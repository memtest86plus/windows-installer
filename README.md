# Memtest86+ Windows USB Installer
Here you can find the source files for the NSIS-based Windows USB Installer for Memtest86+.

To build the Installer, you need to install NSIS 3.08 or later, and copy/rename the following binary files in the same folder:
* memtest32.bin (from ```build32/memtest.bin```) for Legacy BIOS/CSM (via Syslinux)
* memtest32.efi (from ```build32/memtest.efi```) for UEFI 32 bits 
* memtest64.efi (from ```build64/memtest.efi```) for UEFI 64 bits

You can then use ```Compile NSIS Script``` to generate the Windows Executable.

---
Credits, Resources, and Tools used:

* Memtest86+ v6 ©2004-2022 Contributors https://memtest.org (unmodified binary used)

* Memtest 86+ USB Installer (v6+) by Sam Demeulemeester, adapted from original 
  Memtest 86+ USB Installer (v5 and previous) created by Lance from Pendrivelinux

* Syslinux 6.03 ©1994-2014 H. Peter Anvin https://wiki.syslinux.org/ (unmodified binary used)

* NSIS Installer 3.08 ©1995-2021 Contributors https://nsis.sourceforge.io/
