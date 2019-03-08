"""Test communication via SocketCAN."""

import functools
import logging
import selectors
from pprint import pprint
import pytest
from contextlib import contextmanager
from . import kmsg
from .common import (get_can_interfaces, rand_can_frame, MessageReceiver,
                     deterministic_frame_sequence, MessageSender, CANInterface,
                     FrameGenParams)
from .utils import Transaction
from typing import List, Tuple, Iterable, Any
import can
from can.interfaces.socketcan.constants import * # CAN_RAW, CAN_*_FLAG
import time
import errno
from .can_constants import CAN_ERR


@pytest.fixture(scope='module')
def fkmsg():
    i = kmsg.Kmsg()
    yield i
    i.close()


@pytest.fixture(scope='module')
def can_interfaces():
    return get_can_interfaces()


def run_setup_teardown(f):
    @functools.wraps(f)
    def wrapper(*args, fkmsg, **kwds):
        for ifc in can_interfaces():
            ifc.set_down()
        # print('Random state:', random.getstate())
        fkmsg.seek_to_end()
        fkmsg.reset_base_timestamp()
        try:
            f(*args, fkmsg=fkmsg, **kwds)
        finally:
            pass
    return wrapper


def mkid(value):
    def ifcid(ifc):
        if ifc in cafd:
            return 'ctucanfd{}'.format(cafd.index(ifc))
        elif ifc in sja:
            return 'sja{}'.format(sja.index(ifc))
        else:
            return ifc.ifc

    if isinstance(value, list):
        return '[{}]'.format(','.join(ifcid(ifc) for ifc in value))
    elif isinstance(value, CANInterface):
        return ifcid(value)
    else:
        fd = value
        if fd == 'non-iso':
            fdid = 'fd_noniso'
        elif fd:
            fdid = 'fd_iso'
        else:
            fdid = 'nofd'
        return fdid


ifcs = get_can_interfaces()
cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']

if not cafd and not sja:
    logging.warning('Using testing interfaces ...')
    print(ifcs)
    cafd = ifcs[:2]
    sja = ifcs[2:4]


@pytest.mark.parametrize("txi,rxis,fd", [
    (cafd[0], [cafd[1]],         False),
    (cafd[0], [cafd[1]],         True),
    (cafd[0], [cafd[1]],         "non-iso"),
    (cafd[0], [sja[0]],          False),
    (sja[0],  [cafd[0]],         False),
    (cafd[0], [cafd[1], sja[0]], False),
    (cafd[0], [cafd[1], sja[0]], True),
    (cafd[0], [cafd[1], sja[0]], "non-iso")], ids=mkid)
@pytest.mark.parametrize('fgpar', [FrameGenParams(pext=0.5, pfd=0.5, pbrs=0.5)])
@pytest.mark.parametrize('bitrate,dbitrate', [(500000, 4000000)])
@pytest.mark.parametrize('NMSGS', [(10)])
@run_setup_teardown
def test_can_random(expect, fkmsg,  # fixtures
                    txi, rxis, fd, NMSGS, bitrate, dbitrate, fgpar):
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

    all_ifcs = [txi] + rxis

    with _cm_setup_and_check_stats_and_kmsg(**locals()):
        sent_msgs = [rand_can_frame(fgpar) for _ in range(NMSGS)]
        nonfd_msgs = [msg for msg in sent_msgs if not msg.is_fd]

        len_fd, len_nonfd = len(sent_msgs), len(nonfd_msgs)
        buses = [ifc.open(fd=fd and ifc.fd_capable) for ifc in all_ifcs]
        rxis_bus_n = [(rxi, bus, len_fd if rxi.fd_capable else len_nonfd)
                      for rxi, bus in zip(rxis, buses[1:])]
        received_msgs = _send_msgs_sync(rxis_bus_n, [(txi, buses[0], sent_msgs)], fd=fd)
        for bus in buses:
            bus.shutdown()

        _check_messages_match(received_msgs, sent_msgs, nonfd_msgs, rxis,
                              expect=expect)


def _send_msgs_sync(rxis_bus_n: List[Tuple[CANInterface, Any, int]],
                    txis_bus_msgs: List[Tuple[CANInterface, Any, Iterable[can.Message]]],
                    fd) -> List[List[can.Message]]:
    """Send messages to `txi`, receive them on `rxis` and return a list
       of lists.

    The messages are sent and received in one thread in event-based manner.

    :param txis_msgs: [(txi, iterable(CAMFrame))]
    :param rxis: [(rxi, n_expected_messages)]
    """
    sel = selectors.DefaultSelector()
    recs = []
    for rxi, bus, nmsgs in rxis_bus_n:
        receiver = MessageReceiver(ifc=rxi, N=nmsgs, bus=bus, sel=sel)
        recs.append(receiver)
    for txi, bus, msgs in txis_bus_msgs:
        MessageSender(ifc=txi, bus=bus, msgs=msgs, sel=sel)

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


