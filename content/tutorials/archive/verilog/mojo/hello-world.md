+++
title = "Hello World!"
weight = 10
aliases = ["tutorials/verilog/mojo/hello-world.md"]
+++

**The serial interface has changed on April 10, 2015. If you are having trouble, make sure you have the** [latest firmware](@/tutorials/archive/mojo/update-the-mojo.md) **and Mojo Base Project!**

One of the cool features of the Mojo is that there is a microcontroller on-board that is used to configure the FPGA. However, once the FPGA is configured, the microcontroller is free to help out the FPGA! There are two main functions you can use the microcontroller for without modifying the code yourself. The first is an analog to digital convert and the other, which we are covering here, is a USB to serial converter.

This allows you to use the USB port on the Mojo to send data to your computer. The protocol used to send data isn't too complicated at it's core, but luckily for you we already wrote that part of the design for you! 

If you grab a copy of the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip), all the source for this is included. Make sure you download a fresh copy for this tutorial.

### AVR Interface

The main module you need to worry about is the **avr_interface** module. **AVR** is the type of microcontroller on the Mojo. This module is the only one you need to directly interface with. 

As you've probably noticed in other tutorials, out **mojo_top** module had a lot of extra inputs and outputs that weren't being used. Those are all used to interface with the AVR and should be connected to the **avr_interface** module.

```verilog
module avr_interface #(
  parameter CLK_RATE = 50000000,
  parameter SERIAL_BAUD_RATE = 500000
)(
  input clk,
  input rst,
 
  // cclk, or configuration clock is used when the FPGA is begin configured.
  // The AVR will hold cclk high when it has finished initializing.
  // It is important not to drive the lines connecting to the AVR
  // until cclk is high for a short period of time to avoid contention.
  input cclk,
 
  // AVR SPI Signals
  output spi_miso,
  input spi_mosi,
  input spi_sck,
  input spi_ss,
  output [3:0] spi_channel,
 
  // AVR Serial Signals
  output tx,
  input rx,
 
  // ADC Interface Signals
  input [3:0] channel,
  output new_sample,
  output [9:0] sample,
  output [3:0] sample_channel,
 
  // Serial TX User Interface
  input [7:0] tx_data,
  input new_tx_data,
  output tx_busy,
  input tx_block,
 
  // Serial Rx User Interface
  output [7:0] rx_data,
  output new_rx_data
);
```

Here is the port declaration of the module.  Many of the signals are named the same as the top level ports. The few exceptions are **tx** which connects to **avr_rx**, **rx** which connects to **avr_tx**, and **tx_block** which connects to **avr_rx_busy**. 

For now forget about the **channel** and **sample** signals, they are used to interface with the ADC and will be covered in another tutorial.

The signals that are important right now are **tx_data**, **new_tx_data**, **tx_busy**, **rx_data**, **new_rx_data**.

**tx_data** is the data (one byte) that you want to send over the virtual serial port. When you have a new byte you want to send, you need to check **tx_busy** to make sure the module is not busy in anyway. The busy flag can be set for a number of reasons which include, the module is currently sending a byte, **cclk** has not signaled the AVR is ready for data, or the AVR can't accept new data because it's buffer is full.

If the **tx_busy** flag is not set, you can set **new_tx_data** high for one clock cycle to indicate you want the byte present on **tx_data** to be sent. 

To make this clearer, we will implement the classic _Hello World!_ example.

### ROMs

Since we want to send the string _Hello World!_ through the serial port we need to store it somewhere that is easy to access. This is where a **ROM** (**R**ead **O**nly **M**emory) comes in handy.

Here is the ROM we will use. Create a new file named **message_rom.v** and add the following code.

```verilog,short
module message_rom (
    input clk,
    input [3:0] addr,
    output [7:0] data
  );
 
  wire [7:0] rom_data [13:0];
 
  assign rom_data[0] = "H";
  assign rom_data[1] = "e";
  assign rom_data[2] = "l";
  assign rom_data[3] = "l";
  assign rom_data[4] = "o";
  assign rom_data[5] = " ";
  assign rom_data[6] = "W";
  assign rom_data[7] = "o";
  assign rom_data[8] = "r";
  assign rom_data[9] = "l";
  assign rom_data[10] = "d";
  assign rom_data[11] = "!";
  assign rom_data[12] = "\n";
  assign rom_data[13] = "\r";
 
  reg [7:0] data_d, data_q;
 
  assign data = data_q;
 
  always @(*) begin
    if (addr > 4'd13)
      data_d = " ";
    else
      data_d = rom_data[addr];
  end
 
  always @(posedge clk) begin
    data_q <= data_d;
  end
 
endmodule
```

A ROM generally just consists of a few ports, in our case three. The way a ROM works is you specify an address, **addr**, and on the next clock cycle the corresponding data appears at it's output port, **data**.

```verilog,linenos,linenostart=7
wire [7:0] rom_data [13:0];
```

This line is worth mentioning because it is the first time we needed a 2D array. For whatever reason, in Verilog when you want a multi-dimensional array, you specify the extra dimensions after the name of your array.

A 3D array could look like this.

```verilog,linenos,linenostart=7
wire [7:0] rom_data [13:0][7:0];
```

One thing to note, you aren't allowed to use multi-dimensional arrays in port declarations.

To address into our array of data we use the 4 bit wide value from **addr,** which can have a value from 0-15. However, our array only has indexes up to 13! To compensate for this we use the if statement to provide a default value for the out-of-bounds case.

### State Machines

