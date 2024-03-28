+++
title = "Updating the Mojo"
weight = 2
+++

Mojos shipped in 2014 or later have the Arduino compatible bootloader. If your Mojo does not have the Arduino compatible bootloader, we recommend upgrading it. Please visit [this page for more instructions](@/tutorials/mojo/mojo-bootloader.md).

On the Mojo there is a microcontroller that provides most of the core functionality. As we improve the firmware for the microcontroller by fixing bugs and adding new features, you can update the Mojo by following this tutorial. The microcontroller has a USB bootloader so it is easy to update yourself.

## Mojo IDE

If you are using the [Alchitry Labs](@/alchitry-labs.md), simply click **Tools->Flash Firmware...** to flash the latest firmware.

## Manual Update

First you will need to download the latest firmware. The latest firmware was posted on **March 2, 2016**.

- [Mojo V3 Firmware (ATmega32U4)](http://cdn.embeddedmicro.com/mojo-loader/Mojo-v3-Loader-1.2.6.hex)
- [Mojo V2 Firmware (ATmega16U4)](http://cdn.embeddedmicro.com/mojo-loader/Mojo-v2-Loader-1.2.6.hex)

The latest update includes some patches to the serial interface to the FPGA which requires you to use the updated [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip). These changes ensure no bytes are dropped.

## Arduino Compatible Mojo Instructions

The easiest way to update the firmware when an Arduino compatible Mojo is to simply setup the Arduino IDE and grab the latest code from the GIT repository. Instructions for doing this can be found on the [Arduino setup page](@/tutorials/mojo/arduino-setup.md).

However, if you want to just flash the hex without installing the Arduino IDE and applying the modifications, you can use **avrdude** to program it.

### Ubuntu

It's really easy to update using Linux. Simply install **avrdude** by typing the following.

```bash
sudo apt-get install avrdude
```

Then navigate to the folder with the hex file and run avrdude. **Before** you run avrdude, make sure you get the Mojo in bootloader mode by temporarily shorting the pins shown at the bottom of the page.

```bash
avrdude -P /dev/ttyACM0 -c avr109 -p m32u4 -U flash:w:Mojo-v3-Loader-1.2.5.hex
```

Make sure to change **/dev/ttyACM0** to the correct port for the Mojo!

The hex should now be loaded on the Mojo!

### Windows

Head over to SourceForge and download [WinAVR](http://sourceforge.net/projects/winavr/).

After it's installed click Start->Run and type **cmd** to open a command prompt.

Navigate to where the hex file is and enter the following. **Before** you run avrdude, make sure you get the Mojo in bootloader mode by temporarily shorting the pins shown at the bottom of the page.

```bash
avrdude -P COM4 -c avr109 -p m32u4 -U flash:w:Mojo-v3-Loader-1.2.5.hex
```

Make sure to change **COM4** to the port the Mojo is connected to. Note that this port may change after you put the Mojo is bootloader mode. It will only stay in bootloader mode for about 15-20 seconds and it will show up in the Device Manger as **Mojo V3 bootloader**. If you miss the bootloader window, simply short the pins again to re-enter it.

 The hex should noe be loaded on the Mojo!

## Legacy Mojo Instructions

### Ubuntu

It is pretty easy to update the Mojo in Ubuntu using **dfu-programmer**.

First you need to install dfu-programmer. Open a terminal and enter

```bash
sudo apt-get install dfu-programmer
```

You also need to download the following file and place it in **/etc/udev/rules.d**. You will need superuser privileges to do this.

[Mojo USB Rules](http://cdn.embeddedmicro.com/mojo/99-mojo.rules)

Once you add the rules file, you will need to unplug and re-plug the Mojo to have it take effect. 

Jump down to **Entering Bootloader Mode** for instructions on how to get the Mojo into bootloader mode.

You can now update the Mojo with the following commands.

```bash
dfu-programmer atmega32u4 erasedfu-programmer atmega32u4 flash /path/to/hex/file/Mojo-Loader-1.2.5.hexdfu-programmer atmega32u4 start
```

Note that if you have a Mojo V2 the board probably has an ATmega16U4 microcontroller and not an ATmega32U4. In that case, replace **atmega32u4** with **atmega16u4** in the above commands.

The firmware is now updated.

### Windows

To update the Mojo in Windows you will need to download FLIP.

[FLIP Download Page](http://www.atmel.com/tools/FLIP.aspx)

There are two flavors of FLIP, one with a Java Runtime included and one without. Either will work as long as you have Java installed on your computer. If you are unsure if you have Java or not, download the one with the Runtime included.

Once you've installed FLIP, jump down to **Entering Bootloader Mode** for instructions on how to get the Mojo into bootloader mode.

Windows may or may not find the driver for your Mojo. If it doesn't, open the Device Manager. It should look similar to below.

![bootloader-no-driver.png](https://cdn.alchitry.com/mojo/bootloader-no-driver.png)

Right click on the **ATm32U4DFU** or **ATm16U4DFU**, depending on your Mojo, and click **Update Driver Software...** 

Then choose **Browse my computer for driver software** and fill in the path to where you installed FLIP. Select the sub-folder **usb**.

![bootloader-driver-path.png](https://cdn.alchitry.com/mojo/bootloader-driver-path.png)

Click **Next** and install the driver.

Once the driver is installed, launch FLIP.

Click on the chip icon in the upper left corner and choose the microcontroller your Mojo has. If you have a Mojo V2 chances are you have an ATmega16U4, although some have ATmega32U4's. If you have a Mojo V3 you have an ATmega32U4.

Click on the icon of the USB cable and choose **USB** then **Open**.

Next, click on the red book that has the red arrow pointing into it. When you hover over it with your mouse it should say **Load HEX File**. Select the **Mojo-Loader-1.2.hex** file you downloaded.

![bootloader-load-hex.png](https://cdn.alchitry.com/mojo/bootloader-load-hex.png)

Finally click on **Run**. Once that finishes click **Start Application**. The firmware is now updated!

## Entering Bootloader Mode

To program the microcontroller you need to get it into bootloader mode.

First plug the Mojo into your computer. With the Mojo still powered on, flip it over so you see the six little pads above the last O in Mojo. You need to momentarily connect the two leftmost pads. A jumper wire works well for this. Connecting these pads resets the microcontroller and on restart it will enter the bootloader.

The image below shows the pins to connect.

![mojo-v3-bootloader.jpg](https://cdn.alchitry.com/mojo/mojo-v3-bootloader.jpg)

Once you tap those together it should be in bootloader mode. Jump back to your operating system's section.