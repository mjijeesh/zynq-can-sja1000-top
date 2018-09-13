from . import cantestmod  # monkey-patch the bus interface
import can
from .common import *
from .utils import catch
from concurrent.futures import ThreadPoolExecutor
#import pytest

ifcs = get_can_interfaces()
cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']


def highest_bit(v):
    b = 0
    while v > (1 << b):
        b += 1
    return b


def test_errload():
    fgpar = FrameGenParams(pext=0.5, pfd=0.5, pbrs=0.5)
    bitrate,dbitrate,fd = 500000, 4000000,False
    can_interfaces = get_can_interfaces()
    for ifc in can_interfaces:
        ifc.set_down()
    if fgpar is not None:
        fgpar.mask_fd_inplace(fd)
    if not fd:
        dbitrate = None

    all_ifcs = [cafd[0], cafd[1]]
    for ifc in all_ifcs:
        ifc_fd = fd if ifc.fd_capable else False
        ifc.set_up(bitrate=bitrate, dbitrate=dbitrate, fd=ifc_fd)

    bus1 = cafd[0].open(fd=fd)
    bus2 = cafd[1].open(fd=fd)
    frames1 = [rand_can_frame(fgpar) for _ in range(1000)]
    frames2 = copy.deepcopy(frames1)
    for f1, f2 in zip(frames1, frames2):
        highest = highest_bit(f1.arbitration_id)
        f1.arbitration_id |= (1 << highest)
        f2.arbitration_id &= ~(1 << highest)

    @catch
    def main(bus, frames):
        logging.info('sending multi ...')
        try:
            res = bus.send_multi(frames, timeout=5.0)
            logging.info('{} frames'.format(res))
        finally:
            logging.info('... done')
    with ThreadPoolExecutor(2) as exe:
        exe.map(main, [bus1, bus2], [frames1, frames2])
    while True:
        print(bus1.recv(timeout=1.0))

def test2():
    fgpar = FrameGenParams(pext=0.5, pfd=0.5, pbrs=0.5)
    fd = False
    fgpar.mask_fd_inplace(fd=fd)

    bus1 = cafd[0].open(fd=fd)
    bus2 = cafd[1].open(fd=fd)
    bus1.send(rand_can_frame(fgpar))
    print(bus2.recv(timeout=1.0))

if __name__ == '__main__':
    from .conftest import setup_logging
    setup_logging()
    cantestmod.monkeypatch()
    #test_errload()
    test2()
