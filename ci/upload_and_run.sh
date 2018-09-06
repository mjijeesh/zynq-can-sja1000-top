#!/bin/bash

set -eux

host=mzapo

dir=$(ssh -T root@$host mktemp -d /tmp/gitlabci.XXXXXX)

tar czf archive.tar.gz system/system.bit.bin ctucanfd.ko regtest cantest
scp archive.tar.gz root@$host:$dir
rm archive.tar.gz

set +e
ssh -T root@$host bash <<EOF
set -eux

tar xf archive.tar.gz

# Unload old ctucanfd driver module
rmmod ctucanfd || true
# TODO: run async task for dmesg, level >= warning

mv $dir/system.bit.bin /devel/

# Load bitstream
/devel/upbit
# Load ctucanfd driver module
insmod ./ctucanfd.ko

# run tests
pytest-3 --junit-xml=test_hw.xml -v cantest
EOF
res=$?

scp root@$host:$dir/test_hw.xml test_hw.xml
ssh -T root@$host rmdir $dir

exit $res
