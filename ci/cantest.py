#!/usr/bin/env python3
import attr
import errno
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
import json
from pprint import pprint
import kmsg

REGTEST_BIN = '/devel/regtest'
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
            if e.__context__.errno != errno.ENOSPC:
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
        self.log = logging.getLogger('test')
        ifcs = get_can_interfaces()
        self.ifcs = ifcs
        self.cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
        self.sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']
        self.kmsg = kmsg.Kmsg()

    def __del__(self):
        self.kmsg.close()

    def setUp(self):
        for ifc in self.ifcs:
            ifc.set_down()
        # print('Random state:', random.getstate())
        print('Test {}:'.format(self.id()), file=dmesg_log)
        self._dmesg_cm = dmesg_into(dmesg_log)
        self._dmesg_cm.__enter__()
        self.kmsg.seek_to_end()
        self.kmsg.reset_base_timestamp()

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

        all_ifcs = [txi] + rxis
        pretest_infos = [ifc.info() for ifc in all_ifcs]

        sent_msgs = [rand_can_frame(pext=pext, pfd=pfd, pbrs=pbrs)
                     for _ in range(NMSGS)]
        nonfd_msgs = [msg for msg in sent_msgs if not msg.is_fd]

        received_msgs = self._send_msgs_sync(rxis, txi, sent_msgs, nonfd_msgs,
                                             fd=fd)

        self._check_messages_match(received_msgs, sent_msgs, nonfd_msgs, rxis)

        # check that no error condition occured
        for ifc, pretest_info in zip(all_ifcs, pretest_infos):
            self._check_ifc_stats(ifc, pretest_info)

        # check that no warning or error was logged in dmesg
        self._check_kmsg()

    def _send_msgs_sync(self, rxis, txi, sent_msgs, nonfd_msgs, fd):
        """Send messages to `txi`, receive them on `rxis` and return a list
           of lists.

        The messages are sent and received in one thread in event-based manner.

        :param txi: TX interface
        :param rxis: list of RX interfaces
        :param sent_msgs: messages to send
        :param nonfd_msgs: filtered `sent_msgs` without FD frames
        """
        NMSGS = len(sent_msgs)
        self.log.info('{} frames in total, {} non-fd frames, {} fd frames'
                      .format(NMSGS, len(nonfd_msgs), NMSGS-len(nonfd_msgs)))
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
        return received_msgs

    def _check_messages_match(self, received_msgs, sent_msgs, nonfd_msgs, rxis):
        log = logging.getLogger('check')
        rxi_rms_sms = [(rxi, rms, sent_msgs if rxi.fd_capable else nonfd_msgs)
                       for rxi, rms in zip(rxis, received_msgs)]
        for rxi, rms, sms in rxi_rms_sms:
            msg = "{}: received frame count not equal to sent frame count".format(rxi.ifc)
            self.assertEqual(len(rms), len(sms), msg)
            for i, (received, sent) in enumerate(zip(rms, sms)):
                if received != sent:
                    log.info('Sent: {}'.format(sent.__dict__))
                    log.info('Received: {}'.format(received.__dict__))
                msg = "{}: Received message {} not equal to sent!".format(rxi.ifc, i)
                self.assertEqual(sent, received, msg)

    def _check_ifc_stats(self, ifc, pretest_info):
        """Check that no error condition occured on the interface."""
        info = ifc.info()

        def fix_info(g):
            for k in g(info).keys():
                g(info)[k] -= g(pretest_info)[k]

        fix_info(lambda i: i['linkinfo']['info_xstats'])
        fix_info(lambda i: i['stats64']['rx'])
        fix_info(lambda i: i['stats64']['tx'])

        def assert_zero(prefix, arr, keys):
            for k in keys:
                msg = '{}: {}{} should be 0'.format(ifc.ifc, prefix, k)
                self.assertEqual(arr[k], 0, msg)

        assert_zero('xstats.', info['linkinfo']['info_xstats'],
                    ['bus_error', 'bus_off', 'error_warning', 'error_passive',
                     'restarts'])
        assert_zero('berr.', info['linkinfo']['info_data']['berr_counter'],
                    ['rx', 'tx'])
        assert_zero('stats64.rx.', info['stats64']['rx'],
                    ['dropped', 'errors', 'over_errors'])
        assert_zero('stats64.tx.', info['stats64']['tx'],
                    ['dropped', 'errors', 'carrier_errors'])


    def _check_kmsg(self):
        """Check that no warning or error was logged in dmesg."""
        def p(msg):
            if msg.pri > kmsg.LOG_WARN:  # lower prio is higher number
                return False
            elif msg.pri >= kmsg.LOG_WARN and 'bitrate error 0.0%' in msg.msg:
                return False
            else:
                return True
        msgs = list(filter(p, self.kmsg.messages()))
        log = logging.getLogger('dmesg')
        pri2func = {
            kmsg.LOG_EMERG: log.error,
            kmsg.LOG_CRIT: log.error,
            kmsg.LOG_ALERT: log.error,
            kmsg.LOG_ERR: log.error,
            kmsg.LOG_WARN: log.warning,
            kmsg.LOG_INFO: log.info,
            kmsg.LOG_NOTICE: log.info,
            kmsg.LOG_DEBUG: log.debug,
        }
        for msg in msgs:
            func = pri2func.get(msg.pri, log.error)
            func('<{}>[{:10.6f}]  {}'.format(msg.pri, msg.timestamp/1e9,
                                             msg.msg))
        self.assertEqual(len(msgs), 0, "There were kernel errors/warnings.")

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

# TODO: data overun test
