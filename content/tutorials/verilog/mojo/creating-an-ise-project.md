+++
title = "Creating an ISE Project"
weight = 2
+++

This tutorial is to get you familiar with how to create a project and the very basics of Verilog.

Before starting this tutorial, make sure you have installed [Alchitry Labs](@/alchitry-labs.md) and [ISE](https://alchitry.com/pages/installing-ise).

First you will need to download the base project available [here](https://github.com/embmicro/mojo-base-project/archive/master.zip), or check it out from [GitHub](https://github.com/embmicro/mojo-base-project).

Note that this is the starter code for any project. It is not specific to this tutorial and without modifications does **nothing**. You must follow the tutorial and make the necessary modifications to the code to get it to work.

Extract that file to where you want to keep your projects. It is a good starting point for any project created for the Mojo.

The file structure is as follows.

- Mojo-Base
    - ipcore_dir - _where IP cores will go that you generate_
    - iseconfig - _used by ISE_
    - src - _where you put all the files you write_
    - syn - _the working directory for ISE_
    - Mojo-Base.xise - _the ISE project file_

Open up ISE (ISE Design Tools->Project Navigator on Windows) and click File->Open Project and select Mojo-Base.xise

It should now look something like this.

![ise_open.jpg](https://cdn.alchitry.com/verilog/mojo/ise_open.jpg)

For your very first project, we are simply going to wire up the reset button to one of the LEDs on the board. We will make it so the LED will turn on when you push the button. 

Go ahead and double click on the left side where it says **mojo-top (mojo-top.v)** under the hierarchy panel. The file should open and you should see the following code.

```verilog
module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  assign led = 8'b0;
 
endmodule
```

Let me explain what each part of the code does.

### Port declarations

```verilog
module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
  );
```

This is the **port declaration**. This tells what signals are going in and out of the module. Remember we are designing circuits, not writing code, so it is good to think of each module as a block that has some inputs and generates some outputs. For now we only are interested in the **rst_n** input and the **led** outputs.

In Verilog there are two data types, **wire** and **reg**. The default in a port declaration is a wire. For now, we will only be working with wires and regs will be covered in the next tutorial. 

You may have noticed this line.

```verilog,linenos,linenostart=9
output[7:0] led,
```

This is not a single output but actually 8! You can create an array of wires (or regs)  by using those brackets. What **[7:0]** actually means is that led will be an array of eight wires that have an index from 7 down to 0, inclusive. 

It is possible to do [8:1] or [0:7], but unless you have a **very very** good reason for doing that then you should stick to the convention. Mixing what you used as a base index and the order can create major headaches.

### Declaring a wire

This brings us to the first line after the port declaration. 

```verilog,linenos,linenostart=23
wire rst = ~rst_n;
```

In this line we are declaring a new wire called rst and assigning it a value.

It is a common convention to name signals that are active low (meaning a 0 is active) by appending **_n** to the end of their name. Following that convention, **rst_n** is active low, but we want an active high signal. To make **rst** an active high version of **rst_n** we can just invert **rst_n**. The **~** operator is the **not** operator. 

In this case, we are declaring a one bit wire. However, you can declare an array of wires (sometimes also called an n-bit wire where n is the width of the array) with the following line.

```
wire [9:0] array;
```

In this case, we would now have a 10-bit wire called array. Notice here I did not assign it a value.

### Assigning a value

There are many times where you want to assign a value to a wire that is already declared somewhere else. In this case, you can use the **assign** keyword.

```verilog,linenos,linenostart=26
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;
 
assign led = 8'b0;
```

Now is a good time to introduce constants in Verilog. A constant looks something like **8'hD5**, **5'd61**, or **4'b0101**. In these three cases, you can tell how many bits wide each constant is by the first number. The first one is 8 bits, the second 5, and the third 4. This is important because you usually want the constant's width to match the signal you are assigning it to. 

The second part of the constant is the base for the number. A **h** means the number is in hex, a **d** means it's decimal, and **b** means it's binary. The rest of the constant is the actual value.

Now you may be looking at the assign statements and thinking "what the *&$(* kind of value is z?" Well be confused no more, 0 and 1 are not the only values a wire can have! They can actually have one of four values, **0**, **1**, **Z**, and **X**. Z means that the wire is high-impedance, or disconnected. X means that we don't care about the value, or the value is unknown (when you do simulations).

In this case, since we are not using the spi signals we disconnect them because driving them incorrectly could damage the microcontroller. 

Now, let's look at the last line. This is the one we care about. Right now we are just assigning led to be all 0s. That means all the LEDs will always be off! What fun is that? **Let's make a small modification to that line.**

```verilog,linenos,linenostart=30
assign led[6:0] = 7'b0;
assign led[7] = rst;
```

Ok, so what is going on here? The assign is now modified to assign only the first 7 bits of **led** to 0. You can use the bracket notation to select a sub-part of your arrays.

That leaves us free to assign the last bit to whatever we want! That's where the second line comes in. For this simple example, we are going to assign it to **rst**. That will _connect_ the wire **led[7]** to **rst**.

That concludes the modifications we are going to make so go ahead and save the file!

### Creating a bin file

It is now time to take our project and create a bin file that we can load onto the Mojo. To do this, make sure that **mojo_top (mojo_top.v)** is selected under hierarchy. Underneath that you should see a panel labeled **Processes: mojo_top**. In that panel, double click on **Generate Programming File**. You should see a spinning thing start on **Synthesize** and move through the different stages.

![ise_build.jpg](https://cdn.alchitry.com/verilog/mojo/ise_build.jpg)

You will get warnings with this design. They are shown by giving a little ! in a yellow triangle. This is normal and if you double click on **Design Summary/Reports** in the **Processes** panel you should then see a summary of the build. In the top right, you should see **26 Warnings**. Click on that. If you scroll through the warnings you will notice that they are all caused by inputs and outputs in our design not being used. Since that was intentional we can ignore these.

If you didn't get any errors and the **Generate Programming File** stage completed it is time to fire up Mojo Loader to load the bin file!

### Loading the bin file

Once you open up Mojo Loader, select the serial port that the Mojo is connected to. For Windows this should be somethine like **COM2**. In Linux this will probably be **/dev/ttyACM0**, or something similar. It may take a few seconds to recognize the serial port so try opening the dropdown again if you don't see the port listed.

Then click **Open Bin File** and navigate to the **syn** folder in the project folder. In there you should see a **mojo_top.bin** file to select.

![mojo_loader.jpg](https://cdn.alchitry.com/verilog/mojo/mojo_loader.jpg)

Click load and your design will begin to transfer to the Mojo!

If it doesn't work, make sure you have the correct port selected and the board is plugged in.

Once it has transferred, try pressing the reset button. When you push the button the LED closest to the button should light up.

Congratulations, you've completed your first project!