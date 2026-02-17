+++
title = "Setting up the Arduino IDE"
weight = 0
aliases = ["tutorials/mojo/arduino-setup.md"]
+++

All new Mojo's are shipping with a new bootloader that is Arduino compatible. That means that if you want to modify the code that ships on the Mojo, you can from the comfort of the Arduino IDE.

If your Mojo shipped to you in a small custom printed box (shipping since Jan 2014), it is already Arduino compatible. However, if you ordered a Mojo V3 before or have a Mojo V2, you can visit the [Flashing the Bootloader](@/tutorials/archive/mojo/mojo-bootloader.md) page after installing the Arduino IDE for instructions on upgrading.

Please note that if you have a Mojo V2, you need to use the Arduino IDE version 1.6.5.

Note, you do not need to use the Arduino IDE or code at all to use the Mojo. This is only for people who want to program **BOTH** the FPGA and the microcontroller. If you only want to program the FPGA jump into the [FPGA tutorials](@/tutorials/_index.md).

## Arduino IDE 1.6.5

Arduino has recently released version 1.6.5 of their IDE which makes third part extensions much easier. If you are using version 1.6.5, download the [Arduino Mojo Plugin](https://cdn.embeddedmicro.com/arduino/arduino-mojo-plugin.zip).

Extract the zip into your sketchbook (typically **C:\Users\YOURNAME\Arduino** for Windows or **/home/YOURNAME/Arduino** for Linux).

Under **Arduino/hardware/embeddedmicro/avr/** you should see a handful of folders and the **boards.txt** and **platform.txt** files.

You can now fire up the IDE and jump down to the **Getting Started** section of this tutorial.

## Arduino IDE 1.0.5

### Installing the Arduino IDE

The first step of this process is to to just download and install the Arduino IDE!

Head over to the [Arduino website](http://arduino.cc/en/Main/Software) and download version **1.0.5** of the IDE.

If you are running Ubuntu you can install the IDE directly from the Ubuntu Software Center, or by entering the following command in the terminal.

```bash
sudo apt-get install arduino
```

### Adding the Mojo

Once the IDE is installed, you will need to edit some files to make it work with the Mojo.

Download all the files you will need [here](https://cdn.embeddedmicro.com/arduino/arduinoMod.zip) and extract the zip somewhere you can find it.

You now need to find where the files for the Arduino IDE live.

If you are using **Windows** and you installed it via their installer, the files most likely live at **C:\Program Files (x86)\Arduino**.

If you are using **Ubuntu** and you installed it via the Software Center or the terminal, the files most likely live at **/usr/share/arduino**. You will need to edit some files here so you will need to open a file browser with root privileges. Press **alt+F2** and type in **gksu nautilus**. Hit enter and type in your password. **Be careful because in this file browser you will be able to delete system files!**

Once you find the Arduino files, open the **hardware** folder, then open the **arduino** folder.

You should now see the **boards.txt** file. Use the **boards.txt** file from the zip you downloaded earlier to replace the Arduino one.

The new file contains the declaration of the Mojo telling the Arduino IDE how to handle it.

Now simply copy all the files in the **arduinoMod.zip** to the **hardware/arduino** folder. You should merge the various directories replacing only the files that are included in the modified files.

## Getting Started

To get started you need to download our base sketch that does the loading. To do this checkout our [GitHub page](https://github.com/embmicro/mojo-arduino) or download the zip directly from [here](https://github.com/embmicro/mojo-arduino/archive/master.zip).

Create a folder name **mojo_loader** in your sketchbook and extract the files into that folder. Arduino requires that the folder name match the main .ino file (in this case **mojo_loader.ino**). 

Make sure that the Mojo is selected by going to **Tools/Boards** and selecting **Mojo V3**. Also make sure you select the correct serial port in **Tools/Serial Port** before trying to program the Mojo.

In the main **mojo_loader** file there are only three functions you should have to change for most projects. They are **initPostLoad()**, **disablePostLoad()**, and **userLoop()**.

**initPostLoad()** is called before **userLoop()** and should be used to do any setup your code needs.

**disablePostLoad()** is called before the Mojo enters loading mode and is used to **undo** anything you did in **initPostLoad()**. If you fail to properly undo your setup, the loading code may not function properly.

**userLoop()** is where the bulk of your code should live. This acts much the same way as the basic **loop()** function provided by Arduino, but is only called when the FPGA has already been loaded. You should try to keep the loop duration fairly short so that the Mojo Loader will be able to get the Mojo into loading mode in a reasonable amount of time.

### Notes About Our Code

If you look through our code you may notice we don't use some the Arduino libraries for things. In some cases it didn't make sense to use the libraries because we could do things more efficiently by accessing the registers directly. 

The most noticeable example of this is we don't use **digitalWrite()**. Instead, we have use **SET()** which is a macro defined in **hardware.h**. **digitalWrite()** is actually fairly slow due to the fact that it disables and re-enables interrupts every time it is called. This was done so that if you are calling it from inside interrupts, it will work as expected. However, we never do that so the overhead is for nothing. **SET()** is as basic as you can get for setting pins, but it works basically the same way that **digitalWrite()** does.

We also decided not to use the libraries for **Serial1** and the **ADC**. This is because we did some fancy stuff with interrupts and ring buffers to allow the FPGA to have fast access to the USB port and the ADC. 

If you don't want to use these optimizations, feel free to remove this code and replace it with the Arduino libraries.