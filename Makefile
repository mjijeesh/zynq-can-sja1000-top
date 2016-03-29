# 1. system
# 2. peta linux
# 3. apps (latester)

system_project:
	cd system/scripts && vivado -mode batch -nolog -nojournal -source recreate.tcl
system/system.hdf:
	cd system/scripts && vivado -mode batch -nolog -nojournal -source build.tcl

petalinux_config: system/system.hdf
	$(MAKE) -C petalinux config
petalinux_build:
	$(MAKE) -C petalinux build
