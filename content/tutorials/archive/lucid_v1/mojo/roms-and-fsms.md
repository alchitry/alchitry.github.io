+++
title = "ROMs and FSMs"
weight = 4
+++

In this tutorial we will create a project that will send "Hello World!" over the USB (serial) port when the letter "h" is received. This will help teach you how to use finite state machines (FSM).

## Setup

As with all the tutorials, we first need to create a new project based on the Base Project. I called mine "Hello World" but you are free to choose whatever name you want.

With the new empty project, we now need to add the _avr_interface_ component. This will be used to talk to the AVR and expose a nice interface to send data over the USB port.

You should know how to add a component to your project from the last tutorial. If you need a refresher, [click here](@/tutorials/archive/lucid_v1/mojo/components.md).

The component we need to add is the _AVR Interface_ component and it can be found under _Interfaces_. This component will include a bunch of other components as dependencies.

## The AVR Interface

Let's first take a look at what the _avr_interface_ module looks like.

```lucid
module avr_interface #(
    CLK_FREQ = 50000000 : CLK_FREQ > 0,            // clock frequency
    BAUD = 500000 : BAUD > 0 && BAUD < CLK_FREQ/4  // baud rate
  )(
    input clk,
    input rst,
 
    // cclk, or configuration clock is used when the FPGA is begin configured.
    // The AVR will hold cclk high when it has finished initializing.
    // It is important not to drive the lines connecting to the AVR
    // until cclk is high for a short period of time to avoid contention.
    input cclk,
 
    // AVR SPI Signals
    output spi_miso,           // connect to spi_miso
    input spi_mosi,            // connect to spi_mosi
    input spi_sck,             // connect to spi_sck
    input spi_ss,              // connect to spi_ss
    output spi_channel[4],     // connect to spi_channel
 
    // AVR Serial Signals
    output tx,                 // connect to avr_rx (note that tx->rx)
    input rx,                  // connect to avr_tx (note that rx->tx)
 
    // ADC Interface Signals
    input channel[4],          // ADC channel to read from, use hF to disable ADC
    output new_sample,         // new ADC sample flag
    output sample[10],         // ADC sample data
    output sample_channel[4],  // channel of the new sample
 
    // Serial TX User Interface
    input tx_data[8],          // data to send
    input new_tx_data,         // new data flag (1 = new data)
    output tx_busy,            // transmitter is busy flag (1 = busy)
    input tx_block,            // block the transmitter (1 = block) connect to avr_rx_busy
 
    // Serial Rx User Interface
    output rx_data[8],         // data received
    output new_rx_data         // new data flag (1 = new data)
  ) {
```

We will only be looking at the interface to the module since we don't need to know how it all works to use it properly (the magic of components).

There are lots of comments explaining what the signals are for, but the ones we care about I'll explain in more detail.

### cclk

_cclk_ is a very important signal. When the FPGA is still being configured by the AVR, the AVR uses this to send the configuration data. The signal toggles as data is being sent. However, once the FPGA is up and running, the AVR holds it high. We can then use this to make sure that the FPGA doesn't try to drive it's outputs before the AVR is ready. This is because there is a small window between when the FPGA is configured and when the AVR has initialized its IO for the FPGA post-load. We don't have to worry about this since the _avr_interface_ module will take care of it. We just need to pass the signal in.

### tx and rx

These signals are the serial connection to the AVR. Data sent on these will be sent over the USB port.

### Serial TX and RX User Interfaces

These interfaces have a few signals which we will be using internally to tell the module what data to send and to receive any incoming data. One signal to take note of is the _tx_block_ signal. This is used by the AVR to to do some hand-shaking with the FPGA to make sure the FPGA doesn't send too much data (as it will start dropping bytes). Again we just need to connect this to the correct external signal and everything else is taken care of for us.

## Adding avr_interface to mojo_top

