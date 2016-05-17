.PHONY: config build all

all: build

config: .configured

.configured:
	petalinux-config --get-hw-description ../system --oldconfig
	$(MAKE) subsystems/linux/configs/u-boot/platform-auto.h
	#touch .configured

build: .configured subsystems/linux/configs/u-boot/platform-auto.h
	petalinux-build
	$(MAKE) bootscript images/linux/BOOT.BIN

images/linux/BOOT.BIN: FORCE
	cd images/linux && petalinux-package --boot --fsbl zynq_fsbl.elf --u-boot u-boot.elf --force

bootscript: bootscript.txt
	mkimage -A arm -O u-boot -T script -C none -a 0 -e 0 -n "t-Boot Script" -d $< $@

subsystems/linux/configs/u-boot/platform-auto.h: FORCE | build/linux/u-boot/Makefile
	$(MAKE) UBOOT_AUTO_CONFIG=y -C build/linux/u-boot autogen-config
	sed -r -i '/PSSERIAL0 \\/r uboot-extra-env.h' $@
	# HACK: force enable legacy image format; it is needed for everything (script, kernel, device tree)
	#       but something sometimes will go crazy and disable it, sometimes it does not
	#       With this hack it works OK.
	sed -r -i '/CONFIG_BOOTCOMMAND/a #define CONFIG_IMAGE_FORMAT_LEGACY' $@
	sed -r -i '/CONFIG_BOOTCOMMAND/a #undef CONFIG_BOOTP_SERVERIP' $@

build/linux/u-boot/Makefile:
	petalinux-build -c u-boot

FORCE:
