+++
title = "Serial Peripheral Interface (SPI)"
weight = 15
+++

**S**erial **P**eripheral **I**nterface, or **SPI**, is a very common communication protocol used for two-way communication between two devices. A standard SPI bus consists of 4 signals, **M**aster **O**ut **S**lave **I**n (**MOSI**), **M**aster **I**n **S**lave **O**ut (**MISO**), the clock (**SCK**), and **S**lave **S**elect (**SS**). Unlike an [asynchronous serial interface](@/tutorials/verilog/mojo/asynchronous-serial.md), SPI is not symmetric. An SPI bus has one **master** and one or more **slaves**. The master can talk to any slave on the bus, but each slave can only talk to the master. Each slave on the bus must have it's own unique slave select signal. The master uses the slave select signals to _select_ which _slave_ it will be talking to. Since SPI also includes a clock signal, both devices don't need to agree on a data rate before hand. The only requirement is that the clock is lower than the maximum frequency for all devices involved.

### Example SPI Transfer

When the master of the SPI bus wants to initiate a transfer, it must first pull the **SS** signal low for the slave it wants to communicate with. Once the **SS** signal is low, that slave will be _listening_ on the bus. The master is then free to start sending data.

There are 4 different SPI bus standards that all have to do with the **SCK** signal. The 4 modes are broken down into two parameters, **CPOL** and **CPHA**. **CPOL** stands for **C**lock **POL**arity and designates the default value (high/low) of the **SCK** signal when the bus is idle. **CPHA** stands for **C**lock **PHA**se and determines which edge of the clock data is sampled (rising/falling). The data sheet for any device will specify these parameters so you can adjust accordingly. The most common settings are **CPOL**=0 (idle low) and **CPHA**=0 (sample rising edge).

Here is an example transfer with **CPOL**=0 and **CPHA**=0.

![spi.png](https://cdn.alchitry.com/verilog/mojo/spi.png)

The bits in a SPI transmission are sent LSB first.

Any SPI transmission is controlled solely by the master. The master generates the clock and controls the slave select signal(s). This means that the slave has no way of sending data to the master on its own!

Each SPI transfer is **full-duplex**, meaning that data is sent from the master to the slave and from the slave to the master at the same time. There is no way for a slave to opt-out of sending data when the master makes a transfer, however, devices will send dummy bytes (usually all 1's or all 0's) when communication should be one way. If the master is reading data in for a slave, the slave will know to ignore the data being sent by the master.

Devices that use SPI typically will send/receive multiple bytes each time the **SS** signal goes low. This way the **SS** signal acts as a way to frame a transmission. For example, if you had a flash memory that had an SPI bus and you want to read some data, the **SS** signal would go low, the master would send the command to read memory at a certain address, and as long as the master kept **SS** low and toggling **SCK** the flash memory would keep sending out data. Once **SS** returned high the flash memory knows to end the read command.

Since the **MISO** signal can be connected to multiple devices, each device will only drive the line when its **SS** signal is low. This is shown by the grey area.

### SPI Slave

In the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip), the file **spi_slave.v** contains the SPI module used to interface with the AVR. The AVR, in this case, is the master and the FPGA is the slave. The reason the AVR is the master is because the SPI bus is used to transfer data from the analog pins. Since the FPGA has no way of knowing when the data would be available, the FPGA would have to keep asking the AVR if it had any data. By making the AVR the master, it allows it to send the data right when it's ready.

```verilog,short
module spi_slave(
    input clk,
    input rst,
    input ss,
    input mosi,
    output miso,
    input sck,
    output done,
    input [7:0] din,
    output [7:0] dout
  );
 
  reg mosi_d, mosi_q;
  reg ss_d, ss_q;
  reg sck_d, sck_q;
  reg sck_old_d, sck_old_q;
  reg [7:0] data_d, data_q;
  reg done_d, done_q;
  reg [2:0] bit_ct_d, bit_ct_q;
  reg [7:0] dout_d, dout_q;
  reg miso_d, miso_q;
 
  assign miso = miso_q;
  assign done = done_q;
  assign dout = dout_q;
 
  always @(*) begin
    ss_d = ss;
    mosi_d = mosi;
    miso_d = miso_q;
    sck_d = sck;
    sck_old_d = sck_q;
    data_d = data_q;
    done_d = 1'b0;
    bit_ct_d = bit_ct_q;
    dout_d = dout_q;
 
    if (ss_q) begin                           // if slave select is high (deselcted)
      bit_ct_d = 3'b0;                        // reset bit counter
      data_d = din;                           // read in data
      miso_d = data_q[7];                     // output MSB
    end else begin                            // else slave select is low (selected)
      if (!sck_old_q && sck_q) begin          // rising edge
        data_d = {data_q[6:0], mosi_q};       // read data in and shift
        bit_ct_d = bit_ct_q + 1'b1;           // increment the bit counter
        if (bit_ct_q == 3'b111) begin         // if we are on the last bit
          dout_d = {data_q[6:0], mosi_q};     // output the byte
          done_d = 1'b1;                      // set transfer done flag
          data_d = din;                       // read in new byte
        end
      end else if (sck_old_q && !sck_q) begin // falling edge
        miso_d = data_q[7];                   // output MSB
      end
    end
  end
 
  always @(posedge clk) begin
    if (rst) begin
      done_q <= 1'b0;
      bit_ct_q <= 3'b0;
      dout_q <= 8'b0;
      miso_q <= 1'b1;
    end else begin
      done_q <= done_d;
      bit_ct_q <= bit_ct_d;
      dout_q <= dout_d;
      miso_q <= miso_d;
    end
 
    sck_q <= sck_d;
    mosi_q <= mosi_d;
    ss_q <= ss_d;
    data_q <= data_d;
    sck_old_q <= sck_old_d;
 
  end
 
endmodule
```

