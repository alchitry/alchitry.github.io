+++
title = "Flashing the Bootloader"
weight = 1
aliases = ["tutorials/mojo/mojo-bootloader.md"]
+++

This tutorial will walk you through how to upgrade your Mojo's bootloader to the new Arduino compatible bootloader. To do this you will need an ISP programmer. We recommend the **AVRISP mkII**, but any ISP programmer should work. You can even use an Arduino to program the Mojo if you have one.

Please note that some Mojo V2s have an ATmega32U4 microprocessor instead of the ATmega16U4. If your Mojo V2 has the ATmega32U4 processor, follow these instructions as if you have a Mojo V3. You should also select Mojo V3 as the board when using the Arduino IDE.

Before you can program the bootloader you must first install the Arduino IDE as outlined in the [Setting up the Arduino IDE](@/tutorials/archive/mojo/arduino-setup.md) tutorial.

### Connecting Your Programmer

After the Arduino IDE is properly setup, you need to connect your programmer to the Mojo.

The ISP pins on the Mojo are broken out on 6 pads on the back of the board. Take a look at the following image to see how to connect your programmer.

![mojo-v3-prog-pins.jpg](https://cdn.alchitry.com/mojo/mojo-v3-prog-pins.jpg)

We recommend soldering wires to these pads to temporarily connect your programmer. After the bootloader is programmed you can remove the wires.

### Burning the Bootloader

With the programmer connected to your Mojo, fire up the Arduino IDE.

Select your programmer from **Tools/Programmer**.

Make sure the board is set to your board type, **Mojo V3** or **Mojo V2**, in **Tools/Board**. 

Finally, click **Tools/Burn Bootloader** to burn the bootloader.

After the bootloader is burned, you will need to install the drivers for the board if you haven't already. These are installed during the install of the [Mojo IDE](@/alchitry-labs.md).

You then need to flash the FPGA loader program.

You can do this in the Mojo IDE by clicking **Tools->Flash Firmware...** or by using the Arduino IDE as outlined below.

Download the sketch through our [GitHub page](https://github.com/embmicro/mojo-arduino) or by downloading the zip directly from [here](https://github.com/embmicro/mojo-arduino/archive/master.zip).

Open the sketch in the Arduino IDE and load the code onto the Mojo by clicking the right arrow on the top bar. Make sure you have the correct serial port selected in **Tools/Serial Port** first.

You are then all set! You can either use the board as is, or make some edits to the code!