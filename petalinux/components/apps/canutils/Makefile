ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

include apps.common.mk

.PHONY: all build install clean
all: build install

DIR := zynq_canutils
ARCHIVE := $(DIR).rar
URL := http://www.wiki.xilinx.com/file/view/zynq_canutils.rar/498279002/$(ARCHIVE)

$(ARCHIVE):
	wget -c $(URL)
.unpacked: $(ARCHIVE)
	unrar x $(ARCHIVE)
	touch .unpacked
.installed: .unpacked
	cd $(DIR) && tar -x --strip-components=1 -f canutils_install.tar.gz -C $(STAGEDIR)/usr
	cd $(DIR) && tar -x --strip-components=1 -f libskt_install.tar.gz -C $(STAGEDIR)/usr


build: .installed

L := libsocketcan.so
install: build
	for f in candump canecho cansequence; do $(TARGETINST) -d $(STAGEDIR)/usr/bin/$$f /usr/bin/$$f; done
	for f in canconfig; do $(TARGETINST) -d $(STAGEDIR)/usr/sbin/$$f /usr/sbin/$$f; done
	for f in $(L).2.2.0; do $(TARGETINST) -d $(STAGEDIR)/usr/lib/$$f /usr/lib/$$f; done
	for f in $(L) $(L).2; do $(TARGETINST) -s $(L).2.2.0 /usr/lib/$$f; done

clean:
	-rm -Rf $(DIR) .unpacked .installed

help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"
