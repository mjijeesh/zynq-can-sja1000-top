#include "loguru.hpp"

#include <errno.h>
#include <fcntl.h>
#include <net/if.h>
#include <poll.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/epoll.h>
#include <sys/uio.h>
#include <unistd.h>
#include <string.h> // memset
//#include <stropts.h> // ioctl
#include <linux/sockios.h> // ioctl
#include <linux/errqueue.h> // scm_timestamping

#include <linux/can/raw.h>
#include <linux/net_tstamp.h>

#include "cantest.h"
#include <iostream>

static uint64_t ts2ns(const struct timespec &ts) {
    return uint64_t(ts.tv_sec) * 1'000'000'000ULL + ts.tv_nsec;
}

void  _set_sockopt(int s, int lvl, int opt, int val, const char *lvlname, const char *name) {
    int res = setsockopt(s, lvl, opt, &val, sizeof(val));
    if (res)
        LOG_F(WARNING, "setsockopt(%s, %s, %d): %s", lvlname, name, val, strerror(errno));
}
#define SET_SOCKOPT(s, lvl, opt, val) _set_sockopt(s, lvl, opt, val, #lvl, #val)

static inline int sock_get_if_index(int s, const char *if_name)
{
    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));

    strcpy(ifr.ifr_name, if_name);
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0)
        throw error {errno, "SIOCGIFINDEX"};

    return ifr.ifr_ifindex;
}

received_frame receive(int s)
{
    char ctrlmsg[CMSG_SPACE(sizeof(struct timeval)) + CMSG_SPACE(sizeof(uint32_t))];
    struct iovec iov;
    struct msghdr msg;
    struct cmsghdr *cmsg;
    struct sockaddr_can addr;
    int nbytes;
    //static uint64_t dropcnt = 0;
    received_frame res;

    iov.iov_base = &res.frame;
    msg.msg_name = &addr;
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;
    msg.msg_control = &ctrlmsg;

    /* these settings may be modified by recvmsg() */
    iov.iov_len = sizeof(res.frame);
    msg.msg_namelen = sizeof(addr);
    msg.msg_controllen = sizeof(ctrlmsg);
    msg.msg_flags = 0;

    nbytes = recvmsg(s, &msg, 0);
    if (nbytes < 0)
        throw error {errno, "recvmsg"};

    if (nbytes == sizeof(struct can_frame))
        res.is_fd = false;
    else if (nbytes == sizeof(struct canfd_frame))
        res.is_fd = true;
    else
        throw error {-1, "recvmsg: invalid size"};

    for (cmsg = CMSG_FIRSTHDR(&msg);
         cmsg && (cmsg->cmsg_level == SOL_SOCKET);
         cmsg = CMSG_NXTHDR(&msg,cmsg)) {
        if (cmsg->cmsg_type == SO_TIMESTAMPNS) {
            struct timespec tmp;
            memcpy(&tmp, CMSG_DATA(cmsg), sizeof(struct timespec));
            LOG_F(INFO, "timestamp_ns = %llu", ts2ns(tmp));
            if (!res.ts_kern) {
                res.ts_kern = ts2ns(tmp);
            }
        } else if (cmsg->cmsg_type == SO_TIMESTAMPING) {
            struct scm_timestamping tmp;
            memcpy(&tmp, CMSG_DATA(cmsg), sizeof(struct scm_timestamping));
            LOG_F(INFO, "timestamping = {%llu, %llu, %llu}", ts2ns(tmp.ts[0]), ts2ns(tmp.ts[1]), ts2ns(tmp.ts[2]));
            res.ts_kern = ts2ns(tmp.ts[2]);
        }/* else if (cmsg->cmsg_type == SO_RXQ_OVFL) {
            uint32_t ovfl;
            memcpy(&ovfl, CMSG_DATA(cmsg), sizeof(ovfl));
            dropcnt += ovfl;
        }*/
    }
    return res;
}


int can_open(const char *ifc)
{
    int s;

    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0)
        throw error {errno, "socket"};

    struct sockaddr_can addr;
    memset(&addr, 0, sizeof(addr));
    addr.can_family = AF_CAN;
    addr.can_ifindex = sock_get_if_index(s, ifc);

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0)
        throw error {errno, "bind"};

    //uint32_t so_timestamping_flags = SOF_TIMESTAMPING_RX_HARDWARE;
    uint32_t so_timestamping_flags = SOF_TIMESTAMPING_RX_HARDWARE | SOF_TIMESTAMPING_RAW_HARDWARE | SOF_TIMESTAMPING_SOFTWARE;
    SET_SOCKOPT(s, SOL_SOCKET, SO_TIMESTAMPNS, 1);

    struct ifreq hwtstamp;
	struct hwtstamp_config hwconfig;

    memset(&hwtstamp, 0, sizeof(hwtstamp));
    strncpy(hwtstamp.ifr_name, ifc, sizeof(hwtstamp.ifr_name));
    hwtstamp.ifr_data = (char*) &hwconfig;
    memset(&hwconfig, 0, sizeof(hwconfig));
    hwconfig.tx_type = (so_timestamping_flags & SOF_TIMESTAMPING_TX_HARDWARE) ?
                        HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
    hwconfig.rx_filter = (so_timestamping_flags & SOF_TIMESTAMPING_RX_HARDWARE) ?
                        HWTSTAMP_FILTER_PTP_V1_L4_SYNC : HWTSTAMP_FILTER_NONE;
    if (ioctl(s, SIOCSHWTSTAMP, &hwtstamp) < 0)
        LOG_F(ERROR, "SIOCSHWTSTAMP: %s", strerror(errno));

    SET_SOCKOPT(s, SOL_SOCKET, SO_TIMESTAMPING, so_timestamping_flags);

    /*
    const int dropmonitor_on = 1;
    if (setsockopt(s, SOL_SOCKET, SO_RXQ_OVFL,
               &dropmonitor_on, sizeof(dropmonitor_on)) < 0)
        throw error {errno, "setsockopt SO_RXQ_OVFL not supported by your Linux Kernel"};
    */
    return s;
}

