+++
title = "Synchronous Logic"
weight = 1
inline_language = "lucid"
aliases = ["tutorials/lucid_v1/synchronous-logic.md"]
+++

{{ youtube(id="kOE1GXge11k?si=nZOT0nboMJxjkcVl") }}

Synchronous logic is a fundamental building block for just about any digital design. It allows you to create much more complex systems that accomplish something over a series of steps. It also gives you the ability to save states or other information. In this tutorial you will be introduced to the **D flip flop** and how you can use these to make an LED blink.

## The Problem

In our last tutorial we simply wired a LED to a button. Whenever you pressed the button the LED would turn on. Our design had no concept of time. The goal for this project is to blink an LED. That means we have to create a circuit that can turn itself on and off automatically after a regular interval of time has passed. For this we need the flip flop.

## Clocks

Before I can explain what exactly a flip flop does you need to understand what a clock is.

A clock is just a signal that toggles between 0 and 1 over and over again. It looks something like this.

![clock_1ef62072-d7ac-411c-ad74-9a9bd8d77bf7.png](https://cdn.alchitry.com/lucid_v1/clock_1ef62072-d7ac-411c-ad74-9a9bd8d77bf7.png)

The important thing is the rate at which it toggles. The clock on the Au and Cu is a 100MHz clock (the Mojo has a 50MHz clock). That means that it toggles 100 million times per second!

The clock has two edges, the **rising edge** and the **falling edge**. I drew the rising edges with little arrows. The rising edge is usually the important one.

## D Flip-Flops

This is one of the most important circuit elements you will be using. Lucky for you, it is also fairly straightforward how they work. Take a look at the symbol for the flip flop below.

![dff_783f7c84-8d1f-4bdf-b1b0-c8a45cde2a9a.png](https://cdn.alchitry.com/lucid_v1/dff_783f7c84-8d1f-4bdf-b1b0-c8a45cde2a9a.png)

This image shows all the signals that a flip flop could have, but in practice, the only required signals are _D_, _Q_, and _clk_. For now, forget about _rst_ and _en_.

So what exactly does this thing do? All it does is copy the signal at _D_ to _Q_ whenever there is a rising edge on the _clk_ input. That means _Q_ will keep it's value between rising edges of the clock. Since the flip flop _remembers_ what the input was at _D_, it is actually one of the most basic memory elements.

## Loops

Lets take a look at the following example.

![notloop_a227efa4-c9ae-4a79-b9ed-0ea3f240c4d4.png](https://cdn.alchitry.com/lucid_v1/notloop_a227efa4-c9ae-4a79-b9ed-0ea3f240c4d4.png)

What will this circuit do? If the input to the gate is 1, then it's output is 0. However, the output is the input so the output must be 1, but then the input is 1 so the output must be 0? If we assume that the signal can only be 0 or 1 it seems like it would toggle between 0 and 1 infinitely fast. In practice, remember that signals are actually represented by voltages, it may oscillate or it may settle to somewhere in the middle. This is, of course, something we don't want. Designing combinational circuits with feedback can be very tricky to make sure something like this doesn't happen and that the circuit will work how you expect it to. That is why we don't! Instead, we use a circuit like this one.  

![](https://cdn.alchitry.com/lucid_v1/image-asset.png)

What will this circuit do? Well, for now lets just assume that _Q_ is 0. That means that _D_ is 1 (because it went through the not gate). On the next rising edge of the clock _Q_ will copy what _D_ is, so _Q_ becomes 1. Once _Q_ becomes 1, _D_ becomes 0. You can follow the pattern to realize that every time there is a rising edge on the clock the output of the flip flop toggles.

What about the initial condition though? If we just built this circuit how do we know if _Q_ is 0 or 1? The truth is that we don't and in some cases it may be 1 while others it may be 0. That is where the _rst_ signal comes in. This signal is used to reset the flip flop to a known state. In FPGAs this signal is generally very flexible and allows you to reset the flip flop to a 1 or 0 when the signal is high or low (your choice, not both). In Lucid, _dffs_ use active high resets. That means when the _rst_ signal is 1, the flip flop is held in reset.

There are cases where you don't care what the initial value of the flip flop is, in those cases you don't need to, and shouldn't, use a reset.

Since the only signal left is _en_, I'll cover it now just for completeness. There are times when you want the flip flop to ignore the rising edges on the clock and to preserve the contents of _Q_. That is when you use the **enable** signal. When the _en_ signal is 1, the flip flop operates normally. When it is 0 the contents of _Q_ won't change on the rising edges of the clock. If you see a flip flop without an _en_ signal it is just assumed that the flip flop is always enabled.

In Lucid, _dffs_ don't have an explicit _en_ signal, but rather will retain their contents if you don't write something new to it.

## Creating the Module

Open Alchitry Labs and create a new project. I'm going to call mine BlinkerDemo.

With the new project open, click the _New File_ icon (the left most icon in the toolbar) and create a Lucid source file called _blinker.luc_.

![new_module.png](https://cdn.alchitry.com/lucid_v1/new_module.png)

Click _Create File_ to create the file.

The file should now be under _Source_ in the project tree and it should automatically open.

![blinker_module.png](https://cdn.alchitry.com/lucid_v1/blinker_module.png)

## Writing the Blinker

Edit the module so that it looks like the following.

```lucid
module blinker (
    input clk,    // clock
    input rst,    // reset
    output blink  // output to LED
  ) {
 
  dff counter[25](.clk(clk), .rst(rst));
 
  always {
    blink = counter.q[24];
    counter.d = counter.q + 1;
  }
}
```

Let's go over what changes were made. First, I simply renamed _out_ to _blink_ to better reflect what our module does.

Line 7 has the declaration of the flip-flop. Lucid has a type _dff_ for creating flip-flops. The flip-flop I created is called _counter_ and it's 25 bits wide.

I then connected the _clk_ signal of our module to the _clk_ input of the flip-flop. I did the same with the _rst_ signal. The syntax for connecting these signals is _.module_input(signal)_ where _module_input_ is the name of the input on the module and _signal_ is the signal to connect to it. In this case the module input and signal names are the same.

In the always block, line 10 simply connects our output, _blink_, to the most significant bit of _counter.q_. When you are working with flip-flops, FSMs, or modules, you use the dot syntax to specify which signal you want. In this case, we need to read the _q_ output of the _dff_ so we use _counter.q_.

The next line connects the input, _d_, of the _dff_ to its output, _q_, plus one. This means that every time _clk_ goes high, _counter.q_ will increase by 1.

When declaring a _dff_ or _fsm_, you must connect its _clk_ input and optionally connect _rst_. These can't be connected later in an always block.

## Reset

Notice we connect the _rst_ signal to the counter. What does this do? Whenever the _rst_ signal goes high, the value of _counter.q_ becomes 0. This is also the value that the counter is initialized to when the FPGA first starts.

If we wanted the counter to initialize and reset to a different value, we can specify the value using the _dff_ parameter _#INIT_.

```lucid
dff counter[25](#INIT(100), .clk(clk), .rst(rst));
```

The counter will now start with a value of 100 and reset to 100. Zero is the default value if none is specified.

Notice that parameters are specified with _#NAME_ instead of _.name_. Parameters are always all capitalized.

If you don't need to reset a _dff_ for some reason, you can simply not connect anything to the _rst_ input and it won't have a reset. This is recommended if you don't need a reset since it doesn't force the tools to route the reset signal to the flip-flop.

The _dff_ and _fsm_ (covered later) types are special in that the _rst_ input is optional. All other inputs and all inputs to modules are required.

## The Counter

Here is what the counter circuit looks like. Keep in mind that there is actually 25 flip-flops (but only one +1 circuit) and the connections are actually 25 wires, or bits, wide. When many flip-flops are used to store a single multi-bit value they are commonly drawn as a single flip-flop.

![counter.png](https://cdn.alchitry.com/lucid_v1/counter.png)

Let's look at what this module will actually do. Right after the _rst_ signal goes low, _counter.q_ will be 0. That means that _counter.d_ will be 1, since our combinational block assigns it _counter.q_ plus 1.

At the next positive edge of _clk_, _counter.q_ will be assigned the value of _counter.d_, or 1. Once _counter.q_ is 1, _counter.d_ must be 2. You should be able to see what will continue to happen. Each clock cycle _counter.q_ will increase by 1. But what happens when _counter.q_ is _25b1111111111111111111111111_ (the max value)?

Since we are adding a 1 bit number to a 25 bit number, the result can be up to 26 bits, but since we are storing it into a 25 bit _dff_ we lose the last bit. That means that when _counter.q_ is the max value, _counter.d_ is 0 and the process starts all over again.

Our counter will continuously count from 0 to 33554431 (2^25 - 1).

How do we make an LED blink from this counter? It's simple once you realize that for half the time the most significant bit is 1 and the other half of the time it's 0. This is because if _counter.q_ is less than 16777216 (2^24), then the 24th bit must be 0 and when it is equal or greater, the MSB must be 1. That means we can just connect the LED to the most significant bit of our counter. If you need to convince yourself this is true try writing out the binary values from 0-7 and look at how the MSB (most significant bit) changes.

How fast will the LED blink though? We know that the clock frequency is 100MHz, or 100,000,000 clock cycles per second on the Au and Cu. Since our counter takes 2^25 cycles to overflow we can calculate the blinker time, 2^25 / 100,000,000 or about 0.34 seconds (0.67 seconds on the Mojo). The LED will turn on and off every 0.34 seconds. If you wanted to make that time longer, you can just make the counter 26 bits long and the time will double to 0.67 seconds. If you wanted to make it blink faster you can make the counter shorter.

## Module connections

In Lucid, there are three ways to specify an input into a _module_, _dff_, or _fsm_ (from now on I'll just call them all modules). The first way is how we did it in this example.

```lucid
dff counter[25](.clk(clk), .rst(rst));
```

Here we specify the connections in a set of parentheses directly after the name. These connections are only applied to this single module. However, we can use the next method to make the same connections to many modules.

```lucid
.clk(clk), .rst(rst) {
  dff counter1[12];
  dff counter2[7];
  dff counter3[8];
}
```

In this example, we connect the _clk_ and _rst_ inputs of all the modules contained in the curly braces. In this case, they contain three _dffs_. This is convenient since most modules will require a clock and reset signal.

You can also nest this method.

```lucid
.clk(clk) {
  .rst(rst) {
    dff counter1[12];
    dff counter2[7];
  }
  dff counter3[8];
}
```

Here only _counter1_ and _counter2_ are connected to _rst_.

You can also mix this method with the first.

```lucid
.clk(clk) {
  dff counter1[12](.rst(rst));
  dff counter2[7];
  dff counter3[8];
}
```

Here only _counter1_ is connected to _rst_.

Finally, the last way to specify an input is simply by not connecting it when declaring the module but rather inside an always block later. This is what we did with _counter.d_. Note that _dffs_ and _fsms_ require you to specify _clk_ and _rst_ when declaring them and they do not allow you to specify the _d_ input then.

There is a difference when connecting an input at declaration time or in an always block. The difference only is noticeable for arrays. If you have an array of a module and you specify an input at declaration time, that input will be copied to each element in the array individually.

If you specify an input in an always block, you can specify the input to each element separately. In this example, the _clk_ signal is one bit, but it is getting copied to 25 one bit flip-flops. However, the _d_ input, which is also one bit, is packed into a 25 bit array to use in the always block. That way we can use the _d_ input as if it is really one big flip-flop (which don’t actually exist).

## Instantiating a module

Now that we have a blinker module we need to add it to our top level module.

Open up the top file and make the edits so it looks the same as below.

{% fenced_code_tab(tabs=["Au", "Cu", "Mojo"]) %}
```lucid
module au_top (
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
      blinker myBlinker;
    }
  }
   
  always {
    reset_cond.in = ~rst_n;    // input raw inverted reset signal
    rst = reset_cond.out;      // conditioned reset
     
    led = 8x{myBlinker.blink}; // blink LEDs
     
    usb_tx = usb_rx;           // echo the serial data
  }
}
```
---
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
      blinker myBlinker;
    }
  }
   
  always {
    reset_cond.in = ~rst_n;    // input raw inverted reset signal
    rst = reset_cond.out;      // conditioned reset
     
    led = 8x{myBlinker.blink}; // blink LEDs
     
    usb_tx = usb_rx;           // echo the serial data
  }
}
```
---
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
 
    .rst(rst) {
      blinker myBlinker;
    }
  }
 
  always {
    reset_cond.in = ~rst_n;    // input raw inverted reset signal
    rst = reset_cond.out;      // conditioned reset
 
    led = 8x{myBlinker.blink}; // blink LEDs
    spi_miso = bz;             // not using SPI
    spi_channel = bzzzz;       // not using flags
    avr_rx = bz;               // not using serial port
  }
}
```
{% end %}

In the nested _.clk(clk)_ and _.rst(rst)_ blocks, I instantiated the blinker module and named it _myBlinker_. Notice I'm using the batch way of connecting the _clk_ and _rst_ inputs this time. This is because you will likely want to add more modules to your top level module so it can nice to set it up beforehand.

In the always block, we connect the _blink_ output of _myBlinker_ to the eight LEDs using the duplication syntax covered in the previous tutorial.

You should now be able to build and load the project. All 8 LEDs should blink about two times per second.

## The Reset Conditioner

Now that we have actually used the reset signal for what it was intended for, we can talk about the _reset_conditioner_ module. The signal _rst_n_ comes from outside the FPGA. Signals from outside the FPGA are UNCLEAN! What I mean by this is that we don't know how external signals (especially from a button) will change in relation to the clock we are using. If the reset signal goes low really close to the rising edge of the clock, due to internal delays in the FPGA, some flip-flops may come out of reset before the rising edge while others could after. This means some flip-flops may stay reset for a cycle longer than others (NOT GOOD). Even worse, when signals change too close to a rising edge of a clock you run into metastability issues. This is covered later, but it basically means you aren't guaranteed the output of the flip-flop will be 1 or 0. It could be somewhere in between (0.5?) or even oscillate between values (BAD). This is where the reset conditioner comes in. It is a fairly simple circuit that synchronizes the reset signal to the FPGA's clock. This ensures that your entire design will come out of reset at once. If you want to read more than you'll ever want to know about resets, check out [this paper from Xilinx](http://www.xilinx.com/support/documentation/white_papers/wp272.pdf).