import can
import socket
import struct
import ctypes
from ctypes import *
import can.interfaces.socketcan.socketcan as socketcan
from can.interfaces.socketcan.socketcan import (build_can_frame, dissect_can_frame,
                                                log, log_rx, log_tx,
                                                error_code_to_str)
from can.interfaces.socketcan.constants import *  # CAN_RAW, CAN_*_FLAG
from contextlib import contextmanager


# copied from kernel
SOF_TIMESTAMPING_TX_HARDWARE = (1<<0)
SOF_TIMESTAMPING_TX_SOFTWARE = (1<<1)
SOF_TIMESTAMPING_RX_HARDWARE = (1<<2)
SOF_TIMESTAMPING_RX_SOFTWARE = (1<<3)
SOF_TIMESTAMPING_SOFTWARE = (1<<4)
SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5)
SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6)
SOF_TIMESTAMPING_OPT_ID = (1<<7)
SOF_TIMESTAMPING_TX_SCHED = (1<<8)
SOF_TIMESTAMPING_TX_ACK = (1<<9)
SOF_TIMESTAMPING_OPT_CMSG = (1<<10)
SOF_TIMESTAMPING_OPT_TSONLY = (1<<11)
SOF_TIMESTAMPING_OPT_STATS = (1<<12)
SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13)
SOF_TIMESTAMPING_OPT_TX_SWHW = (1<<14)

SO_TIMESTAMPNS = 35
SO_TIMESTAMPING = 37
SO_RXQ_OVFL = 40


def timespec2double(ts):
    sec, nsec = struct.unpack('@ll', ts)
    return sec + nsec * 1e-9


def process_anc(anc):
    res = {}
    for cmsg_level, cmsg_type, cmsg_data in anc:
        if cmsg_level == socket.SOL_SOCKET:
            if cmsg_type == SO_TIMESTAMPNS:
                res['timestampns'] = timespec2double(cmsg_data)
            elif cmsg_type == SO_TIMESTAMPING:
                data = struct.unpack('@llllll', cmsg_data)
                data = zip(data[::2], data[1::2])
                res['timestamping'] = tuple(sec + nsec*1e-9 for sec, nsec in data)
            elif cmsg_type == SO_RXQ_OVFL:
                res['dropped'] = struct.unpack('I', cmsg_data)[0]
    print(res)
    return res


def read_msg(sock):
    """
    Captures a message from given socket.

    :param socket.socket sock:
        The socket to read a message from.

    :return: The received message.
    """
    # Fetching the Arb ID, DLC and Data
    try:
        cf, anc, _, addr = sock.recvmsg(CANFD_MTU, 128)  # 2*3*8 + 8 + 4
        channel = addr[0] if isinstance(addr, tuple) else addr
    except socket.error as exc:
        raise can.CanError("Error receiving: %s" % exc)

    can_id, can_dlc, flags, data = dissect_can_frame(cf)

    anc = process_anc(anc)

    if 'timestamping' in anc:
        timestamp = anc['timestamping']
    elif 'timestampns' in anc:
        timestamp = anc['timestampns']
    else:
        timestamp = 0

    # EXT, RTR, ERR flags -> boolean attributes
    #   /* special address description flags for the CAN_ID */
    #   #define CAN_EFF_FLAG 0x80000000U /* EFF/SFF is set in the MSB */
    #   #define CAN_RTR_FLAG 0x40000000U /* remote transmission request */
    #   #define CAN_ERR_FLAG 0x20000000U /* error frame */
    is_extended_frame_format = bool(can_id & CAN_EFF_FLAG)
    is_remote_transmission_request = bool(can_id & CAN_RTR_FLAG)
    is_error_frame = bool(can_id & CAN_ERR_FLAG)
    is_fd = len(cf) == CANFD_MTU
    bitrate_switch = bool(flags & CANFD_BRS)
    error_state_indicator = bool(flags & CANFD_ESI)

    if is_extended_frame_format:
        log.debug("CAN: Extended")
        # TODO does this depend on SFF or EFF?
        arbitration_id = can_id & 0x1FFFFFFF
    else:
        log.debug("CAN: Standard")
        arbitration_id = can_id & 0x000007FF

    msg = can.Message(timestamp=timestamp,
                      channel=channel,
                      arbitration_id=arbitration_id,
                      extended_id=is_extended_frame_format,
                      is_remote_frame=is_remote_transmission_request,
                      is_error_frame=is_error_frame,
                      is_fd=is_fd,
                      bitrate_switch=bitrate_switch,
                      error_state_indicator=error_state_indicator,
                      dlc=can_dlc,
                      data=data)

    log_rx.debug('Received: %s', msg)

    return msg