We now can add _avr_interface_ to our top level module, _mojo_top_.

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
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    // connect inputs of avr
    avr.cclk = cclk;
    avr.spi_ss = spi_ss;
    avr.spi_mosi = spi_mosi;
    avr.spi_sck = spi_sck;
    avr.rx = avr_tx;
    avr.channel = hf; // ADC is unused so disable
    avr.tx_block = avr_rx_busy; // block TX when AVR is busy
 
    // connect outputs of avr
    spi_miso = avr.spi_miso;
    spi_channel = avr.spi_channel;
    avr_rx = avr.tx;
 
    led = 8h00;             // turn LEDs off
  }
```

All of the external signals are already defined for us in the Base Project. We simply connect them up. Something to notice is that _avr_tx_ connects to _avr.rx_ and _avr.tx_ connects to _avr_rx_. This is because the signals _avr_rx_ and _avr_tx_ are from the point of view of the AVR, while _avr.rx_ and _avr.tx_ are from the point of view of the FPGA. We want the FPGA's transmitter to connect to the AVR's receiver and visa-versa.

We haven't yet connected all of the signals of _avr_.

## The Serial Interface

### Receiving Data

We will first look at how we know when data comes in.

There are two signals that are important for this, _avr.rx_data_ and _avr.new_rx_data_. Their names are pretty self explanatory. The signal _new_rx_data_ is a single bit wide and acts as a flag. When this signal is 1, the value of _rx_data_ is valid and it's the byte we just received.

This means if we want to wait for a specific byte, we can simply wait for _new_rx_data_ to be high and _rx_data_ to be the value we want. This is exactly what we will do later.

### Transmitting Data

Transmitting data is a tiny bit more complicated since we now have three signals. The signals _avr.new_tx_data_ and _avr.tx_data_ are exactly the same as their rx counterparts, except this time they are inputs to the transmitter, so we generate the values. When we want to send a a byte, we set _tx_data_ to be that byte and pulse _new_tx_data_ high for one clock cycle (if you left it high, the same byte would be sent over and over). There is one more thing to consider, that is that the transmitter can't send an entire byte every clock cycle (the fastest we can provide data). Therefore, we need to look at the third signal, _avr.tx_busy_, to know when it is safe to send more data. This signal will be high when the transmitter is busy. When it is busy, any new data will be ignored. That means we must ensure that this signal is low before we attempt to send any data if we want to ensure we don't drop any bytes.

We will now create two new modules that will deal with all these signals to send "Hello World!" when an "h" is received.

## ROMs

Before we get too deep into generating and handling these signals, we need to create a ROM (**R**ead **O**nly **M**emory).

Our ROM will hold the message we want to send, in our case "Hello World!".

Create a new module named _hello_world_rom_ and add the following to it.

```lucid,linenos
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

We have a single input, _address_, and a single output, _letter_. We want to output the first letter, "H", when address is 0 and the second letter, "e", when address is 1. This continues for each letter in our message.

This is actually pretty simple to do. First we need an array of the data we want to send. This is done in the following line.

```lucid,linenos,linenostart=6
const TEXT = "\r\n!dlroW olleH"; // text is reversed to make 'H' address [0]
```

Here we are using a string to represent our data. Strings of more than one letter are 2D. The first dimension has an index for each letter and the second dimension is 8 bits wide.

Note that the text is reversed. This is because we want, as the comment says, for "H" to be the first letter. Also note that "\n" and "\r" are actually single characters each. That means when we reversed the text we didn't write "n\r\" which would be wrong. These characters will make sure the text is on a new line each time it is sent. "\n" goes to the next line and "\r" returns the cursor to the beginning of the new line.

Next, we simply need to set _letter_ to the correct value in _TEXT_ based on the given _address_. We do that on line 9.

```lucid,linenos,linenostart=9
letter = TEXT[address]; // address indexes 8 bit blocks of TEXT
```

Since the text is reversed, we can simply output the corresponding letter.

This wraps up the ROM!

## The Greeter

This is where we will talk to the _avr_interface_ module to actually send and receive data.

