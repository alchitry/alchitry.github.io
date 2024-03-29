+++
title = "Your First FPGA Project"
weight = 0
+++

This tutorial will walk you through creating your first project and making the onboard LED light up when you press the reset button.

## Creating a New Project

Launch Alchitry Labs. After click through the welcome screen, you should see the following.

![Screenshot_from_2019-03-24_13-40-14.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2019-03-24_13-40-14.png)

Click on **File->New Project**. In the dialog that pops up enter a **Project Name** of **LEDtoButton**. You can leave the default workspace if you want or browse for a different one. This is where all your projects will be stored

Use the drop-down menu to choose the board you are using.

Leave the language set to Lucid and **From Example** set to **Base Project**. This will copy a bare-bones project as the starting point.

It should now look something like this. Note that your workspace will be different.

![Screenshot_from_2019-03-24_13-41-08.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2019-03-24_13-41-08.png)

Click _Create_ to create your project.

Back in the main window, expand the tree on the left to find the top file inside of **Source**. This has the name of **_board__top.luc**. Double click on it to open it in the editor.

![Screenshot_from_2019-03-24_13-43-29.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2019-03-24_13-43-29.png)

The top file contains all the external inputs and outputs of your design. Your future projects can be built out of many modules, but they all must be sub-modules to this top module. This will be covered more in a later tutorial. For now, we will make all our edits to this file.

Conveniently, the default file has all the basic inputs and outputs that are hardwired to the FPGA already declared. This way you can just use them without having to look up what pins they connect to.

Note that if you using the Mojo the top files looks a little difference. You may have noticed the yellow underline under all of the inputs. This is because we aren't using them currently and the IDE is just giving us a warning. The Mojo has an AVR microcontroller on the board that the FPGA can talk to. There are connections defined in the top module that are used for this.

If you hover your cursor over a warning or error, text will show up to let you know what is going on. Also when you attempt to build your project (click the hammer icon) all the warnings and errors will be printed in the console.

## The Contents of a Module

Before we continue on, let's cover the basics of what makes up a module and what a module even is. A module is way to organize your project into smaller pieces broken apart by function. It is very similar to the concept of functions when programming where you break down your program into smaller more manageable pieces. Modules are also nice because they can be reused in multiple parts of your design.

### Module Declaration

The first part of any module is the **module declaration**. This is lines 1 through 14, reproduced below.

```lucid
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx           // USB->Serial output
  ) {
```

It always starts off with the **module** keyword followed by the name of the module. In this case it is _au_top_. It is convention to name your module the same thing as the file name.

After the module name comes an optional **parameter declaration**, this isn't used in our module and it will be covered in a later tutorial.

After that is the **port declaration**. This is where you specify all the **inputs**, **outputs**, and **inouts** of your module. An **inout** is a bi-directional port and will also covered in a later tutorial.

Most of the ports in this module are single bit signals. However, the outputs _led_ and _spi_channel,_ on the Mojo, are a multi-bit signals. _led_ consists of 8 bits and _spi_channel_ is 4 bits. This is declared by the \[8] and \[4] after the signal's names, respectively.

The reason _led_ is 8 bits wide, is because the board has 8 LEDs on it! Each bit of the signal connects to one of the LEDs on the board.

We only care about two of these ports for our project, _led_ and _rst_n_. As you may have guessed, _rst_n_ connects to the reset button. The __n_ part of it's name is because the signal is active low (as stated in the comment). This means that the value is typically 1 (high), but when the button is pressed (active) it is 0 (low).

### The Always Block

There is some stuff before the always block, but we will get back to that later (it will make more sense then). So for now, just ignore it.

Always blocks are where all the magic happens. It is where you can perform computation and read/write signals. The always block gets its name because it is _always_ happening. When the tools see an always block, they need to generate a digital circuit that will replicate the _behavior_ that the block describes. Let's take a look at the always block in our code.

```lucid
always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    led = 8h00;             // turn LEDs off
    usb_tx = usb_rx;        // echo the serial data
  }
```

