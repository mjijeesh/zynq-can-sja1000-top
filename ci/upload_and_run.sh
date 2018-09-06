#!/bin/bash

set -eux

host=mzapo

dir=$(ssh -T root@$host mktemp -d /tmp/gitlabci.XXXXXX)

# do not copy __pycache__
tar czf archive.tar.gz system/system.bit.bin ctucanfd.ko regtest cantest/*.{py,yaml,txt}
scp archive.tar.gz root@$host:$dir
rm archive.tar.gz

set +e
ssh -T root@$host bash <<EOF
set -eux

cd '$dir'

tar xf archive.tar.gz

# Unload old ctucanfd driver module
rmmod ctucanfd || true
# TODO: run async task for dmesg, level >= warning

mv $dir/system/system.bit.bin /devel/

# Load bitstream
/devel/upbit
# Load ctucanfd driver module
insmod ./ctucanfd.ko

# Disable debug prints
echo module ctucanfd -pfl >/sys/kernel/debug/dynamic_debug/control

# run tests
pytest-3 --junit-xml=test_hw.xml -v --color=yes cantest
EOF
res=$?

scp root@$host:$dir/test_hw.xml test_hw.xml
ssh -T root@$host rm -R $dir

exit $res
