# 1. system
# 2. peta linux
# 3. apps (latester)

TFTPROOT := /tftpboot/uzedcan

system_project:
	cd system/script && vivado -mode batch -nolog -nojournal -source recreate.tcl -tclargs --origin_dir `pwd`
system/system.hdf system/system.bit:
	cd system/script && vivado -mode batch -nolog -nojournal -source build.tcl
system/system.bit.bin: system/system.bit
	cd system && bootgen -image system.bif -w -process_bitstream bin
petalinux/bootscript: FORCE
	$(MAKE) -C petalinux bootscript
petalinux/images/linux/BOOT.BIN: FORCE
	$(MAKE) -C petalinux images/linux/BOOT.BIN

#.PHONY: dist
#dist:
#	cd system/script && vivado -mode batch -nolog -nojournal -source dist.tcl
#dist: system/system.bit petalinux/bootscript petalinux/images/linux/BOOT.BIN petalinux/images/linux/image.ub petalinux/images/linux/system.dtb
#	$(MAKE) -C petalinux images/linux/image.ub
#	cp -t $(TFTPROOT) $^

petalinux_config: system/system.hdf
	$(MAKE) -C petalinux config
petalinux_build:
	$(MAKE) -C petalinux build bootscript
dts:
	cd system/script && hsi -mode batch -nolog -nojournal -source gendevtree.tcl
fsbl:
	cd system/script && hsi -mode batch -nolog -nojournal -source mkfsbl.tcl

.PHONT: system_project petalinux_config petalinux_build dts fsbl

FORCE:
