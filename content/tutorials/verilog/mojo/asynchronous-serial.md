+++
title = "Asynchronous Serial"
weight = 14
+++

Asynchronous serial communication, often shortened to just **serial**, is one of the easiest ways to communicate between two different devices. In it's simplest form, it consists of just two connections. One line for sending data and the other for receiving data. 

There are many variations on the classic serial bus, but this tutorial will cover just the basics. You should be able to communicate with most serial devices including a computer.

### Baud Rate

As the name implies, this protocol is **asynchronous**. All that means is that there is no shared clock. To get around not having a clock, both devices need to agree to the rate that data can be transmitted. The rate that data is sent is known as the **baud rate**. The unit for baud rate is **bits/sec** and this indirectly sets the width of each bit.

In theory, you can use any baud rate that you like. However, to make it easier to setup devices, there are a handful of standard baud rates. In most cases you will be using one of the following rates.

|Baud Rates (bits/sec)|
|---|
|4800|
|9600|
|14400|
|19200|
|28800|
|38400|
|56000|
|57600|
|115200|
|128000|
|153600|
|230400|
|256000|

### Start and Stop Bits

Another side effect of not having a clock is the need for start and stops bits. A serial port typically sends data out in packets of 8 bits, or a byte. Since it is asynchronous, you never know when the other device will send a byte!

To let the receiver know you are going to send a byte, a **start bit** is sent. This is simply a single bit with the value of **0**. 

Similarly, after the byte has been sent out, a **stop bit** is sent. Typically one stop bit is sent, but sometimes two are sent. Stop bits have the value of **1**.

To better understand what goes on, take a look at this example transmission.

![serial.png](https://cdn.alchitry.com/verilog/mojo/serial.png)

This is a transmission of the character **'a'** which has an [ASCII](http://en.wikipedia.org/wiki/ASCII) value of 97, or a binary value of 01100001.

The serial line idles **high**, meaning when nothing is being sent it is held at the value **1**. This is why the start bit is 0, so the line transitions from high to low. This gives an indication that the line is active.

You may have noticed that order of the bits is reversed. That is because the **LSB** (least-significant bit) is typically transmitted first. 

### The Transmitter

If you download the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip), in the source directory you will find a file named **serial_tx.v**. This is the serial transmitter used by the Mojo to communicate with the AVR. 

```verilog,short
module serial_tx #(
    parameter CLK_PER_BIT = 50
  )(
    input clk,
    input rst,
    output tx,
    input block,
    output busy,
    input [7:0] data,
    input new_data
  );
 
  // clog2 is 'ceiling of log base 2' which gives you the number of bits needed to store a value
  parameter CTR_SIZE = $clog2(CLK_PER_BIT);
 
  localparam STATE_SIZE = 2;
  localparam IDLE = 2'd0,
    START_BIT = 2'd1,
    DATA = 2'd2,
    STOP_BIT = 2'd3;
 
  reg [CTR_SIZE-1:0] ctr_d, ctr_q;
  reg [2:0] bit_ctr_d, bit_ctr_q;
  reg [7:0] data_d, data_q;
  reg [STATE_SIZE-1:0] state_d, state_q = IDLE;
  reg tx_d, tx_q;
  reg busy_d, busy_q;
  reg block_d, block_q;
 
  assign tx = tx_q;
  assign busy = busy_q;
 
  always @(*) begin
    block_d = block;
    ctr_d = ctr_q;
    bit_ctr_d = bit_ctr_q;
    data_d = data_q;
    state_d = state_q;
    busy_d = busy_q;
 
    case (state_q)
      IDLE: begin
        if (block_q) begin
          busy_d = 1'b1;
          tx_d = 1'b1;
        end else begin
          busy_d = 1'b0;
          tx_d = 1'b1;
          bit_ctr_d = 3'b0;
          ctr_d = 1'b0;
          if (new_data) begin
            data_d = data;
            state_d = START_BIT;
            busy_d = 1'b1;
          end
        end
      end
      START_BIT: begin
        busy_d = 1'b1;
        ctr_d = ctr_q + 1'b1;
        tx_d = 1'b0;
        if (ctr_q == CLK_PER_BIT - 1) begin
          ctr_d = 1'b0;
          state_d = DATA;
        end
      end
      DATA: begin
        busy_d = 1'b1;
        tx_d = data_q[bit_ctr_q];
        ctr_d = ctr_q + 1'b1;
        if (ctr_q == CLK_PER_BIT - 1) begin
          ctr_d = 1'b0;
          bit_ctr_d = bit_ctr_q + 1'b1;
          if (bit_ctr_q == 7) begin
            state_d = STOP_BIT;
          end
        end
      end
      STOP_BIT: begin
        busy_d = 1'b1;
        tx_d = 1'b1;
        ctr_d = ctr_q + 1'b1;
        if (ctr_q == CLK_PER_BIT - 1) begin
          state_d = IDLE;
        end
      end
      default: begin
        state_d = IDLE;
      end
    endcase
  end
 
  always @(posedge clk) begin
    if (rst) begin
      state_q <= IDLE;
      tx_q <= 1'b1;
    end else begin
      state_q <= state_d;
      tx_q <= tx_d;
    end
 
    block_q <= block_d;
    data_q <= data_d;
    bit_ctr_q <= bit_ctr_d;
    ctr_q <= ctr_d;
    busy_q <= busy_d;
  end
 
endmodule
```

The parameter **CLK_PER_BIT** is used to set the baud rate. To calculate the correct value for **CLK_PER_BIT** use **CLK_PER_BIT** = Mojo Frequency / Baud Rate.

If you open up **avr_interface.v** you will notice that **CLK_PER_BIT** is set to automatically calculated for you. The baud rate is set to 500,000 bits/sec. The AVR expects this baud rate regardless of what you set the baud rate on your computer for the USB to serial device. You will notice that this is not a standard baud rate! This rate was used since it divides evenly allowing for a high baud rates with 0% error. 

If you wanted a baud rate of 19200, you would use 50MHz / 19200 = 2604 for **CLK_PER_BIT**. Notice that 19200 doesn't divide evenly into 50MHz. It's usually ok to just round to the nearest value. You can check your error by calculating the real baud rate (50MHz / 2604 = 19201.228...) and using the percent error formula, difference / desired (1.228... / 19200 = 6.4*10^-5 or 6.4*10^-3%).

The parameter **CTR_SIZE** should be the minimum number of bits needed to hold the value **CLK_PER_BIT**. In other words ceiling(Log2(**CLK_PER_BIT**)). This is also calculated automatically for you using the built in function **$clog2**.

The input **block** is used by the AVR to tell the Mojo not to send any more data as it's buffer is full. If you don't need **block** you can set it to 0, or remove it from the module.

The way this module works is pretty simple. When it is told to send a byte of data it sends out the start bit. Each bit lasts for **CLK_PER_BIT** number of clock cycles. After the start bit, the data bits are sent out LSB first. The transmission is finally ended with a stop bit.

This is a more realistic example of using state machines than the state machine introduced in the [metastability and debouncing tutorial](@/tutorials/verilog/mojo/metastability-and-debouncing.md).

### The Receiver

The receiver code can be found in the **serial_rx.v** file in the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip).

