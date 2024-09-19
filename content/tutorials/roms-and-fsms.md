+++
title = "ROMs and FSMs"
weight = 5
inline_language = "lucid"
date = "2024-09-19"
+++

In this tutorial we will create a project that will send "Hello World!" over the USB (serial) port when the letter "h" is received. 
This will help teach you how to use finite state machines (FSM).

<!-- more -->

# Setup

We first need to create a new project based on the Base Project. 
I called mine _Hello World_ but you are free to choose whatever name you want.

With the new empty project, we now need to add the `uartTx` and `uartRx` components. 
These will be used to talk to the FTDI chip and send data over the USB port.

You should know how to add a component to your project from the last tutorial. 
If you need a refresher, [click here](@/tutorials/serial-interface.md).

The components we need to add are the _UART Tx_ and _UART Rx_ components, and they can be found under _Interfaces_.

![Serial Components](https://cdn.alchitry.com/tutorials/serial-interface/serial-components.png)

# UART Tx

Let's first take a look at what the module looks like.

```lucid
module uartTx #(
    CLK_FREQ ~ 100000000 : CLK_FREQ > 0,            // clock frequency
    BAUD ~ 1000000 : BAUD > 0 && BAUD <= CLK_FREQ/2 // desired baud rate
)(
    input clk,          // clock
    input rst,          // reset active high
    output tx,          // TX output
    input block,        // block transmissions
    output busy,        // module is busy when 1
    input data[8],      // data to send
    input newData       // flag for new data
) {
```

We will only be looking at the interfaces to the modules since we don't need to know how it all works to use it properly (the magic of components).

This module is responsible for transmitting data. 
When we have a byte to send, we first need to check that `busy` is `0`. 
When this signal is `1`, any data we provide will be ignored. 
Assuming `busy` is `0`, we then provide the data to send on `data` and signal that the data is valid by setting `newData` to `1`. 
This will cause the module to transmit the byte one bit at a time over `tx`.

The input `block` is used when you have some way of knowing that the device receiving the data upstream (the FTDI chip in this case) is busy. 
When `block` is `1`, the module won't transmit data. 
Since we don't have a way to tell when the FTDI can't hold more data, and it isn't a concern when the data is being read by an application on the PC side, we can set this permanently to `0`.

This module has two parameters you need to set in order to get it to work properly. 
The first one `CLK_FREQ` is simply the frequency of the clock you are providing it. 
If you are using the clock on the Alchitry board, this will be `100_000_000`, or 100MHz.

The second parameter, `BAUD` is used to set the rate of bits per second to send.

When a parameter is declared for a module, you only need to specify a name. 
However, you can also specify a default value and some value constraints.

The default value is set by using the equals sign.

You can also specify a test value instead of a default value by using `~` instead of `=`.
A test value is used when checking the module for errors but will still force a value to be provided when the module is instantiated.

Typically, parameters are just numbers, but they can be more complex values like arrays.
If you want to accept a multidimensional array, you need to specify the dimensions with the default or test value.
Parameters without a default or test value are assumed to be a simple number.
See the [reference guide](@/tutorials/lucid-reference.md#parameters) for more info.

Constrains on the parameter's value can be set with a boolean statement after a colon. 
This expression will be evaluated when the module is instantiated and an error will be thrown when it fails (has a value of 0). 
It is recommended to add these constraints if you make any assumptions about the parameter values.

For both `CLK_FREQ` and `BAUD` it makes sense that they are not negative. 
For the module to work, the clock frequency needs to be at least twice the baud rate. 
Note that the closer you get to this limit, the more careful you need to be with choosing your baud rate. 
If the clock frequency isn't divisible by the baud rate then it will approximate the baud rate with the closest higher value.

# UART Rx

```lucid
module uartRx #(
    CLK_FREQ ~ 100000000 : CLK_FREQ > 0,            // clock frequency
    BAUD = 1000000 : BAUD > 0 && BAUD <= CLK_FREQ/4 // desired baud rate
)(
    input clk,      // clock input
    input rst,      // reset active high
    input rx,       // UART rx input
    output data[8], // received data
    output newData  // new data flag (1 = new data)
) {
```

This module is responsible for receiving data on the `rx` input and sending it out as bytes on `data`. 
The value of `data` is valid only when `newData` is 1.

The parameters for this module are more or less the same as before with the small exception that `BAUD` is constrained to a quarter of `CLK_FREQ` instead of half. 
This is due to the internal working of the module. 
Once it detects new incoming data, it waits half a cycle so that it will be sampling the data in the middle of the bit instead of the edge for reliability.

# Using the Modules

We now can add `uartTx` and `uartRx` to our top level module.

```lucid,linenos
module alchitryTop (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usbRx,            // USB->Serial input
    output usbTx            // USB->Serial output
) {
    
    sig rst                 // reset signal
    
    .clk(clk) {
        // The reset conditioner is used to synchronize the reset signal to the FPGA
        // clock. This ensures the entire FPGA comes out of reset at the same time.
        resetConditioner resetCond
        
        .rst(rst) {
            uartRx rx(#BAUD(1_000_000), #CLK_FREQ(100_000_000))
            uartTx tx(#BAUD(1_000_000), #CLK_FREQ(100_000_000))
        }
    }
    
    always {
        resetCond.in = ~rst_n  // input raw inverted reset signal
        rst = resetCond.out    // conditioned reset
        
        led = 8h00             // turn LEDs off
        
        rx.rx = usbRx          // connect rx input
        usbTx = tx.tx          // connect tx output
        
        tx.newData = 0         // no new data by default
        tx.data = 8bx          // don't care when newData is 0
        tx.block = 0           // no flow control, do not block
    }
}
```

All the external signals are already defined for us in the Base Project. 
We simply connect them up.

We can actually make the instantiation of these two modules a bit cleaner. 
Both `uartTx` and `uartRx` have the same parameters, and we want their values to be the same. 
This means we can group them in to a connection block just like we do for `clk` and `rst`.

```lucid,linenos,linenostart=11
    .clk(clk) {
        // The reset conditioner is used to synchronize the reset signal to the FPGA
        // clock. This ensures the entire FPGA comes out of reset at the same time.
        resetConditioner resetCond
        
        .rst(rst) {
            #BAUD(1_000_000), #CLK_FREQ(100_000_000) {
                uartRx rx
                uartTx tx
            }
        }
    }
```

We could have also combined these with the `.rst(rst)` assignment, but we will be adding another module to that block later so it is nice to have them separate.

Currently, we are ignoring any data from the receiver and never sending data on the transmitter.

All inputs to modules need to be assigned a value. 
However, since we are setting `tx.newData` to 0, we really don't care what value gets assigned to `tx.data` since it will never be used. 
In cases like this, the value of `bx` is helpful. 
There isn't really a value associated with `bx`. 
Instead, this tells the synthesizer that we don't care what value it uses. 
This gives it freedom to optimize our design instead of being forced to use an arbitrary useless value like `0`.

We will now create two new modules that will actually deal with all these signals to send `"Hello World!"` when an `"h"` is received.

# ROMs

Before we get too deep into generating and handling these signals, we need to create a ROM (**R**ead **O**nly **M**emory).

Our ROM will hold the message we want to send, in our case `"Hello World!"`.

Create a new module named _helloWorldRom_ and add the following to it.

```lucid,linenos
module helloWorldRom (
    input address[4], // ROM address
    output letter[8]  // ROM output
) {
    
    const TEXT = "\r\n!dlroW olleH" // text is reversed to make 'H' address [0]
    
    always {
        letter = TEXT[address] // address indexes 8 bit blocks of TEXT
    }
}
```

We have a single input, `address`, and a single output, `letter`. 
We want to output the first letter, `"H"`, when address is `0` and the second letter, `"e"`, when address is `1`. 
This continues for each letter in our message.

This is actually pretty simple to do. 
First we need an array of the data we want to send. 
This is done in the following line.

```lucid,linenos,linenostart=6
const TEXT = "\r\n!dlroW olleH" // text is reversed to make 'H' address [0]
```

Here we are using a string to represent our data. 
Strings of more than one letter are 2D arrays. 
The first dimension has an index for each letter and the second dimension is 8 bits wide.

Note that the text is reversed. 
This is because we want, as the comment says, for `"H"` to be the first letter. 
Also note that `"\n"` and `"\r"` are actually single characters each. 
That means when we reversed the text we didn't write `"n\r\"` which would be wrong. 
These characters will make sure the text is on a new line each time it is sent. 
`"\n"` goes to the next line and `"\r"` returns the cursor to the beginning of the new line.

Next, we simply need to set `letter` to the correct value in `TEXT` based on the given `address`. 
We do that on line 9.

```lucid,linenos,linenostart=9
letter = TEXT[address] // address indexes 8 bit blocks of TEXT
```

Since the text is reversed, we can simply output the corresponding letter.

This wraps up the ROM!

# The Greeter

This is where we will talk to the UART modules to actually send and receive data.

Create a new module named `greeter` and fill it with the following.

```lucid,linenos
module greeter (
    input clk,        // clock
    input rst,        // reset
    input newRx,      // new RX flag
    input rxData[8],  // RX data
    output newTx,     // new TX flag
    output txData[8], // TX data
    input txBusy      // TX is busy flag
) {
    const NUM_LETTERS = 14
    
    enum States {IDLE, GREET}
    
    .clk(clk) {
        .rst(rst) {
            dff state[$width(States)]
        }
        dff count[$clog2(NUM_LETTERS)] // min bits to store NUM_LETTERS - 1
    }
    
    helloWorldRom rom
    
    always {
        rom.address = count.q
        txData = rom.letter
        
        newTx = 0 // default to 0
        
        case (state.q) {
            States.IDLE:
                count.d = 0
                if (newRx && rxData == "h")
                    state.d = States.GREET
            
            States.GREET:
                if (!txBusy) {
                    count.d = count.q + 1
                    newTx = 1
                    if (count.q == NUM_LETTERS - 1)
                        state.d = States.IDLE
                }
        }
    }
}
```

The inputs and outputs should look a little familiar. They will connect to the `uartTx` and `uartRx` modules in our top level.

We are using the constant `NUM_LETTERS` to specify how big the ROM is. 
In our case, we have 14 letters to send (this includes the new line characters).

## Enums and FSMs

On line 12 we define an `enum`.

```lucid,linenos,linenostart=12
enum States {IDLE, GREET}
```

An `enum` is just a way to conveniently declare a group of constants that you don't particularly care about their values.
You just need them to be different from each other.

We will be using this `enum` in conjunction with `dff state` to create an FSM (**F**inite **S**tate **M**achine).

Note that the width of `state` is defined as `$width(States)`.
This ensures that `state` is wide enough to hold any value in `States`.

In this example, our FSM can have one of two states, `IDLE` or `GREET`. 
In a more complicated example we could add more states to our FSM simply by adding them to the list.

To access a state, we can use `States.IDLE` or `States.GREET`. 
This is done in the case statement (covered below) as well as when we assign a new state to `state`.

## Functions

```lucid,linenos,linenostart=18
dff count[$clog2(NUM_LETTERS)] // min bits to store NUM_LETTERS - 1
```

Here we are declaring a counter that will be used to keep track of what letter we are on. 
That means we need the counter to be able to count from `0` to `NUM_LETTERS - 1`. 
How do we know how many bits we will need when `NUM_LETTERS` is a constant? 
We could simply compute this by hand and type in the value. 
However, this is fragile since it would be easy to change `NUM_LETTERS` and forget to change the counter size. 
This is where the function `$clog2()` comes in handy. 
This function will compute the ceiling log base 2 of the value passed to it. 
This happens to be the number of bits you need to store the values from `0` to one minus the argument. 
How convenient! 
Just what we needed.

You can check out the [reference guide](@/tutorials/lucid-reference.md#built-in) for more functions.

It is important to note that this function can only be used with constants or constant expressions. 
This is because the tools will compute the value during synthesis. 
Your circuit isn't doing anything fancy here. 
Computing this function in hardware would be far too complicated for a single line to properly handle.

## Saying Hello

We instantiate a copy of our `helloWorldRom` and call it `rom` so we know what data to send.

Since we are only going to be sending the letters from the ROM, we can wire them up directly to _txData_.

```lucid,linenos,linenostart=21
helloWorldRom rom

always {
    rom.address = count.q
    txData = rom.letter
```

We also can set the ROM's address to simply be the output of our counter since that's what the counter is for!

## Case Statements

`case` statements are an easy way to do a bunch of different things depending on the value of something. 
You could always use a bunch of `if` statements but this can be way more compact and easier to read.

The general syntax for a `case` statement is below.

```lucid
case (expr) {
  const: statements
  const: statements
  const: statements
  default: statements
}
```

You pass in some expression and then have a bunch of blocks of statements that are considered based on the value of that expression. 
It sounds way more complicated than it is. Let's look at our example.

```lucid,linenos,linenostart=29
case (state.q) {
    States.IDLE:
        count.d = 0
        if (newRx && rxData == "h")
            state.d = States.GREET
    
    States.GREET:
        if (!txBusy) {
            count.d = count.q + 1
            newTx = 1
            if (count.q == NUM_LETTERS - 1)
                state.d = States.IDLE
        }
}
```

When `state.q` is `States.IDLE`, we only look at the lines 31-33. However, when `state.q` is `States.GREET` we only look at lines 36-41.

## Putting it all Together

So how does it all work? 
Since `IDLE` was the first state we listed, it is, by default, the default state. 
You can specify an alternate default state by using the parameter `#INIT(STATE_NAME)` on the `dff`.

Because we start in the idle state, the counter is set to `0`, and we do nothing until we see `"h"`. 
To wait for `"h"` we wait for `newRx` to be high and `rxData` to be `"h"`.

Once we receive an `"h"`, we change states to `States.GREET`.

Here we wait for `txBusy` to be low to signal we can send data. 
We then increment the counter for next time and signal we have a new letter to send by setting `newTx` high. 
Remember we already set `txData` as the output of our ROM.

Once we are out of letters, we return to the idle state to wait for another `"h"`.

# Adding the Greeter to the Top Module

Finally, we need to add the `greeter` module to our top module.

First, let's add an instance of it.

```lucid,linenos,linenostart=11
    .clk(clk) {
        // The reset conditioner is used to synchronize the reset signal to the FPGA
        // clock. This ensures the entire FPGA comes out of reset at the same time.
        resetConditioner resetCond
        
        .rst(rst) {
            #BAUD(1_000_000), #CLK_FREQ(100_000_000) {
                uartRx rx
                uartTx tx
            }
            
            greeter greeter
        }
    }
```

Next, we need to connect it up.

```lucid,linenos,linenostart=26
always {
    resetCond.in = ~rst_n  // input raw inverted reset signal
    rst = resetCond.out    // conditioned reset
    
    led = 8h00             // turn LEDs off
    
    rx.rx = usbRx          // connect rx input
    usbTx = tx.tx          // connect tx output
    
    greeter.newRx = rx.newData
    greeter.rxData = rx.data
    tx.newData = greeter.newTx
    tx.data = greeter.txData
    greeter.txBusy = tx.busy
    tx.block = 0           // no flow control, do not block
}
```

That's it! 
Go ahead, build your project and load it on your board. 
You can then fire up a serial terminal and send `"h"` to your board to be nicely greeted!