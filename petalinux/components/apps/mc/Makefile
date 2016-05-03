ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

include apps.common.mk

export PKG_CONFIG_PATH = $(STAGEDIR)/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR = $(STAGEDIR)

.PHONY: all build install clean help
all: build install
build: .installed

VER := 4.8.16
DIR := mc-$(VER)
ARCHIVE := $(DIR).tar.xz
URL := http://ftp.midnight-commander.org/$(ARCHIVE)

$(ARCHIVE):
	wget -c $(URL)
.unpacked: $(ARCHIVE)
	tar xf $(ARCHIVE)
	touch .unpacked

PREFIX := $(shell pwd)/usr

.configured: .unpacked
	cd $(DIR) && ./configure --host=arm-xilinx-linux-gnueabi \
		--with-screen=ncurses --disable-vfs-sfs --disable-vfs-sftp \
		--with-sysroot=$(STAGEDIR) --without-x --without-gpm-mouse
	touch .configured
.built .files: .configured
	cd $(DIR) && $(MAKE) && $(MAKE) install DESTDIR=$(PREFIX)
	find usr -not -type d >.files
	cp -R -t $(STAGEDIR)/usr $(PREFIX)/*
	rm -R $(PREFIX)
	touch .built
.installed: .built .files
	while read f; do \
		#  if [ -L $$f ]; then TYPE=-s; \
		#elif [ -d $$f ]; then continue; \
		#elif [ -f $$f ]; then TYPE=-f; \
		#fi; \
		$(TARGETINST) -d $(STAGEDIR)/$$f /$$f; \
	done <.files
	touch .installed

install: .installed

clean:
	rm -rf $(DIR) .unpacked .configured .built .installed .files

help:
	@echo "$(TARGETINST)"
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"
