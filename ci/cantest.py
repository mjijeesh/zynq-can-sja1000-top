#!/usr/bin/env python3
import attr
import can
import struct
import sys
import random
import unittest
import subprocess as sp
# import traceback
# import time
# import os
from pathlib import Path
from contextlib import contextmanager
# from concurrent.futures import ThreadPoolExecutor, TimeoutError

import logging
import logging.config
from log import MyLogRecord
import yaml
import selectors

REGTEST_BIN = '/devel/regtest'


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
        run(['ip', 'link', 'set', self.ifc, 'down'])
        cmd = ['ip', 'link', 'set', self.ifc, 'type', 'can']
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
        run(['ip', 'link', 'set', self.ifc, 'up'])

    def set_down(self):
        """Bring the interface down."""
        run(['ip', 'link', 'set', self.ifc, 'down'])

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
        self.log = logging.getLogger('can_recv.'+ifc.ifc)
        self.bus = ifc.open(fd=fd)
        self.messages = []
        self.N = N
        self.sel = sel
        sel.register(self.bus.socket, selectors.EVENT_READ, data=self)

    def on_event(self):
        self.messages.append(self.bus.recv())
        self.log.debug('received message')
        self.N -= 1
        if self.N <= 0:
            self.log.info('done')
            self.sel.unregister(self.bus.socket)
            self.close()

    def close(self):
        self.bus.shutdown()
        self.bus = None


class MessageSender:
    """Send the given messages on ifc."""

    def __init__(self, ifc, msgs, fd, sel):
        """
        :param ifc: the CANInterface to send to
        :param msgs: iterables of messages to send
        :param fd: whether to open the ifc in FD mode or nor
        :param sel: selector instance
        """
        self.log = logging.getLogger('can_send')
        self.bus = ifc.open(fd=fd)
        self.msgs = msgs
        self.i = 0
        self.sel = sel
        sel.register(self.bus.socket, selectors.EVENT_WRITE, data=self)

    def on_event(self):
        cont = self._send_one()
        # optionally send more frames at once
        # NOTE: not recommended, might lead to frame loss
        #       (and we are not benchmarking here)
        try:
            for i in range(0):
                if not cont:
                    break
                cont = self._send_one()
        except can.CanError as e:
            if e.__context__.errno != 105:  # ENOSPC
                raise

    def _send_one(self):
        if self.i >= len(self.msgs):
            self.log.info('done')
            self.sel.unregister(self.bus.socket)
            self.close()
            return False
        msg = self.msgs[self.i]
        self.log.debug('sending msg')
        self.bus.send(msg)
        self.i += 1  # after successful send
        return True

    def close(self):
        self.bus.shutdown()


class Regtest(unittest.TestCase):
    """Perform basic core integration tests - access registers etc."""

    def test_interfaces(self):
        """Check that there are the interfaces we expect."""
        ifcs = get_can_interfaces()
        cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
        sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']
        self.assertGreaterEqual(len(cafd), 2,
                                "At least 2 CTU CAN FD interfaces expected.")
        self.assertGreaterEqual(len(sja), 1,
                                "At least 1 SJA1000-fdtol interface expected.")
        # from pprint import pprint
        # pprint(ifcs)

    def test_regtest(self):
        """Test basic register access (read, write with byte enable)."""
        ifcs = get_can_interfaces()
        ifcs = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
        for ifc in ifcs:
            with self.subTest(addr=ifc.addr):
                res = sp.run([REGTEST_BIN, '-a', ifc.addr],
                             stdout=sp.PIPE, stderr=sp.STDOUT)
                sys.stdout.write(res.stdout.decode('utf-8'))
                self.assertEqual(res.returncode, 0, "Regtest failed!")