def _check_messages_match(received_msgs: List[List[can.Message]],
                          sent_msgs: List[can.Message],
                          nonfd_msgs: List[can.Message],
                          rxis: List[CANInterface],
                          expect):
    log = logging.getLogger('check')
    rxi_rms_sms = [(rxi, rms, sent_msgs if rxi.fd_capable else nonfd_msgs)
                   for rxi, rms in zip(rxis, received_msgs)]
    for rxi, rms, sms in rxi_rms_sms:
        msg = "{}: received frame count not equal to sent frame count".format(rxi.ifc)
        expect(len(rms) == len(sms), msg)
        # print('{}: expected'.format(rxi.ifc))
        # for msg in sms:
        #     print(msg)
        # print('{}: received'.format(rxi.ifc))
        # for msg in rms:
        #     msg.timestamp = 0
        #     print(msg)

        for i, (received, sent) in enumerate(zip(rms, sms)):
            if received != sent:
                log.info('Sent: {}'.format(sent.__dict__))
                log.info('Received: {}'.format(received.__dict__))
                # received.timestamp = 0
                # print('S:', sent)
                # print('R:', received)
                pass
            msg = "{}: Received message {} not equal to sent!".format(rxi.ifc, i)
            expect(sent == received, msg)


def _check_ifc_stats(ifc, pretest_info, *, expect):
    """Check that no error condition occured on the interface."""
    info = ifc.info()

    def fix_info(g):
        for k in g(info).keys():
            logging.info('{}: {} - {} = {}'.format(k, g(info)[k], g(pretest_info)[k], g(info)[k]-g(pretest_info)[k]))
            g(info)[k] -= g(pretest_info)[k]

    fix_info(lambda i: i['linkinfo']['info_xstats'])
    fix_info(lambda i: i['stats64']['rx'])
    fix_info(lambda i: i['stats64']['tx'])

    def assert_zero(prefix, arr, keys):
        for k in keys:
            msg = '{}: {}{} should be 0 but is {}'.format(ifc.ifc, prefix, k, arr[k])
            expect(arr[k] == 0, msg)

    assert_zero('xstats.', info['linkinfo']['info_xstats'],
                ['bus_error', 'bus_off', 'error_warning', 'error_passive',
                 'restarts'])
    assert_zero('berr.', info['linkinfo']['info_data']['berr_counter'],
                ['rx', 'tx'])
    assert_zero('stats64.rx.', info['stats64']['rx'],
                ['dropped', 'errors', 'over_errors'])
    assert_zero('stats64.tx.', info['stats64']['tx'],
                ['dropped', 'errors', 'carrier_errors'])


def _check_kmsg(*, expect, fkmsg: kmsg.Kmsg):
    """Check that no warning or error was logged in dmesg."""
    def p(msg):
        if msg.pri > kmsg.LOG_WARN:  # lower prio is higher number
            return False
        elif msg.pri >= kmsg.LOG_WARN and 'bitrate error 0.0%' in msg.msg:
            return False
        else:
            return True
    msgs = list(filter(p, fkmsg.messages()))
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
        func('<{}>[{:10.6f}]  {}'.format(msg.pri, msg.timestamp,
                                         msg.msg))
    expect(len(msgs) == 0, "There were kernel errors/warnings.")


@contextmanager
def _cm_setup_and_check_stats_and_kmsg(*, expect, fkmsg, fd, bitrate, dbitrate,
                                       fgpar=None, all_ifcs, ck_stats=True,
                                       ck_kmsg=True, **kwds):
    if fgpar is not None:
        fgpar.mask_fd_inplace(fd)
    if not fd:
        dbitrate = None

    for ifc in all_ifcs:
        ifc_fd = fd if ifc.fd_capable else False
        ifc.set_up(bitrate=bitrate, dbitrate=dbitrate, fd=ifc_fd)

    pretest_infos = [ifc.info() for ifc in all_ifcs]
    yield

    # check that no error condition occured
    if ck_stats:
        for ifc, pretest_info in zip(all_ifcs, pretest_infos):
            _check_ifc_stats(ifc, pretest_info, expect=expect)

    # check that no warning or error was logged in dmesg
    if ck_kmsg:
        _check_kmsg(expect=expect, fkmsg=fkmsg)


