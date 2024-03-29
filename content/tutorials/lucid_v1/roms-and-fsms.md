+++
title = "ROMs and FSMs"
weight = 4
+++

In this tutorial we will create a project that will send "Hello World!" over the USB (serial) port when the letter "h" is received. This will help teach you how to use finite state machines (FSM).

## Setup

As with all the tutorials, we first need to create a new project based on the Base Project. I called mine "Hello World" but you are free to choose whatever name you want.

With the new empty project, we now need to add the _uart_tx_ and _uart_rx_ components. This will be used to talk to the FTDI chip and send data over the USB port.

You should know how to add a component to your project from the last tutorial. If you need a refresher, [click here](@/tutorials/lucid_v1/components.md).

The components we need to add are the _UART TX_ and _UART RX_ components and they can be found under _Protocols_.

## UART Tx

Let's first take a look at what the module looks like.

```lucid
module uart_tx #(
    CLK_FREQ = 50000000 : CLK_FREQ > 0,            // clock frequency
    BAUD = 500000 : BAUD > 0 && BAUD <= CLK_FREQ/2 // desired baud rate
  )(
    input clk,          // clock
    input rst,          // reset active high
    output tx,          // TX output
    input block,        // block transmissions
    output busy,        // module is busy when 1
    input data[8],      // data to send
    input new_data      // flag for new data
  ) {
```

We will only be looking at the interfaces to the modules since we don't need to know how it all works to use it properly (the magic of components).

This module is responsible for transmitting data. When we have a byte to send, we first need to check that _busy_ is 0. When this signal is 1, any data we provide will be ignored. Assuming _busy_ is 0, we then provide the data to send on _data_ and signal that the data is valid by setting _new_data_ to 1. This will cause the module to transmit the byte one bit at a time over _tx_.

The input _block_ is used when you have some way of knowing that the device receiving the data upstream (the FTDI chip in this case) is busy. When _block_ is 1, the module won't transmit data. Since we don't have a way to tell when the FTDI can't hold more data and it isn't a concern when the data is being read by an application on the PC side, we can set this permanently to 0.

This module has two parameters you need to set in order to get it to work properly. The first one _CLK_FREQ_ is simply the frequency of the clock you are providing it. If you are using the default clock on the Au or Cu, this will be 100000000, or 100MHz.

The second parameter, _BAUD_ is used to set the rate of bits per second to send. Alchitry Labs' serial monitor expects to use 1M baud so we will set this to 1000000 later.

When a parameter is declared for a module, you only need to specify a name. However, you can also specify a default value and some value constraints.

The default value is set by using the equals sign.

Constrains on the parameter's value can be set with a boolean statement after a colon. This expression will be evaluated when the module is instantiated and an error will be thrown when it fails (has a value of 0). It is recommend to add these constraints if you make any assumptions about the parameter values.

For both _CLK_FREQ_ and _BAUD_ it makes sense that they are not negative. For the module to work, the clock frequency needs to be at least twice the baud rate. Note that the closer you get to this limit, the more careful you need to be with choosing your baud rate. If the clock frequency isn't divisible by the baud rate then it will approximate the baud rate with the closest higher value.

## UART Rx

```lucid
module uart_rx #(
    CLK_FREQ = 50000000 : CLK_FREQ > 0,            // clock frequency
    BAUD = 500000 : BAUD > 0 && BAUD <= CLK_FREQ/4 // desired baud rate
  )(
    input clk,      // clock input
    input rst,      // reset active high
    input rx,       // UART rx input
    output data[8], // received data
    output new_data // new data flag (1 = new data)
  ) {
```

This module is responsible for receiving data on the _rx_ input and sending it out as bytes on _data_. The value of _data_ is valid only when _new_data_ is 1.

The parameters for this module are more or less the same as before with the small exception that _BAUD_ is constrained to a quarter of _CLK_FREQ_ instead of half. This is due to the internal working of the module. Once it detects new incoming data, it waits half a cycle so that it will be sampling the data in the middle of the bit instead of the edge for reliability.

## Using the Modules

