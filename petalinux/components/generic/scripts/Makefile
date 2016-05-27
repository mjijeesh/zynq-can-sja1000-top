ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

include generic.common.mk

FILES := caninit lsrt upbit

.PHONY: all build pre-build post-build install pre-install post-install config clean
all: build

build:

pre-build:

post-build:

install:
	for f in $(FILES); do $(TARGETINST) -d /$$f ./$$f; done

pre-install:

post-install:

config:

clean:

