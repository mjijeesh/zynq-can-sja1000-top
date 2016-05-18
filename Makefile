# 1. system
# 2. peta linux
# 3. apps (latester)

TFTPROOT := /tftpboot/uzedcan

system_project:
	cd system/script && vivado -mode batch -nolog -nojournal -source recreate.tcl
system/system.hdf system/system.bit:
	cd system/script && vivado -mode batch -nolog -nojournal -source build.tcl
petalinux/bootscript: FORCE
	$(MAKE) -C petalinux bootscript
petalinux/images/linux/BOOT.BIN: FORCE
	$(MAKE) -C petalinux images/linux/BOOT.BIN

.PHONY: dist
dist: system/system.bit petalinux/bootscript petalinux/images/linux/BOOT.BIN petalinux/images/linux/image.ub petalinux/images/linux/system.dtb
	$(MAKE) -C petalinux images/linux/image.ub
	cp -t $(TFTPROOT) $^

petalinux_config: system/system.hdf
	$(MAKE) -C petalinux config
petalinux_build:
	$(MAKE) -C petalinux build bootscript

FORCE:
