+++
title = "External IO"
weight = 6
+++

So far the tutorials have only used the signals defined already for you in the [base project](https://github.com/embmicro/mojo-base-project/archive/master.zip). This tutorial a very short example on how you can define your own inputs and outputs in your top level module and have them connect to the IO headers on the Mojo.

### Revisiting the button

The project for this tutorial will be very similar to the [Creating a Project](@/tutorials/verilog/mojo/creating-an-ise-project.md) tutorial with one difference. Instead of using the reset button to control the LED, we are going to hook up an external button to control the LED.

This project assumes you've connected a button between **P50** and **V+** (3.3V) on the Mojo (P50 is labeled **50**) and a 10K pulldown resistor from **P50** and **GND**. This way P50 will be low when the button isn't pressed but high when it is.

Like before we will start with the [Mojo base project](https://github.com/embmicro/mojo-base-project/archive/master.zip) so make sure you've downloaded that if you haven't already.

We first need to open up **mojo_top.v** and make two minor changes.

We need to add our button to the module declaration.

```verilog,linenos,linenostart=14
input button
```

This line should come at the end of the list (although order do not really matter). Make sure you put a comma at the end of the previous line as well.

The next change is to wire up our new input to the LED.

```verilog,linenos,linenostart=23
assign led[7:1] = 7'b0;
assign led[0] = button;
```

After these two changes the file should look like this.

```verilog,linenos
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
    input avr_rx_busy, // AVR Rx buffer full
    input button
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  assign led[7:1] = 7'b0;
  assign led[0] = button;
 
endmodule
```

Our module now has a new input named **button** which we wired up to the first LED. None of this should be surprising to you as it is almost exactly the same as the first time this was covered.

### The UCF File

This is where all the good stuff happens.

There seems to be a very big piece of information missing from our above module. Sure we just declared a new input for our design and connected it up to the LED, but how do we know what IO pin that input connects to? This is where the **U**ser **C**onstraints **F**ile (**UCF**) comes in. 

In the **src** folder of the project you will find a file called **mojo.ucf** open that file now.

Take a good look at what's inside. The first few lines are there to tell the tools that the Mojo will have a clock signal running at 50MHz. That is important for the way your design gets layed out in the FPGA because it will need to be able to run at **at-least** that speed. If for some reason the tools can't layout your design in such a way that it can run that fast it will notify you. This will be covered in much more depth later.

The rest of the file is simply there to define what pins our top module (**mojo_top.v**) connect to! We are going to have to add a new line for our button.

```ucf,linenos,linenostart=33
NET "button" LOC = P50 | IOSTANDARD = LVCMOS33;
```

There are three parts to this line. The **NET** part tells the tools which signal you are assigning constraints to. The **LOC** part stands for _location_ and defines the pin on the FPGA you want the signal to be connected to. Finally the **IOSTANDARD** specifies the standard to use. You should always use LVCMOS33 or LVTTL for the Mojo since the pins use 3.3V. For most practical purposes LVTTL and LVCMOS33 won't make a difference with your project. For more information see [this document from Xilinx](http://www.xilinx.com/support/documentation/user_guides/ug381.pdf) (Page 24).

If you look closely at the Mojo you will see a bunch of numbers next to the IO ports. These corrispond to the number you set **LOC** to. In this example I chose to connect the button the pin labled with **50** (top header, left side, bottom row) so the pin is **P50**. 

You can also specify the pins an array should connect to by adding a line for each element and indexing that element with the <> notation. The signal **led** is an example of how this is done.

```ucf,linenos,linenostart=11
NET "led<0>" LOC = P134 | IOSTANDARD = LVCMOS33;
NET "led<1>" LOC = P133 | IOSTANDARD = LVCMOS33;
NET "led<2>" LOC = P132 | IOSTANDARD = LVCMOS33;
NET "led<3>" LOC = P131 | IOSTANDARD = LVCMOS33;
NET "led<4>" LOC = P127 | IOSTANDARD = LVCMOS33;
NET "led<5>" LOC = P126 | IOSTANDARD = LVCMOS33;
NET "led<6>" LOC = P124 | IOSTANDARD = LVCMOS33;
NET "led<7>" LOC = P123 | IOSTANDARD = LVCMOS33;
```

Once you've added that line to the end of the UCF file, save both files and you should be able to generate the bin file to load onto the Mojo. Go ahead and connect a button (make sure it has a pullup resistor) to pin 50 and test out your design. The LED should light up when the pin is high.

The same thing can be done for outputs, you just need to change the direction in the module declaration.