class CanTest(unittest.TestCase):
    """Test communication via SocketCAN.

    For each test, dmesg_log is active (together with test identifying line).
    """

    def __init__(self, *args, **kwds):
        super().__init__(*args, **kwds)
        ifcs = get_can_interfaces()
        self.ifcs = ifcs
        self.cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
        self.sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']

    def setUp(self):
        for ifc in self.ifcs:
            ifc.set_down()
        # print('Random state:', random.getstate())
        print('Test {}:'.format(self.id()), file=dmesg_log)
        self._dmesg_cm = dmesg_into(dmesg_log)
        self._dmesg_cm.__enter__()

    def tearDown(self):
        self._dmesg_cm.__exit__(None, None, None)
        del self._dmesg_cm

    def _test_can_random(self, txi, rxis, fd, pext=0.5, pfd=0.5, pbrs=0.5,
                         NMSGS=1000, bitrate=500000, dbitrate=4000000):
        """Generic test method.

        :param txi: TX interface
        :param rxis: list of RX interfaces
        :param fd: whether to enable FD mode and FD messages; True for iso fd,
                   "non-iso" for non-iso fd, False to disable.
        :param pext: probability of a frame having extended identifier
        :param pext: probability of a frame being CAN FD
        :param pbrs: probability of a CAN FD frame having the Bit Rate Shift
                     bit set
        :param NMSGS: how many messages to send
        :param bitrate: nominal bitrate
        :param dbitrate: data bitrate (for CAN FD)
        """
        if not fd:
            dbitrate = None
            pfd = 0
            pbrs = 0

        txi.set_up(bitrate=bitrate, dbitrate=dbitrate, fd=fd)

        for rxi in rxis:
            rxi_fd = fd if rxi.fd_capable else False
            rxi.set_up(bitrate=bitrate, dbitrate=dbitrate, fd=rxi_fd)

        sent_msgs = [rand_can_frame(pext=pext, pfd=pfd, pbrs=pbrs)
                     for _ in range(NMSGS)]
        nonfd_msgs = [msg for msg in sent_msgs if not msg.is_fd]

        sel = selectors.DefaultSelector()
        recs = []
        for rxi in rxis:
            rxi_fd = fd if rxi.fd_capable else False
            nmsgs = NMSGS if rxi.fd_capable else len(nonfd_msgs)
            receiver = MessageReceiver(rxi, nmsgs, fd=rxi_fd, sel=sel)
            recs.append(receiver)
        MessageSender(txi, sent_msgs, fd=fd, sel=sel)

        # while there are some handlers registered ...
        while sel.get_map():
            try:
                es = sel.select(timeout=1.0)
            except KeyboardInterrupt:
                print(dict(sel.get_map()))
                raise
            for key, events in es:
                key.data.on_event()

        received_msgs = [rec.messages for rec in recs]

        rxidxs = [0] * len(rxis)
        for i, sent in enumerate(sent_msgs):
            for rxi_id, rxi in enumerate(rxis):
                if not (sent.is_fd or sent.bitrate_switch) or rxi.fd_capable:
                    received = received_msgs[rxi_id][rxidxs[rxi_id]]
                    rxidxs[rxi_id] += 1

                    if received != sent:
                        print('Sent:', sent.__dict__)
                        print('Received:', received.__dict__)
                    msg = "Received message {} not equal to sent!".format(i)
                    self.assertEqual(sent, received, msg)
        for rxi_id in range(len(rxis)):
            msg = "Extra messages for ifc {}".format(rxis[rxi_id].ifc)
            self.assertEqual(rxidxs[rxi_id], len(received_msgs[rxi_id]), msg)

    def test_2canfd_non_fd(self):
        cafd = self.cafd
        self._test_can_random(cafd[0], [cafd[1]], fd=False)

    def test_2canfd_fd(self):
        cafd = self.cafd
        self._test_can_random(cafd[0], [cafd[1]], fd=True)

    def test_2canfd_fd_noniso(self):
        cafd = self.cafd
        self._test_can_random(cafd[0], [cafd[1]], fd="non-iso")

    def test_canfd_sja_nonfd(self):
        cafd = self.cafd
        sja = self.sja
        self._test_can_random(cafd[0], [sja[0]], fd=False)

    def test_2canfd_sja_nonfd(self):
        cafd = self.cafd
        sja = self.sja
        self._test_can_random(cafd[0], [cafd[1], sja[0]], fd=False)

    def test_2canfd_sja_fd(self):
        cafd = self.cafd
        sja = self.sja
        self._test_can_random(cafd[0], [cafd[1], sja[0]], fd=True)

    def test_2canfd_sja_fd_noniso(self):
        cafd = self.cafd
        sja = self.sja
        self._test_can_random(cafd[0], [cafd[1], sja[0]], fd="non-iso")


if __name__ == '__main__':
    # Set up logging
    with Path('logging.yaml').open('rt', encoding='utf-8') as f:
        cfg = yaml.load(f)
    logging.setLogRecordFactory(MyLogRecord)
    logging.config.dictConfig(cfg)

    # Set up dmesg logging
    logfile = Path('dmesg-xx.log')
    try:
        logfile.unlink()
    except FileNotFoundError:
        pass

    with logfile.open('at') as dmesg_log:
        # Run the tests
        unittest.main()

# TODO: search the dmesg log for errors
# TODO: check that error counters are 0 and other error stats are 0
