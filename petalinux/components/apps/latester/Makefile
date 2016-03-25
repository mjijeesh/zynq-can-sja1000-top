ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

# directory where this file is located
d := $(dir $(lastword $(MAKEFILE_LIST)))
d := $(realpath $(d))

include apps.common.mk
srcdir := $(PROOT)/../can-benchmark/latester
bindir := $(d)/_compiled

all: install

build:
	$(MAKE) -C $(srcdir) MAKERULES_DIR=$(d)
#	$(CC) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS)

clean:
	$(MAKE) -C $(srcdir) MAKERULES_DIR=$(d) clean

.PHONY: all build install

install: build
	$(TARGETINST) -d $(bindir)/bin/latester /usr/bin/latester
	$(TARGETINST) -d $(bindir)/bin/vcanbench /usr/bin/vcanbench

help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"