Notice I said the tools need to replicate the block's _behavior_ and not the block. That is because inside an always block, statements that appear lower in the block have _priority_ over earlier statements. This is similar to programming, and this abstraction makes it so much easier to program complex logic. However, it is important to understand you are not programming and this is just an abstraction. To make this clear take a look at this example.

```lucid
always {
  led = 8h00;             // turn LEDs off
  led = 8hFF;             // turn LEDs on
}
```

What would you expect this always block to do? If you have a programming background, you may be tempted to think that the LEDs would continuously turn on and off. You're not in Kansas anymore Dorthy, this isn't programming and that's not what happens. Remember, there is no processor to run code (that is unless you explicitly make one, like a boss). When the tools see this block, they completely ignore the first line. This is because the second line has higher priory. If you were to synthesize this design, the tools would hard-wire the _led_ signal to _8hFF_ (all 1s).

Back to our design. Were we are assigning four signals a value (six on the Mojo). Note that every output of a module **must** have a value assigned to it at all times. Since we aren't using these outputs, they are assigned with some reasonable defaults. Let's take a quick detour and look at how values are represented in Lucid.

### Representing Values

A value is made of one or more bits. The number of bits a value has is known as its width. There are a few ways to specify a value, some use an implied width while others allow you to explicitly set a width. If you are unfamiliar with binary or hexadecimal please read the [Encodings Tutorial](@/tutorials/background/encodings.md) before continuing.

The first way to represent a value is to just type a decimal number. For example, 9.

Sometimes it’s easier to specify a number with a different radix than 10 (the implied default). Lucid supports three different radix, 10 (decimal), 16 (hexadecimal), and 2 (binary). To specify the radix, prepend d, h, or b to specify decimal, hexadecimal, or binary respectively. For example, hFF has the decimal value 255 and b100 has the decimal value 4. If you don’t append a radix indicator, decimal is assumed.

It is important to remember that all number will be represented as bits in your circuit. When you specify a number this way, the width of the number will be the minimum number of bits required to represent that value for decimal. For binary, it is simply the number of digits and for hexadecimal it is four times the number of digits. For example, the value 7 will be three bits wide (111), _1010_ will be four bits wide, and _hACB_ will be 12 bits wide.

Sometimes you need more control over the exact width of a number. In those cases you can specify the number of bits by prepending the number of bits and radix to the value. For example, _4d2_ will be the value 2 but using 4 bits instead of the minimum 2 (binary value 0010 instead of 10). You must specify the radix when specifying the width to separate the width from the value.

If you specify a width smaller than the minimum number of bits required, the number will drop the most significant bits. When this happens you will get a warning.

### Z and X

When you specify a decimal number, all the bits in your value will be either 0 or 1. However, each bit can actually be one of four values, 0, 1, x, or z. The values of 0 and 1 are fairly self explanatory, it just means the bit is high (1) or low (0). The value of x means **don't care**. It means you want to assign a value, but you really don't care if it is 1 or 0. This is useful for the synthesizer because your circuit may be simpler in one of the cases and it gives the tools the freedom to choose. During simulation, x also means unknown. Z means that the bit is **high-impedance** or tri-stated. This means that it is effectively disconnected. Note that FPGAs can't realize high-impedance signals internally, so the only time you should use z is for outputs of the top module.

Back to our always block, the first two lines connect the input _rst_n_ to the input of the _reset_cond_ module. Modules can be nested which makes it possible to reuse them and helps make your project manageable. This is all covered later in more detail so don't get hung up over this yet. The only important thing to know about these two lines, is that the _rst_n_ signal is active low (0 when the button is pressed, 1 otherwise) while the _rst_ signal is active high.

The next line assigns the _led_ output to all zeros. This turns off all the LEDs.

On the Alchitry boards, the last line connects the serial input pin to the serial output pin effectively echoing anything the FPGA receives over the serial port. We could have also tied this pin to 1 to disable it.

