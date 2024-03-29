+++
title = "Components"
weight = 3
+++

In this tutorial we will use the USB port and create a project that will echo back all the data sent to the Au or Cu. [Click here for a tutorial for the Mojo.](@/tutorials/lucid_v1/mojo/components.md)

This will teach you how to use components in your projects.

## Getting Started

Like before, we will start by creating a new project. Go to **File->New Project...** and create a new Lucid project. I'm calling mine _Serial Port Echo_. It is from the _Base Project_ example.

Great! Now we have a bare-bones project. The Au's and Cu's USB port is accessible to the FPGA through the FTDI USB<->serial bridge. Serial is often called **UART** (**U**niversal **A**synchronous **R**eceiver **T**ransmitter) and this is the name of the components we will need.

## Components

Components are prewritten modules that you will likely need to use in many of your projects. For this tutorial, we need to add two components to our project. One to receive data and one to send data.

Launch the _Component Selector_ by going to **Project->Add Components...**

Under _Protocols_ you will find the components _UART TX_ and _UART RX_. Click the checkboxes next to each one.

![Screenshot_from_2019-04-23_10-52-59.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-04-23_10-52-59.png)

You can click each component for a short description of what it does. 

Feel free to explore the other categories to see what's available. The list of components grows over time with new releases of Alchitry Labs.

Click **Add** to copy the components into your project.

Notice that there is a new category called _Components_.

![Screenshot_from_2019-04-23_10-57-40.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-04-23_10-57-40.png)

You can open any of the components you want to take a look at how they work. However, for this tutorial we will be using them as a black box.

## Instantiating the Component

Now that the components we need are in our project, we need to use them.

We are going make some changes in the top file.

```lucid
.clk(clk) {
  // The reset conditioner is used to synchronize the reset signal to the FPGA
  // clock. This ensures the entire FPGA comes out of reset at the same time.
  reset_conditioner reset_cond;
 
  .rst(rst) {
    uart_rx rx (#BAUD(1000000), #CLK_FREQ(100000000)); // serial receiver
    uart_tx tx (#BAUD(1000000), #CLK_FREQ(100000000)); // serial transmitter
  }
}
```

This will create instances of _uart_rx_ and _uart_tx_ named _rx_ and _tx_ respectively.

We need to specify two parameters for each one. The _BAUD_ parameter is the number of bits per second it should send. The important thing is that you match this rate to the one you set on your computer. The serial port monitor in Alchitry Labs uses 1M baud so that is what we specify here.

The other parameter, ﻿_CLK_FREQ_﻿, is the frequency of the clock. This is used to calculate how many clock cycles are required per bit.

If you only do this, you will actually get some errors. These errors are because some of the inputs to the modules were never assigned.

We are going to hook the modules up to each other so that when data is received, it is promptly sent back.

Change the always block to look the following.

```lucid
always {
  reset_cond.in = ~rst_n; // input raw inverted reset signal
  rst = reset_cond.out;   // conditioned reset
 
  led = 8h00;             // turn LEDs off
 
  rx.rx = usb_rx;         // connect rx input
  usb_tx = tx.tx;         // connect tx output
 
  tx.new_data = rx.new_data;
  tx.data = rx.data;         
  tx.block = 0;           // no flow control, do not block
}
```

On lines 28 and 29, we connect the external input and output to our two modules. 

On lines 31 and 32, we connect the _rx_ module's outputs to the _tx_ module's inputs. 

On line 33, we set the _block_ input of _tx_ to 0. When this value is 1, the _uart_tx_ component won't send any data out. This is useful if you have some way to tell that the receiver is busy. With the Au and Cu, we just assume the data is being read from the computer in a timely manner to keep the FTDI's buffer from overflowing. This is a reasonable assumption as long as there is some program actually reading the data.

### Sending and Receiving Data

When new data arrives, the signal _rx.new_data_ goes high. This tells you that the data on _rx.data_ is valid. Normally you would want to wait for _rx.new_data_ to go high and then do something with the data.

Writing data to the serial port follows the same idea. We set _tx.data_ to the byte to send and we set _tx.new_data_ high. However, there is one more signal to look out for. That is _tx.busy_. If this signal is high, the transmitter is busy for some reason, either it is currently sending a byte or block is high. Either way, if you try to send data when this is high, it will be ignored.

For this simple example, we are going to ignore _tx.busy_. This should not be a problem since we never block and the bytes coming in arrive at the same rate we can send them out.

The next tutorial will handle this more gracefully by actually respecting this flag. 

You should now be able to build your project and load it on the board. You can then go to **Tools->Serial Port Monitor** in Alchitry Labs to launch the monitor. From here, choose the virtual serial port the board connected to and you should be able to type data into the monitor. Whatever you type should be shown.

## Capturing Data

Before we wrap up, let's do a little more with the incoming data. We are going to save the last byte received and display it on the LEDs.

To do this this, we need an 8 bit dff. The following line goes inside the _.clk(clk)_ block but outside the _.rsr(rst)_ block. It could go inside the _.rst(rst)_ block but it really doesn't need a reset.

```lucid
dff data[8];            // flip-flops to store last character
```

We can then write to the _dff_ when we have new data. These lines go at the end of the _always_ block. You can also remove the previous assignment of 0 to _led_.

```lucid
if (rx.new_data)        // new byte received
  data.d = rx.data;     // save it
 
led = data.q;           // output the data
```

On the last line, we connect the LEDs to the output of the _dff_.

If you don't assign a _dff_ a value, then it will retain the last value it had. Since we are only assigning it a value when _rx.new_data_ is high, it will hold the last byte until the next one comes in.

Now, if you build and load your project, when you fire up a serial port monitor you should not only see the text you send back in the monitor, but the LEDs on the board should also changed depending on the character you sent.

The full module looks like this.

```lucid
module cu_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx           // USB->Serial output
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst) {
      uart_rx rx (#BAUD(1000000), #CLK_FREQ(100000000));
      uart_tx tx (#BAUD(1000000), #CLK_FREQ(100000000));
    }
 
    dff data[8];            // flip-flops to store last character
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    rx.rx = usb_rx;         // connect rx input
    usb_tx = tx.tx;         // connect tx output
 
    tx.new_data = rx.new_data;
    tx.data = rx.data;         
    tx.block = 0;           // no flow control, do not block
 
    if (rx.new_data)        // new byte received
      data.d = rx.data;     // save it
 
    led = data.q;           // output the data
  }
}
```