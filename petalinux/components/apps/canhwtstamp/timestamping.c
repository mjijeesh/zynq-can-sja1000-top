/*
 * This program demonstrates how the various time stamping features in
 * the Linux kernel work. It receives CANbus frames and prints its timestamps.
 *
 * Incoming packets are time stamped with SO_TIMESTAMPING with or
 * without hardware support, SIOCGSTAMP[NS] (per-socket time stamp) and
 * SO_TIMESTAMP[NS].
 *
 * Copyright (C) 2009 Intel Corporation.
 * Author: Patrick Ohly <patrick.ohly@intel.com>
 *
 * From original ethernet PTP version in linux/Documentation/networking/timestamping/
 * modified by Martin Jerabek <jerabma7@fel.cvut.cz>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <sys/time.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <unistd.h>

#include <asm/types.h>
#include <linux/net_tstamp.h>
#include <linux/errqueue.h>

#ifndef SO_TIMESTAMPING
# define SO_TIMESTAMPING         37
# define SCM_TIMESTAMPING        SO_TIMESTAMPING
#endif

#ifndef SO_TIMESTAMPNS
# define SO_TIMESTAMPNS 35
#endif

#ifndef SIOCGSTAMPNS
# define SIOCGSTAMPNS 0x8907
#endif

#ifndef SIOCSHWTSTAMP
# define SIOCSHWTSTAMP 0x89b0
#endif

static void usage(const char *error)
{
	if (error)
		printf("invalid option: %s\n", error);
	printf("timestamping interface option*\n\n"
	       "Options:\n"
	       "  IP_MULTICAST_LOOP - looping outgoing multicasts\n"
	       "  SO_TIMESTAMP - normal software time stamping, ms resolution\n"
	       "  SO_TIMESTAMPNS - more accurate software time stamping\n"
	       "  SOF_TIMESTAMPING_TX_HARDWARE - hardware time stamping of outgoing packets\n"
	       "  SOF_TIMESTAMPING_TX_SOFTWARE - software fallback for outgoing packets\n"
	       "  SOF_TIMESTAMPING_RX_HARDWARE - hardware time stamping of incoming packets\n"
	       "  SOF_TIMESTAMPING_RX_SOFTWARE - software fallback for incoming packets\n"
	       "  SOF_TIMESTAMPING_SOFTWARE - request reporting of software time stamps\n"
	       "  SOF_TIMESTAMPING_RAW_HARDWARE - request reporting of raw HW time stamps\n"
	       "  SIOCGSTAMP - check last socket time stamp\n"
	       "  SIOCGSTAMPNS - more accurate socket time stamp\n");
	exit(1);
}

static void bail(const char *error)
{
	printf("%s: %s\n", error, strerror(errno));
	exit(1);
}
/*
static void sendpacket(int sock)
{
	struct timeval now;
	int res;
	struct can_frame frame;
	
	memset(&frame, 0, sizeof(frame));
	frame.can_id = 0x88;
	frame.can_dlc = 2;
	frame.data[0] = 0xaa;
	frame.data[1] = 0xbb;
	
	res = write(sock, &frame, sizeof(frame));
	gettimeofday(&now, 0);
	if (res < 0)
		printf("%s: %s\n", "send", strerror(errno));
	else
		printf("%ld.%06ld: sent %d bytes\n",
		       (long)now.tv_sec, (long)now.tv_usec,
		       res);
}
*/
static void printpacket(struct msghdr *msg, int res,
			char *data,
			int sock, int recvmsg_flags,
			int siocgstamp, int siocgstampns)
{
	struct cmsghdr *cmsg;
	struct timeval tv;
	struct timespec ts;
	struct timeval now;

	gettimeofday(&now, 0);

	printf("%ld.%06ld: received %s data, %d bytes, %zu bytes control messages\n",
	       (long)now.tv_sec, (long)now.tv_usec,
	       (recvmsg_flags & MSG_ERRQUEUE) ? "error" : "regular",
	       res,
	       msg->msg_controllen);
	for (cmsg = CMSG_FIRSTHDR(msg);
	     cmsg;
	     cmsg = CMSG_NXTHDR(msg, cmsg)) {
		printf("   cmsg len %zu: ", cmsg->cmsg_len);
		switch (cmsg->cmsg_level) {
		case SOL_SOCKET:
			printf("SOL_SOCKET ");
			switch (cmsg->cmsg_type) {
			case SO_TIMESTAMP: {
				struct timeval *stamp =
					(struct timeval *)CMSG_DATA(cmsg);
				printf("SO_TIMESTAMP %ld.%06ld",
				       (long)stamp->tv_sec,
				       (long)stamp->tv_usec);
				break;
			}
			case SO_TIMESTAMPNS: {
				struct timespec *stamp =
					(struct timespec *)CMSG_DATA(cmsg);
				printf("SO_TIMESTAMPNS %ld.%09ld",
				       (long)stamp->tv_sec,
				       (long)stamp->tv_nsec);
				break;
			}
			case SO_TIMESTAMPING: {
				struct timespec *stamp =
					(struct timespec *)CMSG_DATA(cmsg);
				printf("SO_TIMESTAMPING ");
				printf("SW %ld.%09ld ",
				       (long)stamp->tv_sec,
				       (long)stamp->tv_nsec);
				stamp++;
				/* skip deprecated HW transformed */
				printf("HW transformed %ld.%09ld",
				       (long)stamp->tv_sec,
				       (long)stamp->tv_nsec);
				stamp++;
				printf("HW raw %ld.%09ld",
				       (long)stamp->tv_sec,
				       (long)stamp->tv_nsec);
				break;
			}
			default:
				printf("type %d", cmsg->cmsg_type);
				break;
			}
			break;
		default:
			printf("level %d type %d",
				cmsg->cmsg_level,
				cmsg->cmsg_type);
			break;
		}
		printf("\n");
	}

	if (siocgstamp) {
		if (ioctl(sock, SIOCGSTAMP, &tv))
			printf("   %s: %s\n", "SIOCGSTAMP", strerror(errno));
		else
			printf("SIOCGSTAMP %ld.%06ld\n",
			       (long)tv.tv_sec,
			       (long)tv.tv_usec);
	}
	if (siocgstampns) {
		if (ioctl(sock, SIOCGSTAMPNS, &ts))
			printf("   %s: %s\n", "SIOCGSTAMPNS", strerror(errno));
		else
			printf("SIOCGSTAMPNS %ld.%09ld\n",
			       (long)ts.tv_sec,
			       (long)ts.tv_nsec);
	}
}