On the Mojo, the last three lines assign the outputs to z. This is because they aren't being used and we shouldn't drive these as they connect directly to the microcontroller on the Mojo (to use these you have to wait for the microcontroller to signal that it is ready first, this is also covered later).

Looking at this always block, we can see there are no redundant assignments (like in our led on/off example). That means these signals will literally be connected to these values.

## Connecting the Button

We are going to modify the module to connect the reset button to the first LED so that when you push the button the LED turns on.

To do this we need to modify line 21, where _led_ is assigned.

```lucid
led = c{7h00, rst};     // connect rst to the first LED
```

The output _led_ is an 8 bit array. That means when you assign it a value you need to provide an 8 bit array. However, the signal _rst_ is a single bit wide. To compensate for this we use the concatenation operator.

To concatenate multiple arrays into one, you can use the concatenation operator, c{ x, y, z }. Here the arrays (or single bit values) x, y, and z will be concatenated to form a larger array.

In our code we are concatenating the constant _7h0_ with _rst_. The constant here is seven zeros. The 7 represents the size, h represents the number base (in this case hexadecimal) and 0 represents the value. Since we just need a bunch of zeros, the number base doesn’t really matter and we could have used _7b0_, or _7d0_, for binary or decimal respectively.

Note that values are zero padded if the specified width is larger than the size required to store the value. For example, _4b11_ would the same as _4b0011_.

If you don’t care about how many bits a values takes up, you don’t have to specify it. The minimum number of bits that will still fit the value will be used. For example, _b1101_ is exactly the same as _4b1101_. If you are using decimal, you can even drop the d so _4d12_ is the same as _d12_ which is the same as just _12_. However, when you are concatenating values, you should always specify a width to make it obvious how big the array will be.

## Building Your Project

Go ahead and click the little hammer icon in the toolbar to build your project. You may need to first specify where you installed the builder.

For the Au, use **Settings->Vivado Location...** and point it to the _Xilinx/Vivado/YEAR.MONTH_ folder.

For the Cu, use **Settings->iCEcube2 Location...** and point it to the _lscc/iCEcube2_ folder. You will also need to use **Settings->iCEcube2 License Location...** to point it to the license file you downloaded when you installed iCEcube2.

For the Mojo, use **Settings->ISE Location...** and point it to the _Xilinx/14.7_ folder.

Once set you should be able to build your project.

As the project builds you should see a bunch of text spit out. Just wait for it to finish building. It should look like this.

![Screenshot_from_2019-03-24_14-09-37.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2019-03-24_14-09-37.png)

The important line here is where it says **Finished building project**. This means that the IDE was able to find a .bin file after. If you ever get a red message telling you the bin file couldn't be found you should scroll up through the build messages for the error that caused it to fail.

## Loading Your Project

With your project built, plug your board into your computer if you haven’t already.

If you are using the Mojo, go to **Settings->Serial Port...** and select the serial port the Mojo is connected to.

The Alchitry boards are detected automatically.

It is time to load your project onto the board. You have two options. The first is the hollow arrow, this will write your configuration directly to the FPGA's RAM. The second is the solid arrow, this will write your configuration to the FLASH memory on the board (as well as the FPGA). If you program to the FPGA's RAM, your configuration will be lost when the board loses power. However, if you program to the FLASH, your configuration will be automatically loaded when the board is powered up.

The Alchitry Cu doesn't support loading directly to the FPGA.

If you program to RAM and then power cycle the board, the last configuration written to FLASH will automatically be loaded. This is helpful when you want to temporarily try out some configuration.

If you want to stop the FPGA from being configured at power up, you can click the eraser icon. This will wipe the FLASH memory and clear the FPGA's current configuration.

Go ahead and click the arrow to program the FPGA.

![Screenshot_from_2019-03-24_14-22-47.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2019-03-24_14-22-47.png)

Now look at your board. You should see the **DONE** LED on. This means that the configuration was loaded successfully to the FPGA.

