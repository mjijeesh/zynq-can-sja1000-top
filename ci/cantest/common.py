import attr
import logging
import json
# from . import cantestmod  # monkey-patch the bus interface
import can
from can.interfaces.socketcan.constants import * # CAN_RAW, CAN_*_FLAG
import struct
import subprocess as sp
from pathlib import Path
import random
from contextlib import contextmanager
import selectors
import errno
import copy
from typing import List
import os  # dup
import fcntl  # ioctl


IP_BIN = '/devel/ip'
if not Path(IP_BIN).exists():
    IP_BIN = '/home/martin/src/iproute2/ip/ip'


def run(*args, **kwds):
    return sp.run(*args, check=True, **kwds)


@attr.s
class CANInterface:
    addr = attr.ib()
    ifc = attr.ib()
    type = attr.ib()  # ctucanfd, sja1000, xilinx_can
    fd_capable = attr.ib()

    def is_vcan(self):
        return 'vcan' in self.ifc

    def set_up(self, bitrate, dbitrate=None, fd=None):
        """Set up and bring up the CAN interface.

        :param bitrate: nominal bitrate
        :param dbitrate: data bitrate (for CAN FD)
        :param fd: True for iso fd, "non-iso" for non-iso fd, False to disable.
                   None to detect based on if dbitrate is set.
        """
        log = logging.getLogger('can_setup')
        run([IP_BIN, 'link', 'set', self.ifc, 'down'])
        cmd = [IP_BIN, 'link', 'set', self.ifc, 'type', 'can']
        if not self.is_vcan():
            cmd += ['bitrate', str(bitrate)]
        if fd is None:
            fd = bool(dbitrate)
        if not isinstance(fd, bool) and fd != 'non-iso':
            raise ValueError('fd must be either bool or "non-iso"')
        if fd:
            assert self.fd_capable
            if not self.is_vcan():
                cmd += ['dbitrate', str(dbitrate)]
            cmd += ['fd-non-iso', 'on' if fd == 'non-iso' else 'off']
        if self.fd_capable:
            cmd += ['fd', 'on' if fd else 'off']
        log.info('{}: {}'.format(self.ifc, ' '.join(cmd)))
        run(cmd)

        # needed so that blocking IO works
        run([IP_BIN, 'link', 'set', self.ifc, 'txqueuelen', str(1000)])

        run([IP_BIN, 'link', 'set', self.ifc, 'up'])

    def set_down(self):
        """Bring the interface down."""
        run([IP_BIN, 'link', 'set', self.ifc, 'down'])

    def info(self):
        """Get interface info. Requires (patched) ip from iproute >=v4.13.0."""
        res = run([IP_BIN, '-detail', '-stats', '-json', 'link', 'show',
                   self.ifc], stdout=sp.PIPE)
        return json.loads(res.stdout.decode('ascii'))[0]

    def open(self, **kwds):
        """Open and return a raw CAN socket (can.interface.Bus)."""
        return can.interface.Bus(channel=self.ifc, bustype='socketcan', **kwds)

    def mask_rx(self, mask: bool):
        if self.type != 'ctucanfd':
            raise TypeError('mask_rx supported only on ctucanfd ifc')
        with self.open() as f:
            SIOCDEVPRIVATE = 0x89F0
            IFNAMSIZ = 16
            IOF_SIZE = 32
            CTUCAN_IOCDBG_MASKRX = SIOCDEVPRIVATE
            arg = struct.pack('@{}sH'.format(IFNAMSIZ), self.ifc.encode('ascii'), int(mask))
            arg += bytes(IOF_SIZE - len(arg))
            fcntl.ioctl(f.socket.fileno(), CTUCAN_IOCDBG_MASKRX, arg)


@attr.s
class FrameGenParams:
    pext = attr.ib()
    "probability of a frame having extended identifier"

    pfd = attr.ib()
    "probability of a frame being CAN FD"

    pbrs = attr.ib()
    "probability of a CAN FD frame having the Bit Rate Shift bit set"

    def mask_fd_inplace(self, fd):
        if not fd:
            self.pfd = 0
            self.pbrs = 0
        return self

    def mask_fd(self, fd):
        return copy.copy(self).mask_fd_inplace(fd)


def compat2type(compatible):
    compats = {
        'sja1000':'sja1000',
        'ctucanfd': 'ctucanfd',
        'xlnx,': 'xilinx_can'
    }
    for c, tp in compats.items():
        if c in compatible:
            return tp
    return compatible


def get_can_interfaces():
    """Gather a list of CAN interfaces currently present in the system.

    Requires mounted /sys. Requires the device to be in device tree
    for populating ifc.compatible.
    Also brings all the devices down, because fd_capable may be discovered only
    by trying to configure FD mode on the device (even to off), which in turn
    requires the device to be down (that could be circumvented but there's
    no need to bother).
    """
    log = logging.getLogger()
    ifcs = []
    for d in Path("/sys/class/net").glob('*can*'):
        ifc = d.name
        of = d / "device/of_node"
        if of.exists():
            compatible = (of / "compatible").read_bytes()[:-1].decode('ascii')
            type = compat2type(compatible)
            addr = struct.unpack('>I', (of / "reg").read_bytes()[:4])[0]
            addr = '0x{:08x}'.format(addr)
        else:
            # in case the device is not in device tree
            log.warning("{}: not in device tree -> leaving .compatible and .addr unpopulated".format(ifc))
            type = None
            addr = None

        ifc = CANInterface(addr=addr, ifc=ifc, type=type, fd_capable=None)

        # discover if the interface is FD capable
        ifc.set_down()
        cmd = ['ip', 'link', 'set', ifc.ifc, 'type', 'can', 'fd', 'off']
        res = sp.run(cmd, check=False, stdout=sp.DEVNULL, stderr=sp.STDOUT)
        ifc.fd_capable = res.returncode == 0

        ifcs.append(ifc)
    return ifcs