static void recvpacket(int sock, int recvmsg_flags,
		       int siocgstamp, int siocgstampns)
{
	char data[256];
	struct sockaddr_can from_addr;
	struct msghdr msg;
	struct iovec entry;
	struct {
		struct cmsghdr cm;
		char control[512];
	} control;
	int res;

	memset(&msg, 0, sizeof(msg));
	msg.msg_iov = &entry;
	msg.msg_iovlen = 1;
	entry.iov_base = data;
	entry.iov_len = sizeof(data);
	msg.msg_name = (caddr_t)&from_addr;
	msg.msg_namelen = sizeof(from_addr);
	msg.msg_control = &control;
	msg.msg_controllen = sizeof(control);

	res = recvmsg(sock, &msg, recvmsg_flags|MSG_DONTWAIT);
	if (res < 0) {
		printf("%s %s: %s\n",
		       "recvmsg",
		       (recvmsg_flags & MSG_ERRQUEUE) ? "error" : "regular",
		       strerror(errno));
	} else {
		printpacket(&msg, res, data,
			    sock, recvmsg_flags,
			    siocgstamp, siocgstampns);
	}
}

int main(int argc, char **argv)
{
	int so_timestamping_flags = 0;
	int so_timestamp = 0;
	int so_timestampns = 0;
	int siocgstamp = 0;
	int siocgstampns = 0;
	char *interface;
	int i;
	int enabled = 1;
	int sock;
	struct ifreq device;
	struct ifreq hwtstamp;
	struct hwtstamp_config hwconfig, hwconfig_requested;
	struct sockaddr_can addr;
	int val;
	socklen_t len;
	struct timeval next;

	if (argc < 2)
		usage(0);
	interface = argv[1];

	for (i = 2; i < argc; i++) {
		if (!strcasecmp(argv[i], "SO_TIMESTAMP"))
			so_timestamp = 1;
		else if (!strcasecmp(argv[i], "SO_TIMESTAMPNS"))
			so_timestampns = 1;
		else if (!strcasecmp(argv[i], "SIOCGSTAMP"))
			siocgstamp = 1;
		else if (!strcasecmp(argv[i], "SIOCGSTAMPNS"))
			siocgstampns = 1;
		else if (!strcasecmp(argv[i], "IP_MULTICAST_LOOP"))
		{
			
		}
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_TX_HARDWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_TX_HARDWARE;
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_TX_SOFTWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_TX_SOFTWARE;
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RX_HARDWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_RX_HARDWARE;
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RX_SOFTWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_RX_SOFTWARE;
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_SOFTWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_SOFTWARE;
		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RAW_HARDWARE"))
			so_timestamping_flags |= SOF_TIMESTAMPING_RAW_HARDWARE;
		else
			usage(argv[i]);
	}

	sock = socket(PF_CAN, SOCK_RAW, CAN_RAW);
	if (sock < 0)
		bail("socket");

	memset(&device, 0, sizeof(device));
	strncpy(device.ifr_name, interface, sizeof(device.ifr_name));
	if (ioctl(sock, SIOCGIFINDEX, &device) < 0)
		bail("getting interface index");

	memset(&hwtstamp, 0, sizeof(hwtstamp));
	strncpy(hwtstamp.ifr_name, interface, sizeof(hwtstamp.ifr_name));
	hwtstamp.ifr_data = (void *)&hwconfig;
	memset(&hwconfig, 0, sizeof(hwconfig));
	hwconfig.tx_type =
		(so_timestamping_flags & SOF_TIMESTAMPING_TX_HARDWARE) ?
		HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
	hwconfig.rx_filter =
		(so_timestamping_flags & SOF_TIMESTAMPING_RX_HARDWARE) ?
		HWTSTAMP_FILTER_PTP_V1_L4_SYNC : HWTSTAMP_FILTER_NONE;
	hwconfig_requested = hwconfig;
	if (ioctl(sock, SIOCSHWTSTAMP, &hwtstamp) < 0) {
		if ((errno == EINVAL || errno == ENOTSUP) &&
		    hwconfig_requested.tx_type == HWTSTAMP_TX_OFF &&
		    hwconfig_requested.rx_filter == HWTSTAMP_FILTER_NONE)
			printf("SIOCSHWTSTAMP: disabling hardware time stamping not possible\n");
		else
			bail("SIOCSHWTSTAMP");
	}
	printf("SIOCSHWTSTAMP: tx_type %d requested, got %d; rx_filter %d requested, got %d\n",
	       hwconfig_requested.tx_type, hwconfig.tx_type,
	       hwconfig_requested.rx_filter, hwconfig.rx_filter);

	/* bind to PTP port */
	addr.can_family = AF_CAN;
	addr.can_ifindex = device.ifr_ifindex;
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0)
		bail("bind");

	/* set socket options for time stamping */
	if (so_timestamp &&
		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP,
			   &enabled, sizeof(enabled)) < 0)
		bail("setsockopt SO_TIMESTAMP");

	if (so_timestampns &&
		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS,
			   &enabled, sizeof(enabled)) < 0)
		bail("setsockopt SO_TIMESTAMPNS");

	if (so_timestamping_flags &&
		setsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING,
			   &so_timestamping_flags,
			   sizeof(so_timestamping_flags)) < 0)
		bail("setsockopt SO_TIMESTAMPING");

	/* verify socket options */
	len = sizeof(val);
	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &val, &len) < 0)
		printf("%s: %s\n", "getsockopt SO_TIMESTAMP", strerror(errno));
	else
		printf("SO_TIMESTAMP %d\n", val);

	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMPNS, &val, &len) < 0)
		printf("%s: %s\n", "getsockopt SO_TIMESTAMPNS",
		       strerror(errno));
	else
		printf("SO_TIMESTAMPNS %d\n", val);

	if (getsockopt(sock, SOL_SOCKET, SO_TIMESTAMPING, &val, &len) < 0) {
		printf("%s: %s\n", "getsockopt SO_TIMESTAMPING",
		       strerror(errno));
	} else {
		printf("SO_TIMESTAMPING %d\n", val);
		if (val != so_timestamping_flags)
			printf("   not the expected value %d\n",
			       so_timestamping_flags);
	}

	/* send packets forever every five seconds */
	gettimeofday(&next, 0);
	next.tv_sec = (next.tv_sec + 1) / 5 * 5;
	next.tv_usec = 0;
	while (1) {
		struct timeval now;
		struct timeval delta;
		long delta_us;
		int res;
		fd_set readfs, errorfs;

		gettimeofday(&now, 0);
		delta_us = (long)(next.tv_sec - now.tv_sec) * 1000000 +
			(long)(next.tv_usec - now.tv_usec);
		if (delta_us > 0) {
			/* continue waiting for timeout or data */
			delta.tv_sec = delta_us / 1000000;
			delta.tv_usec = delta_us % 1000000;

			FD_ZERO(&readfs);
			FD_ZERO(&errorfs);
			FD_SET(sock, &readfs);
			FD_SET(sock, &errorfs);
			printf("%ld.%06ld: select %ldus\n",
			       (long)now.tv_sec, (long)now.tv_usec,
			       delta_us);
			res = select(sock + 1, &readfs, 0, &errorfs, &delta);
			gettimeofday(&now, 0);
			printf("%ld.%06ld: select returned: %d, %s\n",
			       (long)now.tv_sec, (long)now.tv_usec,
			       res,
			       res < 0 ? strerror(errno) : "success");
			if (res > 0) {
				if (FD_ISSET(sock, &readfs))
					printf("ready for reading\n");
				if (FD_ISSET(sock, &errorfs))
					printf("has error\n");
				recvpacket(sock, 0,
					   siocgstamp,
					   siocgstampns);
				/*recvpacket(sock, MSG_ERRQUEUE,
					   siocgstamp,
					   siocgstampns);*/
			}
		} else {
			/* write one packet */
			//sendpacket(sock);
			next.tv_sec += 5;
			continue;
		}
	}

	return 0;
}