![ledbutton.jpg](https://cdn.alchitry.com/lucid_v1/mojo/ledbutton.jpg)

Now push the reset button.

![ledbuttonpressed.jpg](https://cdn.alchitry.com/lucid_v1/mojo/ledbuttonpressed.jpg)

 Notice the LED turned on!

## Some Notes on Hardware

When you press the button, how long does it take for the LED to turn on? If this was a processor instead of an FPGA, the processor would be in a loop reading the button state and turning the LED on or off based on that state. The amount of time between pressing it and when the LED turns on would vary depending on what code the processor was executing and how long it is until it gets back to reading the button and turning the LED on. As you add more code to your loop, this time and variation gets bigger.

However, an FPGA is different. With this design (note I said design and not code), the button input is directly connected to the LED output. You can imagine a physical wire bridging the input to the output inside the FPGA. In reality, it's not a wire but a set of switches (multiplexers) that are set to route the signal directly to the output. Well, this is only partially true since the _reset_conditioner_ is there which does some stuff to clean up the reset signal.

Since the signal doesn’t have to wait for a processor to read it, it will travel as fast as possible through the silicon to light the LED. This is almost instant (again, forget about the _reset_conditioner_)! The best part is that if you wire the button the LED then go on to create some crazy design with the rest of the FPGA, the speed of this will not slow down. This is because the circuits will operate independently as they both simply _exist_. It is this parallelism where FPGAs get their real power.

## Duplication

What if we want all the LEDs to turn on and off with the press of the button instead of just one?

Well we could do it using concatenation just like before by replacing line 20 with the following.

```lucid
led = c{rst,rst,rst,rst,rst,rst,rst,rst};
```

However, there is a better way! This is where the array duplication syntax comes in handy. The syntax is _M x{ A }_. Here M is the number of times to duplicate A. That means we can make line 20 look like this.

```lucid
led = 8x{rst};
```

Much cleaner! This does exactly the same thing as before, but requires a lot less typing.

## Array Indexing

There is an alternative way to write the code where we only want one LED to light. This is by assigning the parts of the led array separately.

```lucid
led[7:1] = 7h0;         // turn these LEDs off
led[0] = rst;           // connect rst to led[0]
```

On line 20, the bit selector _\[7:1]_ is used to select the bits 7 through 1 of the led array. These seven bits are set to 0.

On line 21, _\[0]_ is used to select the single bit, 0, and set it to _rst_.

There are two ways to select a group of bits. The first one (and most common) is the one used above where you specify the start and stop bits (inclusive) explicitly. The other way is to specify a start bit and the total number of bits to include above or below the start bit.

Line 20 could be rewritten as any of the following.

```lucid
led[7:1] = 7b0;  // select bits 7-1
led[7-:7] = 7b0; // select 7 bits starting from 7 and going down
led[1+:7] = 7b0; // select 7 bits starting from 1 and going up
```

The benefit of using the start-width syntax is the width is guaranteed to be constant. This means you can use a signal to specify the start index. This will be covered in a later tutorial.

## Always Blocks

Due to the nature of always blocks, you could also write the LED assignment as follows.

```lucid
led = 8b0;              // turn the LEDs off
led[0] = rst;           // connect rst to led[0]
```

Because the second statement has priority over the first, _led\[0]_ will actually NEVER have the value 0! It will be permanently connected to _rst_. Note that the second line only assigns the first bit of _led_. That means that the other 7 bits will still receive their value from the first statement.

This is one of the weird things of working with hardware. The code you write is not run on a processor like it is when you program. Instead, the code you write is interpreted by the tools to figure out what behavior you want. The tools then create a circuit that will match that behavior.

Always blocks are an easy way to describe complex behavior, but the way you describe the behavior and it's actual implementation can vary.

Congratulations! You've finished your first tutorial on Lucid. When you're ready for more click here for the [Synchronous Logic Tutorial](@/tutorials/lucid_v1/mojo/synchronous-logic.md).