def rand_can_frame(fgpar: FrameGenParams) -> can.Message:
    """Generate a random CAN frame.

    Probability of zero means strictly disabled.
    """
    def p(p): return False if p == 0 else p < random.random()
    ext_id = p(fgpar.pext)
    id = random.randint(0, 0x1fffffff if ext_id else 0x7FF)
    fd = p(fgpar.pfd)
    # BRS only in CAN FD frames, indicated by EDL bit
    brs = p(fgpar.pbrs) if fd else False
    nonfd_lens = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    fd_lens = [0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, 32, 48, 64]
    length = random.choice(fd_lens if fd else nonfd_lens)
    data = bytes(random.getrandbits(8) for _ in range(length))
    msg = can.Message(arbitration_id=id, data=data, dlc=length,
                      extended_id=ext_id, is_fd=fd, bitrate_switch=brs)
    return msg


def deterministic_frame_sequence(nmsgs: int, id: int, fd: bool) -> List[can.Message]:
    msgs = []
    for i in range(nmsgs):
        ext = (i % 2) == 1
        xfd = fd and (i % 4)/2 == 1
        brs = xfd and (i % 4) == 3
        xlen = (i * 2) % 9
        data = (i & ((1 << xlen) - 1)).to_bytes(xlen, byteorder='little')
        canid = ((id&3) << 8) | (i & 0xFF)
        msg = can.Message(arbitration_id=canid, data=data, dlc=xlen,
                          extended_id=ext, is_fd=xfd, bitrate_switch=brs)
        msgs.append(msg)
    return msgs


@contextmanager
def dmesg_into(fout):
    """Capture kernel messages to file-like fout. Acts as a context manager.

    Colors are enabled. Only messages with severity warn or higher are logged.
    Side effect: the kmsg ring buffer is cleared on entry.
    """
    sp.run(['dmesg', '-C'])  # clear the ring buffer
    fout.flush()
    cmd = ['dmesg', '--follow']
    cmd += ['--level=emerg,alert,crit,err,warn']
    cmd += ['--color=always']
    proc = sp.Popen(cmd, stdout=fout, stdin=sp.DEVNULL)
    try:
        yield
    finally:
        proc.terminate()
        proc.wait()


def receive_messages(ifc, bus, N):
    log = logging.getLogger('can_recv.'+ifc.ifc)
    for i in range(N):
        msg = bus.recv()
        log.debug('received message')
        yield msg
    log.info('done')


class MessageReceiver:
    """Receive N messages from ifc and make them available as a list in .messages.

    TODO: also accept error frames?
    """
    def __init__(self, bus, ifc, N, sel):
        """
        :param ifc: the CANInterface to recv from
        :param N: number of messages to recv
        :param fd: whether to open the ifc in FD mode or nor
        :param sel: selector instance
        """
        self.messages = []
        self.bus = bus
        self.gen = receive_messages(ifc, self.bus, N)
        self.sel = sel
        self.N = N
        sel.register(self.bus.socket, selectors.EVENT_READ, data=self)

    def on_event(self):
        try:
            msg = next(self.gen)
        except:
            self.close()
            raise
        else:
            self.messages.append(msg)
            # because StopIteration would be raised only at next iter
            if len(self.messages) == self.N:
                self.close()

    def close(self):
        if self.bus:
            self.sel.unregister(self.bus.socket)


def send_messages(ifc, bus, msgs):
    log = logging.getLogger('can_send')

    i = 0
    while i < len(msgs):
        log.debug('sending msg')
        bus.send(msgs[i])
        i += 1
        yield
    log.info('done')


class MessageSender:
    """Send the given messages on ifc."""

    def __init__(self, bus, ifc, msgs, sel):
        """
        :param ifc: the CANInterface to send to
        :param msgs: iterables of messages to send
        :param fd: whether to open the ifc in FD mode or nor
        :param sel: selector instance
        """
        self.bus = bus
        self.gen = send_messages(ifc, self.bus, msgs)
        self.sel = sel
        self.fd = None
        try:
            sel.register(self.bus.socket, selectors.EVENT_WRITE, data=self)
        except KeyError:
            self.fd = os.dup(self.bus.socket.fileno())
            sel.register(self.fd, selectors.EVENT_WRITE, data=self)


    def on_event(self):
        try:
            next(self.gen)
        except StopIteration:
            self.close()
        except:
            self.close()
            raise

    def close(self):
        if self.bus:
            if self.fd is not None:
                self.sel.unregister(self.fd)
                os.close(self.fd)
            else:
                self.sel.unregister(self.bus.socket)
