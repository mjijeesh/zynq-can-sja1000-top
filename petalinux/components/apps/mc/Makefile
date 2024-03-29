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

PREFIX := $(shell pwd)/image

.configured: .unpacked
	cd $(DIR) && ./configure --host=arm-xilinx-linux-gnueabi \
		--with-screen=ncurses --disable-vfs-sfs --disable-vfs-sftp \
		--with-sysroot=$(STAGEDIR) --without-x --without-gpm-mouse \
		--prefix=/ --exec-prefix=/usr --includedir=/usr/include --datarootdir=/usr/share
	touch .configured
.built: .configured
	cd $(DIR) && $(MAKE)
	touch .built
.installed: .built
	cd $(DIR) && $(MAKE) install DESTDIR=$(PREFIX)
	for f in $(PREFIX)/usr/bin/* $(PREFIX)/usr/lib/*; do \
		echo "Stripping $$f"; $(STRIP) $$f &>/dev/null; done; true
	(cd $(PREFIX) && find . -not -type d) >.files
	cp -R -t $(STAGEDIR) $(PREFIX)/*
	rm -R $(PREFIX)
	while read f; do \
		$(TARGETINST) -d $(STAGEDIR)/$$f /$$f; \
	done <.files
	#touch .installed

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
