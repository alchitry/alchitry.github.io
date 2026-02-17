+++
title = "Register Interface"
weight = 10
+++

This tutorial will introduce you to the register interface component and how it can be used to create easy and reliable interfaces to your designs.

## Overview

The register interface component takes over a serial port (typically from the AVR interface component) and create an address based interface. You can then issue read and write requests over the Mojo's USB port to specific addresses. By default, these addresses have no meaning. They are simply a way for you to differentiate the requests. Both the data and address values are 32 bits wide.

## Example

Let's create a quick example that will map the LEDs on the Mojo to address 0. That way we can read and write to address 0 to change the value of the LEDs.

Create a new project based on the _AVR Interface_ example.

Now open up the components library and add the _Register Interface_ component, which can be found under _Interfaces_.

We now need to hook it up to the serial port of the _AVR Interface_ in _mojo_top.luc_.

```lucid,linenos,short
module mojo_top (
    input clk,              // 50MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input cclk,             // configuration clock, AVR ready when high
    output spi_miso,        // AVR SPI MISO
    input spi_ss,           // AVR SPI Slave Select
    input spi_mosi,         // AVR SPI MOSI
    input spi_sck,          // AVR SPI Clock
    output spi_channel [4], // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,           // AVR TX (FPGA RX)
    output avr_rx,          // AVR RX (FPGA TX)
    input avr_rx_busy       // AVR RX buffer full
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst){
      // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
      avr_interface avr;
      reg_interface register;
    }
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    // connect inputs of avr
    avr.cclk = cclk;
    avr.spi_ss = spi_ss;
    avr.spi_mosi = spi_mosi;
    avr.spi_sck = spi_sck;
    avr.rx = avr_tx;
    avr.channel = hf;           // ADC is unused so disable
    avr.tx_block = avr_rx_busy; // block TX when AVR is busy
 
    // connect outputs of avr
    spi_miso = avr.spi_miso;
    spi_channel = avr.spi_channel;
    avr_rx = avr.tx;
 
    register.rx_data = avr.rx_data;
    register.new_rx_data = avr.new_rx_data;
    avr.tx_data = register.tx_data;
    avr.new_tx_data = register.new_tx_data;
    register.tx_busy = avr.tx_busy;
 
    register.regIn.drdy = 0;    // default to no data
    register.regIn.data = 32bx; // don't care
 
    led = 0;          // turn LEDs off
  }
}
```

Now we only have to deal with the register interface and we can ignore the AVR interface.

Take a look at the _reg_interface.luc_ file.

```lucid,linenos,linenostart=35
global Register {
  struct master {                                 // master device outputs
    new_cmd,                                      // 1 = new command
    write,                                        // 1 = write, 0 = read
    address[32],                                  // address to read/write
    data[32]                                      // data to write (ignore on reads)
  }
  struct slave {                                  // slave device outputs
    data[32],                                     // data read from requested address
    drdy                                          // read data valid (1 = valid)
  }
}
```

```lucid,linenos,linenostart=63
// Register Interface
output<Register.master> regOut,               // register outputs
input<Register.slave> regIn                   // register inputs
```

Here you can see the interface we will be dealing with. When the master (your PC) issues a command, _regOut.new_cmd_ goes high. At this time, _regOut.write_ will tell you if it is write or read request and _regOut.address_ will tell you what address is being referenced. During a write, _regOut.data_ is valid and is the data that should be written to the specified address. During a read, this value is invalid and should be ignored.

When a read request is sent, the value corresponding to _regOut.address_ should be generated and presented on _regIn.data_. When it is ready, _regIn.drdy_ should be set high.

We now need to add a _dff_ to save the value of the LEDs.

```lucid,linenos,linenostart=23
.rst(rst){
  // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
  avr_interface avr;
  reg_interface register;
 
  dff leds [8];
}
```

Now we can add some logic to handle the read and write requests.

```lucid,linenos,linenostart=59
if (register.regOut.new_cmd) {             // new command
  if (register.regOut.write) {             // if write
    if (register.regOut.address == 0) {    // if address is 0
      leds.d = register.regOut.data[7:0];  // write the LEDs
    }
  } else {                                 // if read
    if (register.regOut.address == 0) {    // if address is 0
      register.regIn.data = leds.q;        // read the LEDs
      register.regIn.drdy = 1;             // signal data ready
    }
  }
}
 
led = leds.q;                              // connect the dff
```

When we detect a write request, we update the value of _leds_, but when detect a read request, we return the value of _leds_. Note that we are filtering only for address 0. All other address requests will be ignored.

Here is the fully modified module.