def check_status(result, function, arguments):
    if result < 0:
        raise can.CanError(error_code_to_str(ctypes.get_errno()))
    return result


libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)
libc.sendmmsg.errcheck = check_status


class iovec(Structure):
    _fields_ = [('iov_base', c_void_p), ('iov_len', c_size_t)]


class msg_hdr(Structure):
    _fields_ = [('msg_name', c_void_p),
                ('msg_namelen', c_int),
                ('msg_iov', POINTER(iovec)),
                ('msg_iovlen', c_size_t),
                ('msg_control', c_void_p),
                ('msg_controllen', c_size_t),
                ('msg_flags', c_uint),
                ]


class mmsg_hdr(Structure):
    _fields_ = [('msg_hdr', msg_hdr), ('msg_len', c_uint)]


def send_multi(sock, msgs):
    data = [build_can_frame(msg) for msg in msgs]
    iovecs_arr_t = iovec * len(msgs)
    iovecs = iovecs_arr_t()
    mmsghdr_arr_t = mmsg_hdr * len(msgs)
    mmsgs = mmsghdr_arr_t()
    data_buf = ctypes.create_string_buffer(CANFD_MTU*len(msgs))
    addr = addressof(data_buf)
    off = 0
    memset(mmsgs, 0, sizeof(mmsgs))
    for i, msg in enumerate(msgs):
        data = build_can_frame(msg)
        data_buf[off:off+len(data)] = data
        iovecs[i].iov_base = addr + off
        iovecs[i].iov_len = len(data)
        mmsgs[i].msg_hdr.msg_iov = pointer(iovecs[i])
        mmsgs[i].msg_hdr.msg_iovlen = 1
        off += len(data)

    res = libc.sendmmsg(sock.fileno(), byref(mmsgs), len(msgs), 0)
    # log.info('sendmmsg: {}'.format(res))
    return res


#
# Even Python's sock.gettimeout/settimeout is crap. It only sets socket's
# internal property, which is used on builtin sock operations. [gs]etblocking
# is, however, genuine and issues the ioctl.
# We have to reimplement [gs]ettimeout to use [gs]etsockopt SO_{RCV,SND}TIMEO.
# Note that both send and receive timeouts are set every time.
#

def _gettimeout(sock):
    if sock.gettimeout() == 0:  # non-blocking
        return 0
    fmt = '@ll'
    res = sock.getsockopt(socket.SOL_SOCKET, socket.SO_SNDTIMEO, struct.calcsize(fmt))
    sec, usec = struct.unpack(fmt, res)
    return sec + usec * 1e-6


def _settimeout(sock, timeout):
    if timeout is None:
        sock.setblocking(False)
    else:
        sock.setblocking(True)
        fmt = '@ll'
        sec = int(timeout)
        usec = int((timeout - sec) * 1e6)
        val = struct.pack(fmt, sec, usec)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDTIMEO, val)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVTIMEO, val)


@contextmanager
def scoped_tmout(sock, timeout):
    prev = _gettimeout(sock)
    _settimeout(sock, timeout)
    try:
        yield
    finally:
        _settimeout(sock, prev)


def _recv_internal(self, timeout):
    with scoped_tmout(self.socket, timeout):
        msg = read_msg(self.socket)
    return msg, self._is_filtered


def send(self, msg, timeout=None):
    data = build_can_frame(msg)
    with scoped_tmout(self.socket, timeout):
        self.socket.send(data)


def sock_send_multi(self, msgs, timeout=None):
    with scoped_tmout(self.socket, timeout):
        return send_multi(self.socket, msgs)


def sock_init(self, *args, **kwds):
    _base_init(self, *args, **kwds)
    so_timestamping_flags = SOF_TIMESTAMPING_RAW_HARDWARE \
                          | SOF_TIMESTAMPING_SOFTWARE \
                          | SOF_TIMESTAMPING_RX_HARDWARE \
                          | SOF_TIMESTAMPING_RX_SOFTWARE
    self.socket.setsockopt(socket.SOL_SOCKET, SO_TIMESTAMPING,
                           so_timestamping_flags)
    # self.socket.setsockopt(socket.SOL_SOCKET, SO_TIMESTAMPNS, 1)


_base_init = socketcan.SocketcanBus.__init__


def monkeypatch():
    # cannot extend, because the reference to the original class is already loaded somewhere
    import logging
    logging.info('Monkey-patching ...')
    socketcan.SocketcanBus.__init__ = sock_init
    socketcan.SocketcanBus._recv_internal = _recv_internal
    socketcan.SocketcanBus.send = send
    socketcan.SocketcanBus.send_multi = sock_send_multi


monkeypatch()
