"""Perform basic core integration tests - access registers etc."""

from .common import get_can_interfaces
import subprocess as sp
import sys

REGTEST_BIN = '/devel/regtest'


def test_interfaces(expect):
    """Check that there are the interfaces we expect."""
    ifcs = get_can_interfaces()
    cafd = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
    sja = [ifc for ifc in ifcs if ifc.type == 'sja1000']
    expect(len(cafd) >= 2, "At least 2 CTU CAN FD interfaces expected.")
    expect(len(sja) >= 1, "At least 1 SJA1000-fdtol interface expected.")
    # from pprint import pprint
    # pprint(ifcs)


def test_regtest(expect):
    """Test basic register access (read, write with byte enable)."""
    ifcs = get_can_interfaces()
    ifcs = [ifc for ifc in ifcs if ifc.type == 'ctucanfd']
    for ifc in ifcs:
        # with self.subTest(addr=ifc.addr):
            res = sp.run([REGTEST_BIN, '-a', ifc.addr],
                         stdout=sp.PIPE, stderr=sp.STDOUT)
            sys.stdout.write(res.stdout.decode('utf-8'))
            assert res.returncode == 0, "Regtest failed!"