```lucid,short
module mojo_top (
    input clk,              // 50MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input cclk,             // configuration clock, AVR ready when high
    output spi_miso,        // AVR SPI MISO
    input spi_ss,           // AVR SPI Slave Select
    input spi_mosi,         // AVR SPI MOSI
    input spi_sck,          // AVR SPI Clock
    output spi_channel [4], // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,           // AVR TX (FPGA RX)
    output avr_rx,          // AVR RX (FPGA TX)
    input avr_rx_busy       // AVR RX buffer full
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst){
      // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
      avr_interface avr;
      reg_interface reg;
 
      dff leds [8];
    }
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    // connect inputs of avr
    avr.cclk = cclk;
    avr.spi_ss = spi_ss;
    avr.spi_mosi = spi_mosi;
    avr.spi_sck = spi_sck;
    avr.rx = avr_tx;
    avr.channel = hf;           // ADC is unused so disable
    avr.tx_block = avr_rx_busy; // block TX when AVR is busy
 
    // connect outputs of avr
    spi_miso = avr.spi_miso;
    spi_channel = avr.spi_channel;
    avr_rx = avr.tx;
 
    // connect reg interface to avr interface
    reg.rx_data = avr.rx_data;
    reg.new_rx_data = avr.new_rx_data;
    avr.tx_data = reg.tx_data;
    avr.new_tx_data = reg.new_tx_data;
    reg.tx_busy = avr.tx_busy;
 
    reg.regIn.drdy = 0;                   // default to not ready
    reg.regIn.data = 32bx;                // don't care
 
    if (reg.regOut.new_cmd) {             // new command
      if (reg.regOut.write) {             // if write
        if (reg.regOut.address == 0) {    // if address is 0
          leds.d = reg.regOut.data[7:0];  // write the LEDs
        }
      } else {                            // if read
        if (reg.regOut.address == 0) {    // if address is 0
          reg.regIn.data = leds.q;        // read the LEDs
          reg.regIn.drdy = 1;             // signal data ready
        }
      }
    }
 
    led = leds.q;                         // connect the dff
  }
}
```

Build your project and load it onto your board.

In the Mojo IDE, go to **Tools->Register Interface...**. This tool allows you to send read and write requests to specific addresses when using the register interface component. Fill in 0 for _Address_ and 1 for _Value_ then click _Write_.

![reginterface.png](https://cdn.alchitry.com/lucid_v1/mojo/reginterface.png)

If everything went well, the first LED on your Mojo should have lit up! Try writing different values. Also note that you can use the radio buttons to select if you want the address and value fields to be represented in decimal or hexadecimal.

If you try to read from an address other than 0, you'll get an error message saying the read failed. This is because if the address isn't 0, we never return any data (_regIn.drdy_ stays 0 forever) so the read times out. You can write to other addresses, but the writes are simply ignored.

Try to modify the code so that address 0 still controls the LEDs, but address 1 now will read a bit-wise inverted version of what was last written to it. If you need help, [hit up our forums](http://forum.alchitry.com/).

## The API

This built in register interface tool is helpful, but manually entering everything isn't always practical. Here we will go over how the protocol works for issuing read and write requests so that you can use this in your own applications.

Every request starts with 5 bytes being sent. The first byte is the command byte and the next four are the address (32 bits = 4 bytes) sent with the least significant byte first.

In many cases you will want to read or write to many consecutive addresses, or perhaps the same address many times. It would be inefficient to have to issue the entire command each time so the command byte contains info for consecutive or multiple read/write requests in one.

The MSB (bit 7) of the command byte specifies if the command is a read (0) or write (1). The next bit (bit 6), specifies if consecutive addresses should be read/written (1) or if the same address should be read/written multiple times (0). The 6 LSBs (bits 5-0) represent how many read/write requests should be generated. Note that the number of requests will alway be 1 more than the value of these bits. That means if you want to read or write a single address, they should be set to 0. Setting them to 1 will generate two read or write requests.

If you send a write request, after sending the command byte and address, you continue sending the data to be written. Data is always sent as four bytes per write request and the least significant byte should be sent first.

For reads, after sending the command byte and address, you simply wait for the data to be returned. Data is returned in least significant byte order. Note that you may not always receive all the data you ask for if there is an issue with the FPGA design (i.e. the requested data is never presented, like in our LED example).

Let's take a look at an example.

If you want to write to addresses 5, 6, and 7, you could issue the following request. 0xC2 (1100 0010), 0x05, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00. This would write 1 to address 5, 2 to address 6, and 3 to address 7. If you changed the command byte to 0x82 (1000 0010) you would write 1 to address 5, 2 to address 5, and then 3 to address 5 (in that order).

Issuing a read follows the exact same format except the data bytes are received instead of sent.

A single command can generate up to 64 read/write requests. If you need to read/write more, you need to issue separate commands.

## Java Example

You can download a working Java example (Eclipse project) by [clicking here](http://cdn.embeddedmicro.com/lucid/RegisterInterfaceExample.zip). This example simply writes 0x12 to address 0, but there is a class to make it easy to perform reads and writes in bulk.