A state machine is a very useful technique when you are working with FPGAs. Most designs will have many state machines in them. You could even classify a processor as a state machine in the broad use of the term.

So what is a state machine? For the FPGA, it's basically a circuit that has various states and it will behave differently depending on the state it's in. Certain sets of input may cause the state to change.

The text-book example is a traffic light. The light has a few states, red, yellow, green, and it will transition between these states when certain events happen like a car waiting for a green, or a certain amount of time has elapsed.

In our example, our state machine is very simple and it has only two states, **IDLE** and **PRINT_MESSAGE**. As the names suggest, the **IDLE** state just waits for a signal to transition to the **PRINT_MESSAGE** state. The **PRINT_MESSAGE** state will print out our _Hello World!_ message then return to the **IDLE** state.

```verilog,linenos,short
module message_printer (
    input clk,
    input rst,
    output [7:0] tx_data,
    output reg new_tx_data,
    input tx_busy,
    input [7:0] rx_data,
    input new_rx_data
  );
 
  localparam STATE_SIZE = 1;
  localparam IDLE = 0,
    PRINT_MESSAGE = 1;
 
  localparam MESSAGE_LEN = 14;
 
  reg [STATE_SIZE-1:0] state_d, state_q;
 
  reg [3:0] addr_d, addr_q;
 
  message_rom message_rom (
  .clk(clk),
  .addr(addr_q),
  .data(tx_data)
  );
 
  always @(*) begin
    state_d = state_q; // default values
    addr_d = addr_q;   // needed to prevent latches
    new_tx_data = 1'b0;
 
    case (state_q)
      IDLE: begin
        addr_d = 4'd0;
        if (new_rx_data && rx_data == "h")
          state_d = PRINT_MESSAGE;
      end
      PRINT_MESSAGE: begin
        if (!tx_busy) begin
          new_tx_data = 1'b1;
          addr_d = addr_q + 1'b1;
          if (addr_q == MESSAGE_LEN-1)
            state_d = IDLE;
        end
      end
      default: state_d = IDLE;
    endcase
  end
 
  always @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_d;
    end
 
    addr_q <= addr_d;
  end
 
endmodule
```

Add a new file named **message_printer.v** and add this code.

It is good practice to use **localparams** to declare the states in your state machine. That makes it not only easier to read, but a lot easier to add or remove states.

For this example, I decided it would be a good idea to wait for an **_h_** before printing _Hello World!_. Once an **_h_** is detected, the state changes to **PRINT_MESSAGE**. It then uses **addr_d**/**_q** to increment through the ROM sending each character.

One important thing to notice is the first three lines in the combinational always block. It's important to always give **regs** a value. If it is possible to run through the always block without assigning a value to every **reg** you can end up with something known as a **latch**. Without going into detail, latches are bad! They can make things behave very unpredictably when actually loaded on the FPGA (although you may not notice it in simulation)! ISE will throw warnings when it detects a latch so you should always check for those.

The easy solution is to just assign every **reg** a default value in the beginning of your always block.

### Case Statements

To implement state machines, you usually use a **case** statement. If you've ever programmed in C/C++ or Java this should be pretty familiar (it's basically a switch statement).

The first line

```verilog,linenos,linenostart=32
case (state_q)
```

sets up the case statement and says we are going to be looking at the value of **state_q**.

Each of the following blocks of code is only used in the case that **state_q** matches the value stated. So the first part is used when **state_q** is **IDLE** and the second is used when it is **PRINT_MESSAGE**. 

It is important to always have a **default** entry in your case statement that will bring you back to a known state. You may be thinking that you don't need one since it should be impossible to have any other state than the two we defined. You may be surprised to find out that this is not the case. If the state is encoded with just 1 bit then it is true that it is impossible to be anything else because 1 bit only has 2 values. However, when your design gets synthesized the tools will generally optimize the encoding used by your states and it may make **state_q** actually 2 bits! You may be thinking that this shouldn't change anything because no where in your design do you specify a change to an unknown state. There is however, a small chance that the value a register holds gets flipped randomly putting you in an unknown state! This can be caused by a number of events including radiation. Providing a default case makes sure that if this happens your design will still have predictable behavior. 

### The Top Module

Here is the code for **mojo_top.v**

```verilog,short
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
 
  assign led = 8'b0;
 
  wire [7:0] tx_data;
  wire new_tx_data;
  wire tx_busy;
  wire [7:0] rx_data;
  wire new_rx_data;
 
  avr_interface avr_interface (
    .clk(clk),
    .rst(rst),
    .cclk(cclk),
    .spi_miso(spi_miso),
    .spi_mosi(spi_mosi),
    .spi_sck(spi_sck),
    .spi_ss(spi_ss),
    .spi_channel(spi_channel),
    .tx(avr_rx), // FPGA tx goes to AVR rx
    .rx(avr_tx),
    .channel(4'd15), // invalid channel disables the ADC
    .new_sample(),
    .sample(),
    .sample_channel(),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .tx_block(avr_rx_busy),
    .rx_data(rx_data),
    .new_rx_data(new_rx_data)
  );
 
  message_printer helloWorldPrinter (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .rx_data(rx_data),
    .new_rx_data(new_rx_data)
  );
 
endmodule
```

Here we just instantiate the two modules. Notice the **assign** statements that used to be at the top were removed since we are now using those ports.

You should now be able to synthesize your project and load it onto your Mojo. I tested this using **minicom** on Linux, but any serial terminal program should work. It doesn't matter the parameters you specify for the serial port as they are ignored. 

When you send **_h_** over the serial port the Mojo should respond with _Hello World!_.