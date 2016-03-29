CAN benchmark FPGA design and software for MicroZed board.

Building
========

1. Build Hardware Description File (system.hdf)

The compiled system.hdf file is itself versioned so if you did not modify
the system configuration, you do not have to build it.

1.1 Recreate the Vivado project

  Run this step only once.
  Make sure you have sourced $VIVADO_INSTALL_DIR/settings.sh.

  $ make system_project

1.2 Build system.hdf

  $ make system/system.hdf

2. Build PetaLinux and applications

  Make sure you have sourced both $VIVADO_INSTALL_DIR/settings.sh
  and $PETALINUX_INSTALL_DIR/settings.sh.

  $ make petalinux_config

  You may then configure PetaLinux or its components.
  Set NFS server path in configuration (TODO: where).
  The rootfs will be rsynced here by petalinux-build.
  You may later change the NFS server IP and path in bootscript.

  $ cd petalinux && petalinux-config


3. Configure TFTP server

4. Configure NFS server

   The server must support NFSv2, otherwise it will not work and
   no sensible error message will be printed.

5. Modify module IP, server IPs and paths in u-boot environment and bootscript

  Set the variables "ipaddr", "serverip" in uEnv.txt
  and "nfsserver", "nfspath" in bootscript.txt.

6. Copy images/linux/{image.ub,top_wrapper.bit,system.dtb,bootscript} into /tftpboot

7. Copy boot files to SD card

  Copy the boot image (petalinux/images/linux/BOOT.IMG),
  u-boot environment (petalinux/uEnv.txt)
  to a FAT32 partition on SD card.
  The internal QSPI flash may be used instead, however make sure
  the jumpers on MicroZed board are set appropriately.

