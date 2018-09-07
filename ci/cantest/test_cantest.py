"""Test communication via SocketCAN."""

import functools
import logging
import selectors
from pprint import pprint
from . import kmsg
import pytest
from .common import (get_can_interfaces, rand_can_frame, MessageReceiver,
                     MessageSender, CANInterface)


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


ifcs = can_interfaces()
cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']


@pytest.mark.parametrize("txi,rxis,fd", [
    (cafd[0], [cafd[1]],         False),
    (cafd[0], [cafd[1]],         True),
    (cafd[0], [cafd[1]],         "non-iso"),
    (cafd[0], [sja[0]],          False),
    (cafd[0], [cafd[1], sja[0]], False),
    (cafd[0], [cafd[1], sja[0]], True),
    (cafd[0], [cafd[1], sja[0]], "non-iso")], ids=mkid)
@pytest.mark.parametrize('pext,pfd,pbrs',    [(0.5, 0.5, 0.5)])
@pytest.mark.parametrize('bitrate,dbitrate', [(500000, 4000000)])
@pytest.mark.parametrize('NMSGS', [(1000)])
@run_setup_teardown
def test_can_random(expect, fkmsg,  # fixtures
                    txi, rxis, fd, NMSGS, bitrate, dbitrate,
                    pext, pfd, pbrs):
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

    received_msgs = _send_msgs_sync(rxis, txi, sent_msgs, nonfd_msgs,
                                    fd=fd)

    _check_messages_match(received_msgs, sent_msgs, nonfd_msgs, rxis,
                          expect=expect)

    # check that no error condition occured
    for ifc, pretest_info in zip(all_ifcs, pretest_infos):
        _check_ifc_stats(ifc, pretest_info, expect=expect)

    # check that no warning or error was logged in dmesg
    _check_kmsg(expect=expect, fkmsg=fkmsg)


def _send_msgs_sync(rxis, txi, sent_msgs, nonfd_msgs, fd):
    """Send messages to `txi`, receive them on `rxis` and return a list
       of lists.

    The messages are sent and received in one thread in event-based manner.

    :param txi: TX interface
    :param rxis: list of RX interfaces
    :param sent_msgs: messages to send
    :param nonfd_msgs: filtered `sent_msgs` without FD frames
    """
    NMSGS = len(sent_msgs)
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


def _check_messages_match(received_msgs, sent_msgs, nonfd_msgs, rxis, expect):
    log = logging.getLogger('check')
    rxi_rms_sms = [(rxi, rms, sent_msgs if rxi.fd_capable else nonfd_msgs)
                   for rxi, rms in zip(rxis, received_msgs)]
    for rxi, rms, sms in rxi_rms_sms:
        msg = "{}: received frame count not equal to sent frame count".format(rxi.ifc)
        expect(len(rms) == len(sms), msg)
        for i, (received, sent) in enumerate(zip(rms, sms)):
            if received != sent:
                log.info('Sent: {}'.format(sent.__dict__))
                log.info('Received: {}'.format(received.__dict__))
            msg = "{}: Received message {} not equal to sent!".format(rxi.ifc, i)
            expect(sent == received, msg)


def _check_ifc_stats(ifc, pretest_info, *, expect):
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


def _check_kmsg(*, expect, fkmsg):
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
        func('<{}>[{:10.6f}]  {}'.format(msg.pri, msg.timestamp/1e9,
                                         msg.msg))
    expect(len(msgs) == 0, "There were kernel errors/warnings.")
