import attr
import logging
import json
import can
import struct
import subprocess as sp
from pathlib import Path
import random
from contextlib import contextmanager
import selectors
import errno

IP_BIN = '/devel/ip'


def run(*args, **kwds):
    return sp.run(*args, check=True, **kwds)


@attr.s
class CANInterface:
    addr = attr.ib()
    ifc = attr.ib()
    type = attr.ib()  # ctucanfd, sja1000, xilinx_can
    fd_capable = attr.ib()

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
        cmd += ['bitrate', str(bitrate)]
        if fd is None:
            fd = bool(dbitrate)
        if not isinstance(fd, bool) and fd != 'non-iso':
            raise ValueError('fd must be either bool or "non-iso"')
        if fd:
            assert self.fd_capable
            cmd += ['dbitrate', str(dbitrate)]
            cmd += ['fd-non-iso', 'on' if fd == 'non-iso' else 'off']
        if self.fd_capable:
            cmd += ['fd', 'on' if fd else 'off']
        log.info('{}: {}'.format(self.ifc, ' '.join(cmd)))
        run(cmd)
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
    for d in Path("/sys/class/net").glob('can*'):
        ifc = d.name
        try:
            of = d / "device/of_node"
            compatible = (of / "compatible").read_bytes()[:-1].decode('ascii')
            type = compat2type(compatible)
        except:
            # in case the device is not in device tree
            log.warning("{}: not in device tree -> leaving .compatible unpopulated".format(ifc))
            type = None
        addr = struct.unpack('>I', (of / "reg").read_bytes()[:4])[0]
        addr = '0x{:08x}'.format(addr)
        ifc = CANInterface(addr=addr, ifc=ifc, type=type, fd_capable=None)

        # discover if the interface is FD capable
        ifc.set_down()
        cmd = ['ip', 'link', 'set', ifc.ifc, 'type', 'can', 'fd', 'off']
        res = sp.run(cmd, check=False, stdout=sp.DEVNULL, stderr=sp.STDOUT)
        ifc.fd_capable = res.returncode == 0

        ifcs.append(ifc)
    return ifcs


def rand_can_frame(pext, pfd, pbrs):
    """Generate a random CAN frame.

    :param pext: probability of the frame having extended identifier
    :param pext: probability of the frame being CAN FD
    :param pbrs: probability of a CAN FD frame having the Bit Rate Shift
                 bit set

    Probability of zero means strictly disabled.
    """
    def p(p): return False if p == 0 else p < random.random()
    ext_id = p(pext)
    id = random.randint(0, 0x1fffffff if ext_id else 0x7FF)
    fd = p(pfd)
    # BRS only in CAN FD frames, indicated by EDL bit
    brs = p(pbrs) if fd else False
    nonfd_lens = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    fd_lens = [0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, 32, 48, 64]
    length = random.choice(fd_lens if fd else nonfd_lens)
    data = bytes(random.getrandbits(8) for _ in range(length))
    msg = can.Message(arbitration_id=id, data=data, dlc=length,
                      extended_id=ext_id, is_fd=fd, bitrate_switch=brs)
    return msg


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
    def __init__(self, ifc, N, fd, sel):
        """
        :param ifc: the CANInterface to recv from
        :param N: number of messages to recv
        :param fd: whether to open the ifc in FD mode or nor
        :param sel: selector instance
        """
        self.messages = []
        self.bus = ifc.open(fd=fd)
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
            self.bus.shutdown()
            self.bus = None


def send_messages(ifc, bus, msgs):
    log = logging.getLogger('can_send')

    i = 0
    while i < len(msgs):
        try:
            log.debug('sending msg')
            bus.send(msgs[i])
            i += 1
            yield
        except can.CanError as e:
            if e.__context__.errno != errno.ENOBUFS:
                raise
    log.info('done')


class MessageSender:
    """Send the given messages on ifc."""

    def __init__(self, ifc, msgs, fd, sel):
        """
        :param ifc: the CANInterface to send to
        :param msgs: iterables of messages to send
        :param fd: whether to open the ifc in FD mode or nor
        :param sel: selector instance
        """
        self.bus = ifc.open(fd=fd)
        self.gen = send_messages(ifc, self.bus, msgs)
        self.sel = sel
        sel.register(self.bus.socket, selectors.EVENT_WRITE, data=self)

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
            self.sel.unregister(self.bus.socket)
            self.bus.shutdown()
            self.bus = None