void test_2(int sock)
{
    int res;
    struct can_frame frm;
    memset(&frm, 0, sizeof(frm));
    frm.can_id = 0x123;
    frm.can_dlc = 4;
    frm.data[0] = 0xDE;
    frm.data[1] = 0xAD;
    frm.data[2] = 0xBE;
    frm.data[3] = 0xEF;

    struct iovec iov[1000];
    int iovcnt = 1000;

    for (int i=0; i<iovcnt; ++i) {
        iov[i].iov_base = &frm;
        iov[i].iov_len = sizeof(frm);
    }
    res = writev(sock, iov, iovcnt);
    if (res < 1)
        LOG_F(ERROR, "writev: %s", strerror(errno));
    else
        LOG_F(INFO, "writev: written %d bytes", res);
}

void test_3(int sock)
{
    int res;
    struct can_frame frm;
    memset(&frm, 0, sizeof(frm));
    frm.can_id = 0x123;
    frm.can_dlc = 4;
    frm.data[0] = 0xDE;
    frm.data[1] = 0xAD;
    frm.data[2] = 0xBE;
    frm.data[3] = 0xEF;

    struct iovec iov;
    struct mmsghdr msgs[1000];
    int msgcnt = 1000;

    iov.iov_base = &frm;
    iov.iov_len = sizeof(frm);
    memset(msgs, 0, sizeof(msgs));
    for (int i=0; i<msgcnt; ++i) {
        msgs[i].msg_hdr.msg_iov = &iov;
        msgs[i].msg_hdr.msg_iovlen = 1;
    }
    res = sendmmsg(sock, msgs, msgcnt, 0);
    if (res < 1)
        LOG_F(ERROR, "sendmmsg: %s", strerror(errno));
    else
        LOG_F(INFO, "sendmmsg: written %d messages", res);
}


void test_1(int sock)
{
    struct can_frame frm;
    int res;
    memset(&frm, 0, sizeof(frm));
    frm.can_id = 0x123;
    frm.can_dlc = 4;
    frm.data[0] = 0xDE;
    frm.data[1] = 0xAD;
    frm.data[2] = 0xBE;
    frm.data[3] = 0xEF;

    int epoll_fd = epoll_create(1);
    epoll_event evt;
    evt.events = EPOLLOUT | EPOLLET;
    evt.data.fd = sock;
    res = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, sock, &evt);
    if (res != 0)
        throw error {errno, "epoll_ctl"};

    for (int i=0; i<1000; ++i) {
        int res = write(sock, &frm, sizeof(frm));
        if (res != sizeof(frm))
            LOG_F(ERROR, "write: %s", strerror(errno));
        if (res == -1 && (errno == ENOBUFS || errno == EAGAIN)) {
            LOG_F(INFO, "waiting ...");
            res = epoll_wait(epoll_fd, &evt, 1, 5000);
            if (res < 0)
                LOG_F(WARNING, "epoll_wait: %s", strerror(errno));
        }
    }
}

void test_recv(int sock)
{
    while (1) {
        auto fr = receive(sock);
        if (fr.ts_kern)
            printf("ts = %llu\n", *fr.ts_kern);
        else
            printf("ts missing");
    }
}

int main(int argc, char *argv[])
{
    int ret;
    loguru::init(argc, argv);
    LOG_F(INFO, "Hello from main.cpp!");
    if (argc < 2) {
        LOG_F(ERROR, "Usage: %s ifc", argv[0]);
        return 1;
    }

    int sock = -1;
    try {
        const char *ifc = argv[1];
        sock = can_open(ifc);

        SET_SOCKOPT(sock, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS, 0);
        SET_SOCKOPT(sock, SOL_CAN_RAW, CAN_RAW_FD_FRAMES, 1);
        SET_SOCKOPT(sock, SOL_CAN_RAW, CAN_RAW_LOOPBACK, 1);

        //test_1(sock);
        //test_3(sock);
        test_recv(sock);

        ret = 0;
    } catch (const std::exception &e) {
        LOG_F(ERROR, e.what());
        ret = 1;
    }
    close(sock);
    return ret;
}