We now can add _uart_tx_ and _uart_rx_ to our top level module.

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
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    rx.rx = usb_rx;         // connect rx input
    usb_tx = tx.tx;         // connect tx output
 
    tx.new_data = 0;        // no new data by default
    tx.data = 8bx;          // don't care when new_data is 0   
    tx.block = 0;           // no flow control, do not block
 
    led = 8h00;             // turn LEDs off
  }
}
```

All of the external signals are already defined for us in the Base Project. We simply connect them up.

We can actually make the instantiation of these two modules a bit cleaner. Both _uart_tx_ and _uart_rx_ have the same parameters and we want their values to be the same. This means we can group them in to a connection block just like we do for _clk_ and _rst_.

```lucid
.clk(clk) {
  // The reset conditioner is used to synchronize the reset signal to the FPGA
  // clock. This ensures the entire FPGA comes out of reset at the same time.
  reset_conditioner reset_cond;
 
  .rst(rst) {
    #BAUD(1000000), #CLK_FREQ(100000000) {
      uart_rx rx;
      uart_tx tx;
    }
  }
}
```

We could have also combined these with the _.rst(rst)_ assignment, but we will be adding another module to that block later so it is nice to have them separate.

Currently we are ignoring any data from the receiver and never sending data on the transmitter.

All inputs to modules need to be assigned a value. However, since we are setting _tx.new_data_ to 0, we really don't care what value gets assigned to _tx.data_ since it will never be used. In cases like this, the value of 'x' is helpful. There isn't really a value associated with 'x'. Instead, this tells the synthesizer that we don't care what value it uses. This gives it freedom to optimize our design instead of being forced to use an arbitrary useless value like 0.

We will now create two new modules that will actually deal with all these signals to send "Hello World!" when an "h" is received.

## ROMs

Before we get too deep into generating and handling these signals, we need to create a ROM (**R**ead **O**nly **M**emory).

Our ROM will hold the message we want to send, in our case "Hello World!".

Create a new module named _hello_world_rom_ and add the following to it.

```lucid
module hello_world_rom (
    input address[4],  // ROM address
    output letter[8]   // ROM output
  ) {
 
  const TEXT = "\r\n!dlroW olleH"; // text is reversed to make 'H' address [0]
 
  always {
    letter = TEXT[address]; // address indexes 8 bit blocks of TEXT
  }
}
```

We have a single input, _address_, and a single output, _letter_. We want to output the first letter, "H", when address is 0 and the second letter, "e", when address is 1. This continues for each letter in our message.

This is actually pretty simple to do. First we need an array of the data we want to send. This is done in the following line.

```lucid
const TEXT = "\r\n!dlroW olleH"; // text is reversed to make 'H' address [0]
```

Here we are using a string to represent our data. Strings of more than one letter are 2D. The first dimension has an index for each letter and the second dimension is 8 bits wide.

Note that the text is reversed. This is because we want, as the comment says, for "H" to be the first letter. Also note that "\n" and "\r" are actually single characters each. That means when we reversed the text we didn't write "n\r\" which would be wrong. These characters will make sure the text is on a new line each time it is sent. "\n" goes to the next line and "\r" returns the cursor to the beginning of the new line.

Next, we simply need to set _letter_ to the correct value in _TEXT_ based on the given _address_. We do that on line 9.

```lucid
letter = TEXT[address]; // address indexes 8 bit blocks of TEXT
```

Since the text is reversed, we can simply output the corresponding letter.

This wraps up the ROM!

## The Greeter

This is where we will talk to the UART modules to actually send and receive data.

Create a new module named _greeter_ and fill it with the following.

```lucid,linenos
module greeter (
    input clk,         // clock
    input rst,         // reset
    input new_rx,      // new RX flag
    input rx_data[8],  // RX data
    output new_tx,     // new TX flag
    output tx_data[8], // TX data
    input tx_busy      // TX is busy flag
  ) {
 
  const NUM_LETTERS = 14;
 
  .clk(clk) {
    .rst(rst) {
      fsm state = {IDLE, GREET};
    }
    dff count[$clog2(NUM_LETTERS)]; // min bits to store NUM_LETTERS - 1
  }
 
  hello_world_rom rom;
 
  always {
    rom.address = count.q;
    tx_data = rom.letter;
 
    new_tx = 0; // default to 0
 
    case (state.q) {
      state.IDLE:
        count.d = 0;
        if (new_rx && rx_data == "h")
          state.d = state.GREET;
 
      state.GREET:
        if (!tx_busy) {
          count.d = count.q + 1;
          new_tx = 1;
          if (count.q == NUM_LETTERS - 1)
            state.d = state.IDLE;
        }
    }
  }
}
```

The inputs and outputs should look a little familiar. They will connect to the _uart_tx_ and _uart_rx_ modules in our top level.

We are using the constant _NUM_LETTERS_ to specify how big the ROM is. In our case, we have 14 letters to send (this includes the new line characters).

### FSMs

On line 15 we instantiate an FSM.

```lucid,linenos,linenostart=15
fsm state = {IDLE, GREET};
```

**fsm** is similar to **dff** in that they both have _.clk_, _.rst_, and _.d_ inputs and a _.q_ output. They behave much the same way, with one important exception. FSMs are used to store a state, not a value.

In this example, our FSM can have one of two states, _IDLE_ or _GREET_. In a more complicated example we could add more states to our FSM simply by adding them to the list.

To access a state, we can use _state.IDLE_ or _state.GREET_. This is done in the case statement (covered below) as well as when we assign a new state to _state_.

### Functions

```lucid
dff count[$clog2(NUM_LETTERS)]; // min bits to store NUM_LETTERS - 1
```

Here we are declaring a counter that will be use to keep track of what letter we are on. That means we need the counter to be able to count from 0 to _NUM_LETTERS_ - 1. How do we know how many bits we will need when _NUM_LETTERS_ is a constant? We could simply compute this by hand and type in the value. However, this is fragile since it would be easy to change _NUM_LETTERS_ and forget to change the counter size. This is where the function _$clog2()_ comes in handy. This function will compute the ceiling log base 2 of the value passed to it. This happens to be the number of bits you need to store the values from 0 to one minus the argument. How convenient! Just what we needed.

It is important to note that this function can only be used with constants or constant expressions. This is because the tools will compute the value during synthesis. Your circuit isn't doing anything fancy here. Computing this function in hardware would be far too complicated for a single line to properly handle.

### Saying Hello

We instantiate a copy of our _hello_world_rom_ and call it _rom_ so we know what data to send.

Since we are only going to be sending the letters from the ROM, we can wire them up directly to _tx_data_.

```lucid
hello_world_rom rom;
 