```verilog,short
module serial_rx #(
    parameter CLK_PER_BIT = 50
  )(
    input clk,
    input rst,
    input rx,
    output [7:0] data,
    output new_data
  );
 
  // clog2 is 'ceiling of log base 2' which gives you the number of bits needed to store a value
  parameter CTR_SIZE = $clog2(CLK_PER_BIT);
 
  localparam STATE_SIZE = 2;
  localparam IDLE = 2'd0,
    WAIT_HALF = 2'd1,
    WAIT_FULL = 2'd2,
    WAIT_HIGH = 2'd3;
 
  reg [CTR_SIZE-1:0] ctr_d, ctr_q;
  reg [2:0] bit_ctr_d, bit_ctr_q;
  reg [7:0] data_d, data_q;
  reg new_data_d, new_data_q;
  reg [STATE_SIZE-1:0] state_d, state_q = IDLE;
  reg rx_d, rx_q;
 
  assign new_data = new_data_q;
  assign data = data_q;
 
  always @(*) begin
    rx_d = rx;
    state_d = state_q;
    ctr_d = ctr_q;
    bit_ctr_d = bit_ctr_q;
    data_d = data_q;
    new_data_d = 1'b0;
 
    case (state_q)
      IDLE: begin
        bit_ctr_d = 3'b0;
        ctr_d = 1'b0;
        if (rx_q == 1'b0) begin
          state_d = WAIT_HALF;
        end
      end
      WAIT_HALF: begin
        ctr_d = ctr_q + 1'b1;
        if (ctr_q == (CLK_PER_BIT >> 1)) begin
          ctr_d = 1'b0;
          state_d = WAIT_FULL;
        end
      end
      WAIT_FULL: begin
        ctr_d = ctr_q + 1'b1;
        if (ctr_q == CLK_PER_BIT - 1) begin
          data_d = {rx_q, data_q[7:1]};
          bit_ctr_d = bit_ctr_q + 1'b1;
          ctr_d = 1'b0;
          if (bit_ctr_q == 3'd7) begin
            state_d = WAIT_HIGH;
            new_data_d = 1'b1;
          end
        end
      end
      WAIT_HIGH: begin
        if (rx_q == 1'b1) begin
          state_d = IDLE;
        end
      end
      default: begin
        state_d = IDLE;
      end
    endcase
 
  end
 
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
      bit_ctr_q <= 3'b0;
      new_data_q <= 1'b0;
      state_q <= IDLE;
    end else begin
      ctr_q <= ctr_d;
      bit_ctr_q <= bit_ctr_d;
      new_data_q <= new_data_d;
      state_q <= state_d;
    end
 
    rx_q <= rx_d;
    data_q <= data_d;
  end
 
endmodule
```

The parameters for this module are the same as the ones from the TX module.

This module will sit in the **IDLE** state until it detects that the **rx** signal is low. That signals the beginning of the start bit. It then waits for **half** the number of clock cycles as **CLK_PER_BIT**. This is to make sure that the data bits are sampled near their centers, which is important for reliably receiving the data.