Create a new module named _greeter_ and fill it with the following.

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

The inputs and outputs should look a little familiar. They will connect to the _avr_ module in _mojo_top_.

We are using the constant _NUM_LETTERS_ to specify how big the ROM is. In our case, we have 14 letters to send (this includes the new line characters).

### FSMs

On line 15 we instantiate an FSM.

```lucid,linenos,linenostart=15
fsm state = {IDLE, GREET};
```

**fsm** is similar to **dff** in that they both have _.clk_, _.rst_, and _.d_ inputs and a _.q_ output. They behave much the same way, with one important exception. FSMs are used to store a state, not a value.

In this example, our FSM can have one of two states, _IDLE_ or _GREET_. In a more complicated example we could add more states to our FSM simply by adding them to the list.

To access a state, we can use _state.IDLE_ or _state.GREET_. This is done in the case statement (covered below) as well as when we assign a new state to _state_.

### Functions

```lucid,linenos,linenostart=17
dff count[$clog2(NUM_LETTERS)]; // min bits to store NUM_LETTERS - 1
```

Here we are declaring a counter that will be use to keep track of what letter we are on. That means we need the counter to be able to count from 0 to _NUM_LETTERS_ - 1. How do we know how many bits we will need when _NUM_LETTERS_ is a constant? We could simply compute this by hand and type in the value. However, this is fragile since it would be easy to change _NUM_LETTERS_ and forget to change the counter size. This is where the function _$clog2()_ comes in handy. This function will compute the ceiling log base 2 of the value passed to it. This happens to be the number of bits you need to store the values from 0 to one minus the argument. How convenient! Just what we needed.

It is important to note that this function can only be used with constants or constant expressions. This is because the tools will compute the value at runtime. Your circuit isn't doing anything fancy here. Computing this function in hardware would be far too complicated for a single line to properly handle.

### Saying Hello

We instantiate a copy of our _hello_world_rom_ and call it _rom_ so we know what data to send.

Since we are only going to be sending the letters from the ROM, we can wire them up directly to _tx_data_.

```lucid
hello_world_rom rom;
 
always {
  rom.address = count.q;
  tx_data = rom.letter;
```

We also can set the ROM's address to simply be the output of our counter since that's what the counter is for!

### Case Statements

**Case statements** are an easy way to do a bunch of different things depending on the value of something. You could always use a bunch of **if statements** but this can be way more compact and easier to read.

The general syntax for a **case statement** is below.

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

When _state.q_ is _state.IDLE_, we only look at the lines 30-32. However, when _state.q_ is _state.GREET_ we only look at lines 35-40.

### Putting it all Together

So how does it all work? Since _IDLE_ was the first state we listed, it is, by default, the default state. You can specify an alternate default state by using the parameter _#INIT(STATE_NAME)_.

Because we start in the idle state, the counter is set to 0 and we do nothing until we see "h". To wait for "h" we wait for _new_rx_ to be high and _rx_data_ to be "h".

Once we receive an "h", we change states to _state.GREET_

Here we wait for _tx_busy_ to be low to signal we can send data. We then increment the counter for next time and signal we have a new letter to send by setting _new_tx_ high. Remember we already set _tx_data_ as the output of our ROM.

Once we are out of letters, we return to the idle state to wait for another "h".

## Adding the Greeter to mojo_top

Finally we need to add the _greeter_ module to _mojo_top_

First, let's add an instance of it.

```lucid
.clk(clk), .rst(~rst_n){
   // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
   avr_interface avr;
 
   greeter greeter; // instance of our greeter
 }
```

Next, we need to connect it up.

```lucid
greeter.new_rx = avr.new_rx_data;
greeter.rx_data = avr.rx_data;
avr.new_tx_data = greeter.new_tx;
avr.tx_data = greeter.tx_data;
greeter.tx_busy = avr.tx_busy;
```

That's it! Go ahead, build your project and load it on your Mojo. You can then fire up a serial monitor and send "h" to your board to be nicely greeted!