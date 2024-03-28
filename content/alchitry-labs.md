+++
title = "Alchitry Labs"
weight = 0
+++

## Version 2.0.x Preview

[Download the V2 preview.](https://alchitry.com/Alchitry-Labs-V2/download.html)

A full rewrite of Alchitry Labs is currently underway. You can download the latest version at the link above.

This is a preview and things are likely to change/break between updates.

V2 supports Windows, Linux, and **Macs**.

On Macs, you can only build for the [Cu](@/boards/cu.md) using the included open-source toolchain. Both Lattice and Xilinx still do not support Macs with their build tools. This means that building for the [Au](@/boards/au.md) is not possible.
## Version 1.2.7

### Download Links

- [Windows Installer](https://cdn.alchitry.com/labs/alchitry-labs-1.2.7-windows.msi)
- [Windows Files](https://cdn.alchitry.com/labs/alchitry-labs-1.2.7-windows.zip)
- [Linux](https://cdn.alchitry.com/labs/alchitry-labs-1.2.7-linux.tgz)

### Alchitry Loader

Alchitry Labs now includes the Alchitry Loader as part of the install to make things simpler. This tool can be used to load .bin files directly to your board from a third-party tool.
### Drivers

Alchitry Labs now supports both the open source library libusb, the FTDI proprietary drivers, and direct COM port drivers (for the Mojo).

This has the advantage of no longer needing to specify a serial port for your board and you no longer need to install any drivers for the Alchitry boards on Windows or Linux!
### Windows

You no longer need to install any drivers manually for Alchitry boards (see the next section for the Mojo). Windows should automatically detect and load the proper drivers for your board.

If you were using a previous version of Alchitry Labs, you can now remove winUSB. To do this, open the Device Manager (with your board plugged in) and scroll down to "Universal Serial Bus devices."

Here you should see two entries for your board. Right click on one of them and choose "Uninstall device."

In the dialog that pops up, make sure "Delete the driver software for this device" is checked and click "Uninstall." Repeat this for the second entry.

Now unplug and replug in your board.
#### Legacy Drivers (COM port)

If you are using a Mojo, you need to install the serial port drivers by running the file named **dpinst-amd64.exe** which can be found where you installed Alchitry Labs or in the Windows files (not the installer).
### Linux

You likely won't have to do anything. The drivers for libusb are generally included with your distribution and things will probably just work.

If you run into permission problems, you can copy the udev rules files from the **driver** folder into **/etc/udev/rules.d/**. These will give access to the boards to the "dialup" group.
### Builders

To build projects for the Au you need to install [Vivado](https://www.xilinx.com/support/download.html) (WebPACK, aka free).

To build projects for the Cu you need to install [iCEcube2](http://www.latticesemi.com/iCEcube2) (bottom of the page).

If you are building with iCEcube2 for the Cu, you will need to point the IDE to your license file for iCEcube2. [You can get a license here.](https://www.latticesemi.com/Support/Licensing/DiamondAndiCEcube2SoftwareLicensing/iceCube2)

You can also use the open source project [IceStorm](http://www.clifford.at/icestorm/) to build for the Cu.

To build for the Mojo you need to install [ISE](https://alchitry.com/pages/installing-ise).