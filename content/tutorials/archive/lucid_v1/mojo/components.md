+++
title = "Components"
weight = 3
aliases = ["tutorials/lucid_v1/mojo/components.md"]
+++

In this tutorial we will use the USB port and create a project that will echo back all the data sent to the Mojo.

This will teach you how to use components in your projects.

## Getting Started

Like before, we will start by creating a new project. Go to **File->New Project...** and create a new Lucid project. I'm calling mine _Serial Port Echo_. It is from the _Base Project_ example.

Great! Now we have a bare-bones project. The Mojo's USB port is accessible to the FPGA through the AVR (the microcontroller). The AVR acts as a USB<->serial bridge once the FPGA is configured so we need to talk to the AVR over **UART** (**U**niversal **A**synchronous **R**eceiver **T**ransmitter).

## Components

Components are prewritten modules that you will likely need to use in many of your projects. For this tutorial, we need to add the _AVR Interface_ component to our project.

Launch the _Component Selector_ by going to **Project->Add Components...**

Under _Interfaces_ you will find the component _AVR Interface_. Click the checkbox next to it.

![components.png](https://cdn.alchitry.com/lucid_v1/mojo/components.png)

Notice that there are four more components under _AVR Interface_ that automatically got selected. These are **dependencies** of _AVR Interface_. That means they must be included for it to work.

You can click each one for a short description of what it does. Each of the dependencies can be included separately for use if your own projects if you want (they exist in other categories).

You should take some time to look at what components are available to you for your future projects.

Click **Add** to copy the components into your project.

Notice that there is a new category called _Components_.

![components_added.png](https://cdn.alchitry.com/lucid_v1/mojo/components_added.png)

You can open any of the components you want to take a look at how they work. However, for this tutorial we will be using them as a black box.

## Instantiating the Component

Now that the components we need are in our project, we need to use them.

We are going make some changes in _mojo_top.luc_.

```lucid
.clk(clk) {
  // The reset conditioner is used to synchronize the reset signal to the FPGA
  // clock. This ensures the entire FPGA comes out of reset at the same time.
  reset_conditioner reset_cond;
 
  .rst(rst){
    // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
    avr_interface avr;
  }
}
```

This will create an instance of _avr_interface_ named _avr_.

If you only do this, you will actually get an error. The error is because some of the inputs to the module were never assigned. Add the following to line 33.

```lucid
// connect inputs
avr.cclk = cclk;
avr.spi_ss = spi_ss;
avr.spi_mosi = spi_mosi;
avr.spi_sck = spi_sck;
avr.rx = avr_tx;
 
// connect outputs
spi_miso = avr.spi_miso;
spi_channel = avr.spi_channel;
avr_rx = avr.tx;
avr.channel = hf; // ADC is unused so disable
avr.tx_block = avr_rx_busy; // block TX when AVR is busy
```

Here we are just connecting the inputs and outputs of the _avr_ instance to the inputs and outputs of our module.

Also, now that the connections to the AVR are actually being used, don't forget to remove the following lines that assign default values from the always block.

```lucid
spi_miso = bz;          // not using SPI
spi_channel = bzzzz;    // not using flags
avr_rx = bz;            // not using serial port
```

Note that _avr.channel_ is set to _hf_, this will disable the ADC since it is an invalid channel. You should disable the ADC when you aren't using it because the AVR with otherwise spend time taking readings. You can get better USB data rates when it is disabled.

Also note that _avr.rx_ connects to _avr_tx_ and _avr.tx_ connects to _avr_rx_. This is because the top level signals were named the same as those on the AVR while the module signal names are its own. You want the module's transmitter to connect to the AVR's receiver and vice versa.

We are still missing some connections, but first a small detour.

### Sending and Receiving Data

When new data arrives, the signal _avr.new_rx_data_ goes high. This tells you that the data of _avr.rx_data_ is valid. Normally you would want to wait for _avr.new_rx_data_ to go high and then do something with the data.

To write data to the USB port is the same idea. We set _avr.tx_data_ to the byte to send and we set _avr.new_tx_data_ high. However, there is one more signal to look out for. That is _avr.tx_busy_. If this signal is high, the transmitter is busy for some reason, either it is currently sending a byte or the AVR can't take any more data at this moment. Either way, if you try to send data when this is high, it will be ignored.

For this simple example, we are going to ignore _avr.tx_busy_ and just live with dropped data if too much stuff is sent at once. The next tutorial will handle this more gracefully.

All we want to do is echo data we receive back to the transmitter. To do this we can just connect the transmitter to the receiver.

```lucid
// connect the receiver to the transmitter
// to echo the data back
avr.tx_data = avr.rx_data;
avr.new_tx_data = avr.new_rx_data;
```

You should now be able to build your project and load it on the Mojo. If you fire up your favorite serial port monitor and connect to the Mojo, any text you send should be sent right back. Note that the baud rate you set doesn't matter (it's ignored) as long as it's not 1200, which is used to put the AVR into bootloader mode.

## Capturing Data

Before we wrap up, let's do a little more with the incoming data. We are going to save the last byte received and display it on the LEDs.

To do this this, we need an 8 bit dff.

```lucid
dff data[8]; // flip-flops to store last character
```

We can then write to the _dff_ when we have new data.

```lucid
if (avr.new_rx_data) // if new data
  data.d = avr.rx_data; // write it to data
 
led = data.q; // connect the LEDs to our flip-flop
```

On the last line, we connect the LEDs to the output of the _dff_.

If you don't assign a _dff_ a value, then it will retain the last value it had. Since we are only assigning it a value when _avr.new_rx_data_ is high, it will hold the last byte until the next one comes in.

Now, if you build and load your project, when you fire up a serial port monitor you should not only see the text you send back in the monitor, but the LEDs on the Mojo should also changed depending on the character you sent.

The full module looks like this.

```lucid
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
      dff data[8]; // flip-flops to store last character
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
 
    // connect the receiver to the transmitter
    // to echo the data back
    avr.tx_data = avr.rx_data;
    avr.new_tx_data = avr.new_rx_data;
 
    if (avr.new_rx_data) // if new data
      data.d = avr.rx_data; // write it to data
 
    led = data.q; // connect the LEDs to our flip-flop
  }
}
```