ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

include libs.common.mk

.PHONY: all build install clean help
all: build install
build: .installed

VER := 2.1.6
DIR := talloc-$(VER)
ARCHIVE := $(DIR).tar.gz
URL := https://www.samba.org/ftp/talloc/$(ARCHIVE)
L := libtalloc.so

$(ARCHIVE):
	wget -c $(URL)
.unpacked: $(ARCHIVE)
	tar xzf $(ARCHIVE)
	touch .unpacked

.configured: .unpacked
	cd $(DIR) && python2 ./buildtools/bin/waf configure --prefix=$(STAGEDIR)/usr --cross-compile --cross-answers=../answers.txt --disable-python --hostcc=gcc --disable-rpath --bundled-libraries=NONE
	touch .configured
.built: .configured
	cd $(DIR) && python2 ./buildtools/bin/waf build
	touch .built
.installed: .built
	cd $(DIR) && python2 ./buildtools/bin/waf install
	touch .installed

install: .installed
	for f in $(L).$(VER); do $(TARGETINST) -d $(STAGEDIR)/usr/lib/$$f /usr/lib/$$f; done
	for f in $(L) $(L).2; do $(TARGETINST) -s $(L).$(VER) /usr/lib/$$f; done

clean:
	rm -rf $(DIR) .unpacked .configured .built .installed

help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"