@pytest.mark.parametrize('fgpar', [FrameGenParams(pext=0.5, pfd=0.5, pbrs=0.5)])
@pytest.mark.parametrize('bitrate,dbitrate', [(500000, 4000000)])
@pytest.mark.parametrize('NMSGS', [(1000)])
@pytest.mark.parametrize('fd', [(True)])
@run_setup_teardown
def test_can_multitx_2cafd(expect, fkmsg,  # fixtures
                           fd, NMSGS, bitrate, dbitrate, fgpar):
    """Generic test method.

    :param fd: whether to enable FD mode and FD messages; True for iso fd,
               "non-iso" for non-iso fd, False to disable.
    :param fgpar: FrameGenParams
    :param NMSGS: how many messages to send
    :param bitrate: nominal bitrate
    :param dbitrate: data bitrate (for CAN FD)
    """

    def genmsgs(id, fd):
        # fgp = fgpar.mask_fd(fd)
        # return [rand_can_frame(fgp) for _ in range(NMSGS)]
        return deterministic_frame_sequence(NMSGS, id=id, fd=fd)

    def check_messages_match(rec, sent, rxi):
        _check_messages_match([rec], sent, sent, [rxi], expect=expect)

    all_ifcs = [cafd[0], cafd[1]]
    with _cm_setup_and_check_stats_and_kmsg(**locals()):
        buses = [ifc.open(fd=fd and ifc.fd_capable) for ifc in all_ifcs]
        rxis_bus_n = [(ifc, bus, NMSGS) for ifc, bus in zip(all_ifcs, buses)]
        txis_bus_msgs = [(ifc, bus, genmsgs(id=id+1, fd=fd and ifc.fd_capable))
                         for id, (ifc, bus) in enumerate(zip(all_ifcs, buses))]
        received_msgs = _send_msgs_sync(rxis_bus_n, txis_bus_msgs, fd=fd)
        for bus in buses:
            bus.shutdown()

        check_messages_match(received_msgs[0], txis_bus_msgs[1][2], rxis_bus_n[0][0])
        check_messages_match(received_msgs[1], txis_bus_msgs[0][2], rxis_bus_n[1][0])


@pytest.mark.parametrize('bitrate,dbitrate', [(500000, 4000000)])
@pytest.mark.parametrize('fd', [(False)])
@run_setup_teardown
def test_cafd_rx_overrun(expect, fkmsg,  # fixtures
                         fd, bitrate, dbitrate):
    """Test handling RX FIFO overrun condition.

    Test plan:
    - ioctl on rxb to disable reception (mask RXBNEI)
    - send 100 frames on txb
    - ioctl on rxb to enable reception (unmask RXBNEI)
    - receive <100 frames on rxb, the last one should be error frame
    - check that it's overload frame
    - try to read another frame
      - there should not be any (testcase: overload is handled only once)

    :param fd: whether to enable FD mode and FD messages; True for iso fd,
               "non-iso" for non-iso fd, False to disable.
    :param fgpar: FrameGenParams
    :param NMSGS: how many messages to send
    :param bitrate: nominal bitrate
    :param dbitrate: data bitrate (for CAN FD)
    """

    txi = cafd[0]
    rxi = cafd[1]
    log = logging.getLogger('test.cafd_rx_overrun')
    all_ifcs = [txi, rxi]
    with _cm_setup_and_check_stats_and_kmsg(**locals(), ck_stats=False), Transaction() as tx:
        buses = [ifc.open(fd=fd and ifc.fd_capable) for ifc in all_ifcs]
        tx.on_cleanup(lambda: [bus.shutdown() for bus in buses])
        txb, rxb = buses

        # receive errors on rxi
        rxb.socket.setsockopt(SOL_CAN_RAW, CAN_RAW_ERR_FILTER, CAN_ERR.MASK)

        with Transaction() as tx2:
            rxi.mask_rx(True)
            tx2.on_cleanup(lambda: rxi.mask_rx(False))
            for msg in deterministic_frame_sequence(100, id=0, fd=False):
                txb.send(msg)

        msgs = []
        sel = selectors.SelectSelector()
        sel.register(rxb.socket.fileno(), selectors.EVENT_READ)
        tx.on_cleanup(lambda: sel.unregister(rxb.socket))

        while True:
            res = sel.select(timeout=0.5)
            if not res:
                break
            errmsg = rxb.recv()
            msgs.append(errmsg)
            log.info(repr(errmsg.__dict__))

        pprint(msgs)
        assert msgs
        expect(msgs[-1].is_error_frame)
        expect(msgs[-1].arbitration_id == CAN_ERR.CRTL and
               msgs[-1].data[1] == CAN_ERR.CRTL_RX_OVERFLOW,
               "Error frame should be RX overflow.")
        expect(all(not m.is_error_frame for m in msgs[:-1]))
        log.info('Sent {} messages until overflow was reached'.format(len(msgs)-1))