always {
  rom.address = count.q;
  tx_data = rom.letter;
```

We also can set the ROM's address to simply be the output of our counter since that's what the counter is for!

### Case Statements

**Case statements** are an easy way to do a bunch of different things depending on the value of something. You could always use a bunch of **if statements** but this can be way more compact and easier to read.

The general syntax for a **case statement** is below.

```lucid
case (expr) {
  const: statements
  const: statements
  const: statements
  const: statements
  default: statements
}
```

Basically, you pass in some expression and then have a bunch of blocks of statements that are considered based on the value of that expression. It sounds way more complicated than it is. Let's look at our example.

```lucid
case (state.q) {
  state.IDLE:
    count.d = 0;
    if (new_rx && rx_data == "h")
      state.d = state.GREET;
 
  state.GREET:
    if (!tx_busy) {
      count.d = count.q + 1;
      new_tx = 1;
      if (count.q == NUM_LETTERS - 1)
        state.d = state.IDLE;
    }
}
```

When _state.q_ is _state.IDLE_, we only look at the lines 30-32. However, when _state.q_ is _state.GREET_ we only look at lines 35-40.

### Putting it all Together

So how does it all work? Since _IDLE_ was the first state we listed, it is, by default, the default state. You can specify an alternate default state by using the parameter _#INIT(STATE_NAME)_.

Because we start in the idle state, the counter is set to 0 and we do nothing until we see "h". To wait for "h" we wait for _new_rx_ to be high and _rx_data_ to be "h".

Once we receive an "h", we change states to _state.GREET_

Here we wait for _tx_busy_ to be low to signal we can send data. We then increment the counter for next time and signal we have a new letter to send by setting _new_tx_ high. Remember we already set _tx_data_ as the output of our ROM.

Once we are out of letters, we return to the idle state to wait for another "h".

## Adding the Greeter to the Top Module

Finally we need to add the _greeter_ module to our top module.

First, let's add an instance of it.

```lucid
.clk(clk) {
  // The reset conditioner is used to synchronize the reset signal to the FPGA
  // clock. This ensures the entire FPGA comes out of reset at the same time.
  reset_conditioner reset_cond;
 
  .rst(rst) {
    #BAUD(1000000), #CLK_FREQ(100000000) {
      uart_rx rx;
      uart_tx tx;
    }
 
    greeter greeter; // instance of our greeter
  }
}
```

Next, we need to connect it up.

```lucid
always {
  reset_cond.in = ~rst_n; // input raw inverted reset signal
  rst = reset_cond.out;   // conditioned reset
 
  rx.rx = usb_rx;         // connect rx input
  usb_tx = tx.tx;         // connect tx output
 
  greeter.new_rx = rx.new_data;
  greeter.rx_data = rx.data;
  tx.new_data = greeter.new_tx;
  tx.data = greeter.tx_data;
  greeter.tx_busy = tx.busy;
  tx.block = 0;
 
  led = 8h00;             // turn LEDs off
}
```

That's it! Go ahead, build your project and load it on your board. You can then fire up a serial monitor (Tools->Serial Port Monitor) and send "h" to your board to be nicely greeted!