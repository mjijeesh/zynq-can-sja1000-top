#!/bin/bash

set -eux

host=mzapo

dir=$(ssh -T root@$host mktemp -d /tmp/gitlabci.XXXXXX)

scp system/system.bit.bin ctucanfd.ko regtest tstbrd_test.bats
    root@$host:$dir


# Upload bitstream
#scp system/system.bit.bin root@$host:/devel/system.bit.bin

# Upload ctucanfd.ko
#scp ctucanfd.ko root@$host:/devel/ctucanfd.ko

# Upload test script
#scp ctucanfd.ko root@$host:/devel/ctucanfd.ko



ssh -T root@$host bash <<EOF
set -eux

trap 'rm -R $dir' EXIT ERROR

# Unload old ctucanfd driver module
rmmod ctucanfd || true
# TODO: run async task for dmesg, level >= warning

mv $dir/system.bit.bin /devel/

# Load bitstream
/devel/upbit
# Load ctucanfd driver module
insmod ctucanfd.ko

# run tests
bats tstbrd_tests.bats
EOF

# TODO: maybe use python for the tests ...

exit
Tests:
- regtest:
    prefix="/sys/firmware/devicetree/base/amba/CTU_CAN_FD@"
    for d in ${prefix}*; do
        addr=0x${d#${prefix}}
        echo Running regtest for ifc $addr
        ./regtest -a $addr
        [ $? -eq 0 ] || fail
    done
- two ctu can fd together, no FD
- two ctu can fd together, FD frames
- two sja1000 together, no FD
- 2x ctucanfd, 1x sja1000
    - no fd
    - some fd

-> really do this in python
