+++
title = "Register Interface"
weight = 7
inline_language = "lucid"
date = "2025-04-28"
+++

This tutorial will introduce you to the _Register Interface_ component and how you can use it to easily implement
complex interfaces in your designs.

<!-- more -->

# Introduction

Sometimes dealing with an interface, like the [serial interface](@/tutorials/serial-interface.md), directly can become
quite complicated depending on what you are trying to implement.
The _Register Interface_ component provides an abstraction on top of a basic interface (usually the USB<->Serial port,
but it doesn't have to be).

The abstraction it provides is a _register_ based one.
The FPGA acts as a peripheral and responds to read and write requests targeted at specific addresses.

You've likely seen a register interface many times if you've worked with anything over I2C or SPI.
Datasheets will list the registers you can read and write and what the bits in each one does.

In the most basic case, the thing you are reading and writing is actually a register.
However, it doesn't _have_ to be.
Instead, you can respond to the reads/writes however you see fit.

For example, you might choose to respond to a read at address 8 with data from a FIFO.
Each time address 8 is read, you remove a value from the FIFO and return it.
This is a common case when you are implementing something that collects data and needs to stream it out to the host.

Enough theoretical, let's jump into the actual interface.

# The Register Interface Component

In Alchitry Labs, open a New Project using the base template and name it whatever you want.
I'm calling mine _Register Interface Demo_. 
Now, open the _Component Library_ and add the _Register Interface_ (under _Interfaces_) to your project.
You will also likely want to add the _UART Rx_ and _UART Tx_ components if you plan to use the interface with the 
built-in USB port.

Here's the full module.

```lucid,short,linenos,linenostart=34
global Register {
    struct request {                                // request device outputs
        new_cmd,                                    // 1 = new command
        write,                                      // 1 = write, 0 = read
        address[32],                                // address to read/write
        data[32]                                    // data to write (ignore on reads)
    }
    struct response {                               // response inputs
        data[32],                                   // data read from requested address
        drdy                                        // read data valid (1 = valid)
    }
}

module register_interface #(
    CLK_FREQ ~ 100000000 : CLK_FREQ > 0
)(
    input clk,                                     // clock
    input rst,                                     // reset

    // Serial RX Interface
    input rx_data[8],                              // data received
    input new_rx_data,                             // new data flag (1 = new data)

    // Serial Tx Interface
    output tx_data[8],                             // data to send
    output new_tx_data,                            // new data flag (1 = new data)
    input tx_busy,                                 // transmitter is busy flag (1 = busy)

    // Register Interface
    output reg_out<Register.request>,              // register outputs
    input reg_in<Register.response>                // register inputs
) {

    enum States {IDLE, GET_ADDR, WRITE, REQUEST_WRITE, REQUEST_READ, WAIT_READ, READ_RESULT}

    .clk(clk) {
        .rst(rst) {
            dff state[$width(States)](#INIT(States.IDLE))
        }

        dff addr_ct [6]                              // address counter
        dff byte_ct [2]                              // byte counter
        dff inc                                      // increment flag
        dff wr                                       // write flag
        dff timeout[$clog2(CLK_FREQ / 4)]            // timeout counter
        dff addr [32]                                // saved address
        dff data [32]                                // saved data
    }

    always {
        // defaults
        reg_out.new_cmd = 0                          // no new command
        reg_out.write = bx                           // don't care
        reg_out.address = addr.q                     // output addr
        reg_out.data = data.q                        // output data
        tx_data = bx                                 // don't care
        new_tx_data = 0                              // no new data

        timeout.d = timeout.q + 1                    // increment timeout counter
        if (new_rx_data)                             // if new serial data
            timeout.d = 0                            // reset counter

        case (state.q) {
            States.IDLE:
                timeout.d = 0                        // reset timeout
                byte_ct.d = 0                        // reset byte count

                if (new_rx_data) {                   // if new data
                    wr.d = rx_data[7]                // bit 7 is write flag
                    inc.d = rx_data[6]               // bit 6 is auto increment flag
                    addr_ct.d = rx_data[5:0]         // 7 LSBs are number of addresses to read/write (+1)
                    state.d = States.GET_ADDR        // read in address bytes
                }

            States.GET_ADDR:
                if (new_rx_data) {                        // if new data
                    addr.d = c{rx_data, addr.q[31-:24]}   // shift in byte
                    byte_ct.d = byte_ct.q + 1             // increment byte count
                    if (byte_ct.q == 3) {                 // if received all 4 bytes
                        if (wr.q)                         // if write
                            state.d = States.WRITE        // switch to WRITE
                        else                              // else
                            state.d = States.REQUEST_READ // switch to REQUEST_READ
                    }
                }

            States.WRITE:
                if (new_rx_data) {                        // if new data
                    data.d = c{rx_data, data.q[31-:24]}   // shift in data
                    byte_ct.d = byte_ct.q + 1             // increment byte count
                    if (byte_ct.q == 3)                   // if received all 4 bytes
                        state.d = States.REQUEST_WRITE    // request the write
                }

            States.REQUEST_WRITE:
                reg_out.new_cmd = 1                       // new command!
                reg_out.write = 1                         // it's a write
                addr_ct.d = addr_ct.q - 1                 // decrement address count
                if (addr_ct.q == 0) {                     // if no more commands to issue
                    state.d = States.IDLE                 // return to idle
                } else {                                  // else
                    state.d = States.WRITE                // read in other data to write
                    if (inc.q)                            // if auto-increment
                        addr.d = addr.q + 1               // increment the address
                }

            States.REQUEST_READ:
                reg_out.new_cmd = 1                       // new command!
                reg_out.write = 0                         // it's a read
                if (reg_in.drdy) {                        // if result valid
                    data.d = reg_in.data                  // save the value
                    state.d = States.READ_RESULT          // send it out
                } else {
                    state.d = States.WAIT_READ            // wait for the result
                }

            States.WAIT_READ:
                if (reg_in.drdy) {                        // if result valid
                    data.d = reg_in.data                  // save the value
                    state.d = States.READ_RESULT          // send it out
                }

            States.READ_RESULT:
                timeout.d = 0                             // reset the timeout
                if (!tx_busy) {                           // if serial not busy
                    tx_data = data.q[7:0]                 // write byte of data
                    data.d = data.q >> 8                  // shift data
                    new_tx_data = 1                       // send the byte
                    byte_ct.d = byte_ct.q + 1             // increase the byte counter
                    if (byte_ct.q == 3) {                 // if we sent 4 bytes
                        addr_ct.d = addr_ct.q - 1         // decrement the number of reads to perform
                        if (addr_ct.q == 0) {             // if no more commands
                            state.d = States.IDLE         // return to IDLE
                        } else {                          // else
                            state.d = States.REQUEST_READ // request another read
                            if (inc.q)                    // if auto-increment
                                addr.d = addr.q + 1       // increment the address
                        }
                    }
                }
        }

        if (&timeout.q)                                   // if we timed out
            state.d = States.IDLE                         // reset to IDLE
    }
}
```

I'm not going to dive into too much detail on _how_ it all works but mostly go over what it does and how to use it.
It is essentially just a large FSM (see [the FSM tutorial](@/tutorials/roms-and-fsms.md) for background).
Check out [The API](#the-api) section for info on the actual protocol.

For now, we will dive into using it.

# Controlling the LEDs

To get your feet wet, we will use the interface to control the LEDs on the board.

First, we need to instantiate the modules in the `alchitry_top` module.

```lucid,linenos,linenostart=16
        .rst(rst) {
            dff led_reg[8]
            #CLK_FREQ(100_000_000) {
                register_interface reg
                #BAUD(1_000_000) {
                    uart_rx rx
                    uart_tx tx
                }
            }
        }
```

Here I used connection blocks for the parameters `CLK_FREQ` and `BAUD` to easily set them for all the modules that need them.
This is optional, but I like to do it this way to guarantee they are all the same.

I also added the `dff led_reg` that we will use to save the value written to the LEDs.

In the `always` block, we can connect up the modules.

```lucid,linenos,linenostart=28
    always {
        reset_cond.in = ~rst_n  // input raw inverted reset signal
        rst = reset_cond.out    // conditioned reset
        
        led = led_reg.q
        
        usb_tx = tx.tx
        rx.rx = usb_rx
        
        reg.rx_data = rx.data
        reg.new_rx_data = rx.new_data
        tx.data = reg.tx_data
        tx.new_data = reg.new_tx_data
        reg.tx_busy = tx.busy
    }
```

We now need to deal with incoming requests.
This is done through the `reg_out` and `reg_in` ports of the `register_interface` module.
These ports use [structs](@/tutorials/lucid-reference.md#struct) to bundle a bunch of signals together.

The `struct` for each one is defined in the `global` block in the same file.
These are available anywhere in your design by using the designations `Register.request` and `Register.response`.

We can connect up these signals to respond to read/write requests to address 0 with the value of the LEDs.

```lucid,linenos,linenostart=44
        // default value
        reg.reg_in = <Register.response>(.data(32bx), .drdy(0))
        
        if (reg.reg_out.new_cmd) {
            if (reg.reg_out.write) { // write
                if (reg.reg_out.address == 0) { // address matches
                    led_reg.d = reg.reg_out.data[7:0] // update the value
                }
            } else { // read
                if (reg.reg_out.address == 0) { // address matches
                    reg.reg_in.drdy = 1 // data ready
                    reg.reg_in.data = led_reg.q // return the value
                }
            }
        }
```

Notice on line 45 I used the [struct literal syntax](@/tutorials/lucid-reference.md#structs) to assign a constant value
to every element in the struct.

You can now build your project and load it onto your board.

In Alchitry Labs, you can now open the _Register Interface_ tool to read/write registers.
Click the _Tools_ icon (looks like a terminal) and select _Register Interface_.
A new tab will open.

![Register Interface](https://cdn.alchitry.com/tutorials/register-interface/register-interface.png)

Click the chain icon to connect.
Make sure the baud rate matches what you set in your code.
In the above example I used 1M baud which is what Alchitry Labs defaults to.

You can enter a value, like `3`, into the _Value_ box and click _Write_ to write it to address 0.
If you then click _Read_ it'll read it back.

![Read and Write](https://cdn.alchitry.com/tutorials/register-interface/register-interface-read-write.png)

You should see your board's first two LEDs turn on.
Try writing a few other values just to make sure it's working as expected.

Don't forget to disconnect the register interface by clicking the chain icon.
You won't be able to program it while connected.

If you try to read from an address other than 0, you'll get an error along the lines of 
"Read failed: Read 0 but expected 4 bytes!"
This happens because we only set the `drdy` flag to `1` when address `0` was read and ignored every other request.
The tool only waits a short time after sending a read request for a result.

To expand the address you respond to, you would typically use a `case` statement instead of the `if`.

```lucid,linenos,linenostart=47
        if (reg.reg_out.new_cmd) {
            if (reg.reg_out.write) { // write
                case (reg.reg_out.address) { 
                    0: led_reg.d = reg.reg_out.data[7:0] // update the value
                    1: // do something with address 1
                    2: // do something with address 2
                    3: // do something with address 3
                }
            } else { // read
                case (reg.reg_out.address) {  // address matches
                    0:
                        reg.reg_in.drdy = 1 // data ready
                        reg.reg_in.data = led_reg.q // return the value
                    1:
                        // respond to address 1
                    2:
                        // respond to address 2
                    3:
                        // respond to address 3
                }
            }
        }
```

Each address targets a 32bit value.
In the LED example, we are throwing away the top 24 bits, but you could use them for something else.

Here's the full `alchitry_top` module.

```lucid,short,linenos
module alchitry_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx           // USB->Serial output
) {
    
    sig rst                 // reset signal
    
    .clk(clk) {
        // The reset conditioner is used to synchronize the reset signal to the FPGA
        // clock. This ensures the entire FPGA comes out of reset at the same time.
        reset_conditioner reset_cond
        
        .rst(rst) {
            dff led_reg[8]
            #CLK_FREQ(100_000_000) {
                register_interface reg
                #BAUD(1_000_000) {
                    uart_rx rx
                    uart_tx tx
                }
            }
        }
    }
    
    always {
        reset_cond.in = ~rst_n  // input raw inverted reset signal
        rst = reset_cond.out    // conditioned reset
        
        led = led_reg.q
        
        usb_tx = tx.tx
        rx.rx = usb_rx
        
        reg.rx_data = rx.data
        reg.new_rx_data = rx.new_data
        tx.data = reg.tx_data
        tx.new_data = reg.new_tx_data
        reg.tx_busy = tx.busy
        
        // default value
        reg.reg_in = <Register.response>(.data(32bx), .drdy(0))
        
        if (reg.reg_out.new_cmd) {
            if (reg.reg_out.write) { // write
                case (reg.reg_out.address) { 
                    0: led_reg.d = reg.reg_out.data[7:0] // update the value
                }
            } else { // read
                case (reg.reg_out.address) {  // address matches
                    0:
                        reg.reg_in.drdy = 1 // data ready
                        reg.reg_in.data = led_reg.q // return the value
                }
            }
        }
    }
}
```

# The API

This built in register interface tool is helpful, but manually entering everything isn't always practical. 
Here we will go over how the protocol works for issuing read and write requests so that you can use this in your own 
applications.

Every request starts with 5 bytes being sent. 
The first byte is the command byte and the next four are the address (32 bits = 4 bytes) sent with the least significant 
byte first.

In many cases you will want to read or write to many consecutive addresses, or perhaps the same address many times. 
It would be inefficient to have to issue the entire command each time so the command byte contains info for consecutive 
or multiple read/write requests in one.

The MSB (bit 7) of the command byte specifies if the command is a read (0) or write (1). 
The next bit (bit 6), specifies if consecutive addresses should be read/written (1) or if the same address should be 
read/written multiple times (0). 
The 6 LSBs (bits 5-0) represent how many read/write requests should be generated. Note that the number of requests will 
always be 1 more than the value of these bits. 
That means if you want to read or write a single address, they should be set to 0. 
Setting them to 1 will generate two read or write requests.

If you send a write request, after sending the command byte and address, you continue sending the data to be written. 
Data is always sent as four bytes per write request and the least significant byte should be sent first.

For reads, after sending the command byte and address, you simply wait for the data to be returned. 
Data is returned in least significant byte order. 
Note that you may not always receive all the data you ask for if there is an issue with the FPGA design 
(i.e. the requested data is never presented, like in our LED example).

Let's take a look at an example.

If you want to write to addresses 5, 6, and 7, you could issue the following request. 
0xC2 (1100 0010), 0x05, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00. 
This would write 1 to address 5, 2 to address 6, and 3 to address 7. 
If you changed the command byte to 0x82 (1000 0010) you would write 1 to address 5, 2 to address 5, and then 3 to 
address 5 (in that order).

Issuing a read follows the exact same format except the data bytes are received instead of sent.

A single command can generate up to 64 read/write requests. 
If you need to read/write more, you need to issue separate commands.

After a short period, the interface times out and resets to the `IDLE` state.
This ensures that a bad command doesn't permanently mess up the stream.