This is module assumes **CPOL** = 0 and **CPHA** = 0.

It waits for **SS** to go low. Once **SS** is low, it starts shifting data into the **data_d/_q** register. Once eight bits have been shifted in it signals that it has new data on **dout**. On the falling edges of the clock, it shifts out the data that was provided by **din** at the beginning of the transmission.

### SPI Master

Our Clock/Visualizer Shield, uses a **R**eal-**T**ime **C**lock (**RTC**) device that provides the Mojo with the current time. The RTC is connected to the Mojo through an SPI bus. In this case, the FPGA on the Mojo is the master and the RTC is the slave.

```verilog,short
module spi #(parameter CLK_DIV = 2)(
    input clk,
    input rst,
    input miso,
    output mosi,
    output sck,
    input start,
    input[7:0] data_in,
    output[7:0] data_out,
    output busy,
    output new_data
  );
 
  localparam STATE_SIZE = 2;
  localparam IDLE = 2'd0,
    WAIT_HALF = 2'd1,
    TRANSFER = 2'd2;
 
  reg [STATE_SIZE-1:0] state_d, state_q;
 
  reg [7:0] data_d, data_q;
  reg [CLK_DIV-1:0] sck_d, sck_q;
  reg mosi_d, mosi_q;
  reg [2:0] ctr_d, ctr_q;
  reg new_data_d, new_data_q;
  reg [7:0] data_out_d, data_out_q;
 
  assign mosi = mosi_q;
  assign sck = (~sck_q[CLK_DIV-1]) & (state_q == TRANSFER);
  assign busy = state_q != IDLE;
  assign data_out = data_out_q;
  assign new_data = new_data_q;
 
  always @(*) begin
    sck_d = sck_q;
    data_d = data_q;
    mosi_d = mosi_q;
    ctr_d = ctr_q;
    new_data_d = 1'b0;
    data_out_d = data_out_q;
    state_d = state_q;
 
    case (state_q)
      IDLE: begin
        sck_d = 4'b0;              // reset clock counter
        ctr_d = 3'b0;              // reset bit counter
        if (start == 1'b1) begin   // if start command
          data_d = data_in;        // copy data to send
          state_d = WAIT_HALF;     // change state
        end
      end
      WAIT_HALF: begin
        sck_d = sck_q + 1'b1;                  // increment clock counter
        if (sck_q == {CLK_DIV-1{1'b1}}) begin  // if clock is half full (about to fall)
          sck_d = 1'b0;                        // reset to 0
          state_d = TRANSFER;                  // change state
        end
      end
      TRANSFER: begin
        sck_d = sck_q + 1'b1;                           // increment clock counter
        if (sck_q == 4'b0000) begin                     // if clock counter is 0
          mosi_d = data_q[7];                           // output the MSB of data
        end else if (sck_q == {CLK_DIV-1{1'b1}}) begin  // else if it's half full (about to fall)
          data_d = {data_q[6:0], miso};                 // read in data (shift in)
        end else if (sck_q == {CLK_DIV{1'b1}}) begin    // else if it's full (about to rise)
          ctr_d = ctr_q + 1'b1;                         // increment bit counter
          if (ctr_q == 3'b111) begin                    // if we are on the last bit
            state_d = IDLE;                             // change state
            data_out_d = data_q;                        // output data
            new_data_d = 1'b1;                          // signal data is valid
          end
        end
      end
    endcase
  end
 
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 3'b0;
      data_q <= 8'b0;
      sck_q <= 4'b0;
      mosi_q <= 1'b0;
      state_q <= IDLE;
      data_out_q <= 8'b0;
      new_data_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
      data_q <= data_d;
      sck_q <= sck_d;
      mosi_q <= mosi_d;
      state_q <= state_d;
      data_out_q <= data_out_d;
      new_data_q <= new_data_d;
    end
  end
 
endmodule
```

In this case **CPOL** = 0 and **CPHA** = 1.

The overall idea is the same, however, the FPGA now needs to generate the **SCK** signal. The parameter **CLK_DIV** is used to specify how much the FPGA's clock should be divided. The default value is 2, which means that the frequency of **SCK** will be 1/4th (2^2 = 4 clock cycles) of that of the FPGA. If **CLK_DIV** was set to 3, **SCK** would be 1/8th (2^3 = 8 clock cycles) the frequency of the FPGA's clock.