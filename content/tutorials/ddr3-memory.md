+++
title = "DDR3 Memory"
weight = 11
inline_language = "lucid"
date = "2024-09-23"
+++

In this tutorial we are going to set up an interface to the DDR3 memory with the FPGA on the Alchitry Au/Au+.

<!-- more -->

# Setup

The first step is to create a project.

Open [Alchitry Labs](@/alchitry-labs.md), and create a new project based on the _DDR3 Base Project_. 
I called mine _DDR Demo_, but feel free to name yours whatever you want.

{% callout(type="warning") %}
This project temple is a bit special in that it includes some _Vivado IP Cores_.
The cores themselves aren't included in the temple but scripts for their creation are.
These are fired off when the project is created.

Make sure to have Vivado setup correctly before creating the project or the IP cores will fail to generate, and you'll have to delete your project and start fresh.
{% end %}

When the project first opens, there will be some errors reported in `alchitry_top` and the `mig_wrapper`.
These will clear up once the IP cores have finished generating.
This can take a few minutes.

![Cores Built](https://cdn.alchitry.com/tutorials/ddr3/cores-built.png)

Once it finishes, you should see the `clk_wiz_0` and `mig_7series_0` cores added to the project.

# The Memory Controller

There is special hardware on the Artix 7 FPGA that is used for interfacing with the DDR chip. 
To efficiently use this, Xilinx provides customizable IP via their IP catalog in Vivado.

Customizing this IP requires full knowledge of the DDR3 chip being used and the board pinout. 
While you can find all the information you need to set this up for the Alchitry Au, we have drastically simplified it for you in Alchitry Labs.

The controller was added automatically as part of this project template, but you can add it manually to another project by clicking the three block icon and selecting _Generate MIG Core (DDR)_ from the dropdown.
Note that this option is missing for our project since the core has already been added.

If you look at the _IP Cores_ section of the project tree, you should see the _mig_7series_0_ core. 
You can double-click on it to open its stub file.
This is an empty Verilog file that defines all the connections to the core.

## Adapting to Lucid

You can use this core directly in your design if you want, but it is generally more convenient to wrap it.
The `mig_wrapper` component does just that.

```lucid,short
global Memory {
    struct in {
        addr[28],
        cmd[3],
        enable,
        wr_data[128],
        wr_enable,
        wr_mask[16]
    }
    
    struct out {
        rd_data[128],
        rd_valid,
        rdy,
        wr_rdy
    }
}

module mig_wrapper (
    inout ddr3_dq[16],
    inout ddr3_dqs_n[2],
    inout ddr3_dqs_p[2],
    output ddr3_addr[14],
    output ddr3_ba[3],
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output ddr3_ck_p,
    output ddr3_ck_n,
    output ddr3_cke,
    output ddr3_cs_n,
    output ddr3_dm[2],
    output ddr3_odt,
    // Inputs
    // Single-ended system clock
    input sys_clk,
    // Single-ended iodelayctrl clk (reference clock)
    input clk_ref,
    // user interface signals
    input mem_in<Memory.in>,
    output mem_out<Memory.out>,
    output ui_clk,
    output sync_rst,
    input sys_rst
) {
    
    mig_7series_0 mig(.ddr3_dq(ddr3_dq),.ddr3_dqs_n(ddr3_dqs_n),.ddr3_dqs_p(ddr3_dqs_p))
    
    always {
        ddr3_addr = mig.ddr3_addr
        ddr3_ba = mig.ddr3_ba
        ddr3_ras_n = mig.ddr3_ras_n
        ddr3_cas_n = mig.ddr3_cas_n
        ddr3_we_n = mig.ddr3_we_n
        ddr3_reset_n = mig.ddr3_reset_n
        ddr3_ck_p = mig.ddr3_ck_p
        ddr3_ck_n = mig.ddr3_ck_n
        ddr3_cke = mig.ddr3_cke
        ddr3_cs_n = mig.ddr3_cs_n
        ddr3_dm = mig.ddr3_dm
        ddr3_odt = mig.ddr3_odt
        
        mig.app_sr_req = 0
        mig.app_ref_req = 0
        mig.app_zq_req = 0
        
        mig.app_wdf_data = mem_in.wr_data
        mig.app_wdf_end = mem_in.wr_enable
        mig.app_wdf_wren = mem_in.wr_enable
        mig.app_wdf_mask = mem_in.wr_mask
        mig.app_cmd = mem_in.cmd
        mig.app_en = mem_in.enable
        mig.app_addr = mem_in.addr
        
        mem_out.rd_data = mig.app_rd_data
        mem_out.rd_valid = mig.app_rd_data_valid
        mem_out.rdy = mig.app_rdy
        mem_out.wr_rdy = mig.app_wdf_rdy
        
        mig.sys_clk_i = sys_clk
        mig.clk_ref_i = clk_ref
        mig.sys_rst = sys_rst
        
        sync_rst = mig.ui_clk_sync_rst
        ui_clk = mig.ui_clk
    }
}
```

This component wraps the `mig_7series_0` core and defines two global structures to make hooking up other modules to it easier.

If you look at the module declaration of the wrapper, you will see a bunch of `inout` and `output` ports that start with *ddr3_*. 
These are all top level signals that need to connect to the DDR3 chip.

These names are actually important since the pins they connect to are defined in the `mig_7series_0` core. 
You don't need to specify their pinouts in your constraints file.

## Hooking up the wrapper

The basic connections for the wrapper are already handled for you in `alchitry_top`.

```lucid,short,linenos
module alchitry_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx,          // USB->Serial output
    /* DDR3 Connections */
    inout ddr3_dq[16],
    inout ddr3_dqs_n[2],
    inout ddr3_dqs_p[2],
    output ddr3_addr[14],
    output ddr3_ba[3],
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output ddr3_ck_p,
    output ddr3_ck_n,
    output ddr3_cke,
    output ddr3_cs_n,
    output ddr3_dm[2],
    output ddr3_odt
) {
    // clock generator takes 100MHz in and creates 100MHz + 200MHz
    clk_wiz_0 clk_wiz(.resetn(rst_n), .clk_in(clk))

    // DDR3 Interface - connect inouts directly
    mig_wrapper mig (
        .ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .sys_rst(!clk_wiz.locked), // reset when clk_wiz isn't locked
        .sys_clk(clk_wiz.clk_100), // 100MHz clock
        .clk_ref(clk_wiz.clk_200)  // 200MHz clock
    )

    sig rst = mig.sync_rst // use the reset signal from the mig core

    always {
        /* DDR3 Connections */
        ddr3_addr = mig.ddr3_addr
        ddr3_ba = mig.ddr3_ba
        ddr3_ras_n = mig.ddr3_ras_n
        ddr3_cas_n = mig.ddr3_cas_n
        ddr3_we_n = mig.ddr3_we_n
        ddr3_reset_n = mig.ddr3_reset_n
        ddr3_ck_p = mig.ddr3_ck_p
        ddr3_ck_n = mig.ddr3_ck_n
        ddr3_cke = mig.ddr3_cke
        ddr3_cs_n = mig.ddr3_cs_n
        ddr3_dm = mig.ddr3_dm
        ddr3_odt = mig.ddr3_odt

        // default values
        mig.mem_in = <Memory.in>(
            .enable(0), 
            .cmd(3bx),
            .addr(28bx),
            .wr_data(128bx),
            .wr_mask(0),
            .wr_enable(0)
        )

        led = 8h00              // turn LEDs off

        usb_tx = usb_rx         // echo the serial data
    }
}
```

Again, it is important you don't change the names of these signals since they are used in the constraint file included with the `mig_7series_0` core. 
If you change the names, the tools won't know what pins they need to connect to on the FPGA.

# Setting up the clock

The memory interface requires both a 100MHz and a 200MHz clock. 
Since the Alchitry Au only has a 100MHz clock, we need to synthesize the 200MHz one.

This is the purpose of the `clk_wiz_0` core.

This core takes in a 100MHz clock and outputs 100MHz and 200MHz clocks.
You may be thinking that outputting the same frequency is pointless, but the way the clock is routed in the FPGA means that the input clock can't be used anywhere else.
If you need 100MHz somewhere else, you need to get it from the `clk_wiz_0`.

The FPGA can actually synthesize a lot of different frequencies.
You can check out the wizard by opening the _Vivado IP Catalog_.
Click the three block icon in the toolbar and select _Vivado IP Catalog_ from the dropdown.

After a few seconds, a window should open that looks like this.

![Vivado IP Catalog](https://cdn.alchitry.com/tutorials/ddr3/ip-catalog.png)

Note that you can see the two cores already in our project on the left.

You can right-click on the `clk_wiz_0` core and select _Re-customize IP..._ to open up the wizard.
Feel free to poke around the tabs to get an idea of the options available for future use.

![Clock Wizard](https://cdn.alchitry.com/tutorials/ddr3/customize-ip.png)

Since this was already setup how we need, click _Cancel_ for now and close the IP catalog.

Back in Alchitry Labs, you should see some text in the console about looking for cores. 
Everytime the _Vivado IP Catalog_ is closed, Alchitry Labs does a sweep of the cores folder to see what changed.

Hooking up the `clk_wiz_0` core is simple.

```lucid,linenos,linenostart=24
// clock generator takes 100MHz in and creates 100MHz + 200MHz
clk_wiz_0 clk_wiz(.resetn(rst_n), .clk_in(clk))
```

The `clk_wiz` instance has two outputs, `clk_wiz.clk_100` and `clk_wiz.clk_200` which are 100MHz and 200MHz clocks respectively.

These clocks are fed directly into the `mig` controller.
The `mig` controller then outputs a `ui_clk` which is intended to be used with its interface.
For the newer Alchitry V2 boards, this clock is 100MHz.
For Alchitry V1 boards, it is 81.25MHz.
This is what will drive the rest of our design.

This clock is derived from the 4:1 clock ratio used by the interface.
Alchitry V1 boards have a slower speed grade FPGA capable of 325MHz while the V2 boards go up to 400MHz.

Also notice that we are using the `mig.sync_rst` signal as our reset. 
Because of this, we don't need the `reset_conditioner` used in previous tutorials.

The reset button on the board will still work as the reset since it is used to reset `clk_wiz_0` which then resets the memory controller. 
This works since the `locked` output of the clock wizard goes low when it is reset. 
The `locked` output goes high when it isn't being reset and the clocks are stable. 
If you don't hold your circuit in reset when this input isn't high, you risk running into glitches as the clocks may be doing weird things.

With all of that we are now fully setup to use the core!

# The User Interface

The memory interface abstracts away a ton of the complexities of dealing with DDR3 memory, but the interface we get to it is still reasonably complex.

Check out [this document](https://docs.amd.com/v/u/1.4-English/ug586_7Series_MIS) from Xilinx that details all the information on the core. 
Skip to page 57 and look at the section labeled _User Interface_.

This section details what each of the signals we will be interacting with do.

The actual signals we need to deal with are a subset of the ones listed. 
See the two structs declared in the `mig_wrapper` component for the ones we need.

```lucid
global Memory {
    struct in {
        addr[28],
        cmd[3],
        enable,
        wr_data[128],
        wr_enable,
        wr_mask[16]
    }
    
    struct out {
        rd_data[128],
        rd_valid,
        rdy,
        wr_rdy
    }
}
```

One thing to note is that while the `cmd` signal (`app_cmd` in the Xilinx doc) is three bits wide, it only ever has a value of 0 (for write) and 1 (for read). 
Other values are used in different configurations of the core (for example, with ECC memory).

There are really three independent interfaces bundled together used to deal with the controller.

The first is the write FIFO. 
The controller will store data in a FIFO to be used in subsequent write commands. 
The signal `wr_rdy` is `1` when there is space in the buffer. 
You can write to the buffer by supplying data on `wr_data` and setting `we_enable` to `1`.

The signal `wr_mask` can be used to ignore bytes in `wr_data`. 
A `1` means to ignore the corresponding byte. 
To write the full 16 bytes (128 bits) set `wr_mask` to `0`.

Note that this mask doesn't change which bytes are sent to the DDR3 chip. 
It is used to control the _DM_ lines which tell the DDR3 chip to ignore certain bytes. 
If you set `wr_mask` to `16hFFFF` and perform a write command, the full 128 bits will still be sent to the DDR3 but nothing will happen.

With data in the FIFO, you can issue a write command.

The command interface can be used when the signal `rdy` is `1`.

To issue a command, set `cmd` to `0` for a write command or `1` for a read command, supply the related address on `addr` and set `enable` to `1`.

If you issue a write command, the first value written to the write FIFO will be used as data.

If you issue a read command, once it has been performed, the value will be returned on the read interface.

The read interface consists of `rd_valid`, which is `1` when there is new data, and `rd_data`, which is the data. 
After sending a read command, you wait for `rd_valid` to be `1` which means the data you requested is on `rd_data`.

The reason for the three independent interfaces it efficiency. 
The command interface may be ready to accept more commands before the read data is fully ready. 
The write FIFO may also be willing to accept data while a read is being performed.

It is also possible to set up the core to allow it to reorder the execution of commands to improve efficiency. 
In this case you may be issuing many commands while waiting for the first read command to finish. 
However, to keep things simple, our interface configuration uses strict ordering (commands executed in the order given).

# Write and Read Example

In this next section, we will create a small state machine that first initializes the DDR3 to have sequential values stored and then reads them back displaying them on the LEDs.

Here's the full top level module.

```lucid,short,linenos
module alchitry_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx,          // USB->Serial output
    /* DDR3 Connections */
    inout ddr3_dq[16],
    inout ddr3_dqs_n[2],
    inout ddr3_dqs_p[2],
    output ddr3_addr[14],
    output ddr3_ba[3],
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output ddr3_ck_p,
    output ddr3_ck_n,
    output ddr3_cke,
    output ddr3_cs_n,
    output ddr3_dm[2],
    output ddr3_odt
) {
    // clock generator takes 100MHz in and creates 100MHz + 200MHz
    clk_wiz_0 clk_wiz(.resetn(rst_n), .clk_in(clk))
    
    // DDR3 Interface - connect inouts directly
    mig_wrapper mig (
        .ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .sys_rst(!clk_wiz.locked), // reset when clk_wiz isn't locked
        .sys_clk(clk_wiz.clk_100), // 100MHz clock
        .clk_ref(clk_wiz.clk_200)  // 200MHz clock
    )
    
    sig rst = mig.sync_rst // use the reset signal from the mig core
    
    enum State {WRITE_DATA, WRITE_CMD, READ_CMD, WAIT_READ, DELAY}
    
    .clk(mig.ui_clk) {
        .rst(rst) {
            dff state[$width(State)]
            dff ctr[24]
            dff address[8]
            dff led_reg[8]
        }
    }
    
    always {
        /* DDR3 Connections */
        ddr3_addr = mig.ddr3_addr
        ddr3_ba = mig.ddr3_ba
        ddr3_ras_n = mig.ddr3_ras_n
        ddr3_cas_n = mig.ddr3_cas_n
        ddr3_we_n = mig.ddr3_we_n
        ddr3_reset_n = mig.ddr3_reset_n
        ddr3_ck_p = mig.ddr3_ck_p
        ddr3_ck_n = mig.ddr3_ck_n
        ddr3_cke = mig.ddr3_cke
        ddr3_cs_n = mig.ddr3_cs_n
        ddr3_dm = mig.ddr3_dm
        ddr3_odt = mig.ddr3_odt
        
        // default values
        mig.mem_in = <Memory.in>(
            .enable(0), 
            .cmd(3bx),
            .addr(28bx),
            .wr_data(128bx),
            .wr_mask(0),
            .wr_enable(0)
        )
        
        led = led_reg.q  // set leds to show led_reg value
        
        usb_tx = usb_rx  // echo the serial data
        
        case (state.q) {
            State.WRITE_DATA:
                mig.mem_in.wr_enable = 1
                mig.mem_in.wr_data = address.q
                if (mig.mem_out.wr_rdy)
                    state.d = State.WRITE_CMD
            
            State.WRITE_CMD:
                mig.mem_in.enable = 1
                mig.mem_in.cmd = 0 // 0 = write
                mig.mem_in.addr = c{address.q, 3b000} // first three bits of addr are for the 8 words in wr_data
                if (mig.mem_out.rdy) {
                    address.d = address.q + 1
                    state.d = State.WRITE_DATA
                    if (address.q == 8hFF) {
                        state.d = State.READ_CMD
                        address.d = 0
                    }
                }
            
            State.READ_CMD:
                mig.mem_in.enable = 1
                mig.mem_in.cmd = 1 // 1 = read
                mig.mem_in.addr = c{address.q, 3b000}
                if (mig.mem_out.rdy)
                    state.d = State.WAIT_READ
            
            State.WAIT_READ:
                if (mig.mem_out.rd_valid) {
                    led_reg.d = mig.mem_out.rd_data[7:0]
                    state.d = State.DELAY
                    address.d = address.q + 1
                }
            
            State.DELAY:
                ctr.d = ctr.q + 1 // delay so we can see the value
                if (&ctr.q)
                    state.d = State.READ_CMD
        }
    }
}
```

First notice that we used the signal `mig.ui_clk` in the `.clk` block for the `dff` instances. 
This is the clock that the user interface of the memory interface is synchronized to. 
If you need to use a different clock for the rest of your design, you'll have to implement some clock domain crossing scheme. 
It is easiest if you can make your design work with this clock (100MHz on V2 and 81.25MHz on V1).

If you look a little lower in the `always` block, you'll see the default values we assign to the `mem_in` struct on the `mig` module. 
The `wr_mask` signal is active low, meaning a 0 enables the byte. 
Since we will be writing all the bytes, we can fix it to 0.

The other values we don't care about when the enable signals are `0` so they are set to `bx`.

The state machine is straightforward, it starts in `WRITE_DATA` where it writes a value to the write FIFO. 
Once the value is written, which is noted by `wr_enable` and `wr_rdy` both being `1`, it switches to the `WRITE_CMD` state.

In this state, it sends the write command. 
One thing to note is that the address associated with the write command is the _DDR native address_. 
This means that the first three bits should always be `0` since each DDR entry is 16 bits (the DDR3 on the Au has a 16 bit bus) and each read/write we preform is on 128 bit blocks.

This is easy to do by concatenating three 0's onto the end of our address.

```lucid,linenos,linenostart=89
mig.mem_in.addr = c{address.q, 3b000} // first three bits of addr are for the 8 words in wr_data
```

The 128 bit operation size isn't configurable. 
Xillinx's memory interface uses bursts of 8 to increase efficiency. 
This is common practice when working with DDR memory. 
Also note that the DDR interface is clocked at 4x the system clock which means that you complete an entire burst in the span of a single system clock cycle (4x freq * 2 for double data rate = 8 values per system cycle).

The burst operation is actually supported by the DDR3 chip itself. 
The address you give the memory interface is sent directly to the DDR3 chip. 
If you don't set the last three bits to 0, weird things happen. 

For writes, these bits are ignored and everything works as if they were 0.

For reads, the same 16-bit words in the burst will be read from same 128-bit block but in a different order. 
For example, if the last three bits are 0, then they are read in the expected order, 0, 1, 2, 3, 4, 5, 6, and 7. 
However, if you set the last three bits to 2, then it will read them in the order 2, 3, 0, 1, 6, 7, 4, and 5. 
See page 145 of [this document](https://media-www.micron.com/-/media/client/global/documents/products/data-sheet/dram/ddr3/2gb_1_35v_ddr3l.pdf) for the full behavior. 
The memory controller is set up to use the sequential burst type.

It is generally best to just ensure these bits are always 0. 
The reason this feature exists is so that you can get a specific 16 bit value as soon as possible while still reading in a burst of 8.

Note that we are writing the address' value to each address. 
In other words, address 0 gets value 0, address 1 gets value 1, and so on. 
This means when we read these back in order, it'll look like a counter.

Once 256 addresses have been written, it switches to reading. 
The `READ_CMD` state issues the read command and then transitions to the `WAIT_READ` state.

In the `WAIT_READ` state, it waits for `rd_valid` to be `1`. 
It then uses the read value to set the LED's state.

Finally, it goes into the `DELAY` state to waste some time so we can see the LED value before it loops to `READ_CMD` again.

It will continue reading the first 256 addresses of the DDR3 over and over.

If you change what value is written in the `WRITE_DATA` state, it'll change what the LEDs show.

With this you should be able to build the project and load it onto your board to see the LEDs counting.

# Caching

You may have noticed that this example is incredibly wasteful. 
We are reading and writing full 128-bit blocks of data when we are only using the first 8 bits.

This could be fixed if we just combined 16 values into 128-bit blocks and wrote those to a single address. 
When we read them, we could then store a whole line and iterate over each byte before reading in another line.

For our trivial example, it wouldn't be too hard to implement this directly. 
However, for more complex read/write patterns, this could be very difficult to do efficiently.

Luckily, there is a component in the _Component Library_ that can help us with this.

Open the _Component Library_ and under _Memory_ select _LRU Cache_.

```lucid,short
module lru_cache #(
    ENTRIES = 4 : ENTRIES > 0,
    WORD_SIZE = 16 : WORD_SIZE >= 8 && WORD_SIZE <= 128 && (WORD_SIZE == $pow(2,$clog2(WORD_SIZE/8))*8), // 8,16,32,64,128 valid
    AGE_BITS = 3 : AGE_BITS > 0
)(
    input clk,  // clock
    input rst,  // reset
    input wr_addr[24 + $clog2(128/WORD_SIZE)], // 24-28 bits
    input wr_data[WORD_SIZE],
    input wr_valid,
    output wr_ready,
    input rd_addr[24 + $clog2(128/WORD_SIZE)],
    input rd_cmd_valid,
    output rd_ready,
    output rd_data[WORD_SIZE],
    output rd_data_valid,
    input flush,
    output flush_ready,
    input mem_out<Memory.out>,
    output mem_in<Memory.in>
) {

    const WORDS_PER_LINE = 128 / WORD_SIZE
    const BYTES_PER_WORD = WORD_SIZE / 8
    const SUB_ADDR_BITS = $clog2(WORDS_PER_LINE)
    const ADDR_SIZE = 24 + SUB_ADDR_BITS

    enum State {IDLE, PREP_WRITE_ENTRY, PREP_READ_ENTRY, FLUSH, WRITE_DATA, WRITE_CMD, READ_CMD, WAIT_READ}
    enum WriteState {IDLE, PUT}
    enum ReadState {IDLE, FETCH}

    .clk(clk) {
        .rst(rst) {
            dff active[ENTRIES]

            dff state[$width(State)]
            dff write_state[$width(WriteState)]
            dff read_state[$width(ReadState)]
        }

        dff buffer[ENTRIES][WORDS_PER_LINE][WORD_SIZE]
        dff address[ENTRIES][25]

        dff written[ENTRIES]
        dff valid[ENTRIES][WORDS_PER_LINE]
        dff age[ENTRIES][AGE_BITS]

        dff active_entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1]

        dff read_data[WORD_SIZE]
        dff read_valid

        dff read_pending
        dff read_addr[ADDR_SIZE]

        dff write_pending
        dff write_addr[ADDR_SIZE]
        dff write_data[WORD_SIZE]

        dff old_active[ENTRIES]
        dff return_state[$width(State)]
    }

    sig handled
    sig oldest_entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1]
    sig entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1]
    sig max_age[$width(age.q, 1)]

    always {
        mem_in.enable = 0
        mem_in.wr_data = $flatten(buffer.q[active_entry.q])
        mem_in.cmd = bx
        mem_in.addr = c{address.q[active_entry.q], 3b000}
        mem_in.wr_enable = 0
        flush_ready = state.q == State.IDLE
        wr_ready = write_state.q == WriteState.IDLE
        rd_ready = read_state.q == ReadState.IDLE
        rd_data = read_data.q
        rd_data_valid = read_valid.q

        read_valid.d = 0

        // only write out valid bytes (0 = write)
        repeat(i, WORDS_PER_LINE)
            mem_in.wr_mask[i*BYTES_PER_WORD+:BYTES_PER_WORD] = BYTES_PER_WORDx{~valid.q[active_entry.q][i]}

        // Keep track of the oldest entry (the one to replace)
        max_age = 0
        oldest_entry = 0
        entry = bx

        handled = 0
        repeat(i, ENTRIES) {
            if (!handled) {
                if (!active.q[i]) { // entry isn't in use
                    oldest_entry = i[$width(oldest_entry)-1:0] // use the inactive entry
                    handled = 1      // stop the for loop
                }
                if (age.q[i] > max_age) {
                    max_age = age.q[i]
                    oldest_entry = i[$width(oldest_entry)-1:0]
                }
            }
        }

        case (read_state.q) {
            ReadState.IDLE:
                if (rd_cmd_valid) {
                    repeat(i, ENTRIES) // increment all the entry ages
                        if (!(&age.q[i]))
                            age.d[i] = age.q[i] + 1


                    handled = 0
                    repeat(i, ENTRIES) {
                        if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? rd_addr[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == rd_addr[ADDR_SIZE-1:SUB_ADDR_BITS])) {
                            handled = 1
                            read_valid.d = 1
                            read_data.d = buffer.q[i][SUB_ADDR_BITS > 0 ? rd_addr[SUB_ADDR_BITS-1:0] : 0]
                            age.d[i] = 0 // reset the age on an access
                        }
                    }
                    if (!handled) { // entry isn't in the cache
                        read_pending.d = 1
                        read_addr.d = rd_addr
                        read_state.d = ReadState.FETCH
                    }
                }

            ReadState.FETCH:
                read_pending.d = 1

                handled = 0
                repeat(i, ENTRIES) {
                    if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
                        handled = 1
                        read_valid.d = 1
                        read_data.d = buffer.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0]
                        age.d[i] = 0 // reset the age on an access
                    }
                }
                if (handled) {
                    read_pending.d = 0
                    read_state.d = ReadState.IDLE
                }
        }

        case (write_state.q) {
            WriteState.IDLE:
                if (wr_valid) {
                    repeat(i, ENTRIES) // increment all the entry ages
                        if (!(&age.q[i]))
                            age.d[i] = age.q[i] + 1

                    handled = 0
                    repeat(i, ENTRIES) {
                        if (!handled && active.q[i] && (address.q[i] == wr_addr[ADDR_SIZE-1:SUB_ADDR_BITS])) {
                            handled = 1
                            written.d[i] = 1
                            valid.d[i][SUB_ADDR_BITS > 0 ? wr_addr[SUB_ADDR_BITS-1:0] : 0] = 1
                            buffer.d[i][SUB_ADDR_BITS > 0 ? wr_addr[SUB_ADDR_BITS-1:0] : 0] = wr_data
                            age.d[i] = 0 // reset the age on an access
                        }
                    }

                    if (!handled) { // entry isn't in the cache
                        write_pending.d = 1
                        write_data.d = wr_data
                        write_addr.d = wr_addr
                        write_state.d = WriteState.PUT
                    }
                }

            WriteState.PUT:
                write_pending.d = 1

                handled = 0
                repeat(i, ENTRIES) {
                    if (!handled && active.q[i] && (address.q[i] == write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
                        handled = 1
                        written.d[i] = 1
                        valid.d[i][SUB_ADDR_BITS > 0 ? write_addr.q[SUB_ADDR_BITS-1:0] : 0] = 1
                        buffer.d[i][SUB_ADDR_BITS > 0 ? write_addr.q[SUB_ADDR_BITS-1:0] : 0] = write_data.q
                        age.d[i] = 0 // reset the age on an access
                    }
                }

                if (handled) {
                    write_pending.d = 0
                    write_state.d = WriteState.IDLE
                }
        }

        case (state.q) {
            WriteState.IDLE:
                if (flush) { // flush command takes priority
                    active.d = 0
                    old_active.d = active.q
                    state.d = State.FLUSH

                } else if (read_pending.q) { // Read command is pending
                    entry = oldest_entry // default to oldest

                    // check for a cache line that was written but never read (ie only partially valid)
                    handled = 0
                    repeat(i, ENTRIES) {
                        if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
                            handled = 1
                            entry = i[$width(entry)-1:0]
                        }
                    }

                    // save the entry
                    active_entry.d = entry

                    // if entry is active and not our address
                    if (active.q[entry] && address.q[entry] != read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]) {
                        // need to mark inactive then wait for any potential writes
                        active.d[entry] = 0
                        state.d = State.PREP_READ_ENTRY
                    } else {
                        state.d = State.READ_CMD
                        address.d[entry] = read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]
                        if (address.q[entry] != read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])
                            valid.d[entry] = 0
                    }

                } else if (write_pending.q) { // Write command is pending
                    // if oldest entry is active
                    if (active.q[oldest_entry]) {
                        // need to mark inactive then wait for any potential writes
                        active.d[oldest_entry] = 0
                        active_entry.d = oldest_entry
                        state.d = State.PREP_WRITE_ENTRY
                    } else { // oldest entry can be cleared
                        // prep the new entry
                        written.d[oldest_entry] = 0
                        valid.d[oldest_entry] = 0
                        address.d[oldest_entry] = write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]
                        age.d[oldest_entry] = 0
                        active.d[oldest_entry] = 1
                        write_pending.d = 0
                    }
                }

            State.PREP_WRITE_ENTRY:
                // if entry was written to
                if (written.q[active_entry.q]) {
                    // write the data out
                    return_state.d = State.PREP_WRITE_ENTRY
                    state.d = State.WRITE_DATA
                } else {
                    // prep the new entry
                    written.d[active_entry.q] = 0
                    valid.d[active_entry.q] = 0
                    address.d[active_entry.q] = write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]
                    age.d[active_entry.q] = 0
                    active.d[active_entry.q] = 1
                    state.d = State.IDLE
                    write_pending.d = 0
                }

            State.PREP_READ_ENTRY:
                if (written.q[active_entry.q]) {
                    // write the data out
                    return_state.d = State.PREP_READ_ENTRY
                    state.d = State.WRITE_DATA
                } else {
                    // read in new active_entry
                    state.d = State.READ_CMD
                    address.d[active_entry.q] = read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]
                    valid.d[active_entry.q] = 0
                }

            State.FLUSH:
                state.d = State.IDLE // default to returning if no entries to flush

                handled = 0
                repeat(i, ENTRIES) {
                    // find the first entry that needs to be flushed
                    if (!handled && old_active.q[i] && written.q[i]) {
                        handled = 1
                        active_entry.d = i[$width(active_entry.q)-1:0]
                        state.d = State.WRITE_DATA
                        old_active.d[i] = 0
                        return_state.d = State.FLUSH
                    }
                }

            State.WRITE_DATA:
                mem_in.wr_enable = 1
                if (mem_out.wr_rdy) {
                    state.d = State.WRITE_CMD
                }

            State.WRITE_CMD:
                mem_in.enable = 1
                mem_in.cmd = 0 // write
                if (mem_out.rdy) {
                    state.d = return_state.q
                    written.d[active_entry.q] = 0
                }

            State.READ_CMD:
                mem_in.enable = 1
                mem_in.cmd = 1 // read
                if (mem_out.rdy) {
                    state.d = State.WAIT_READ
                }

            State.WAIT_READ:
                if (mem_out.rd_valid) {
                    repeat(i, WORDS_PER_LINE)
                        if (!valid.q[active_entry.q][i]) // only read in unwritten words
                            buffer.d[active_entry.q][i] = mem_out.rd_data[WORD_SIZE*i+:WORD_SIZE]

                    // prep the new entry
                    active.d[active_entry.q] = 1
                    valid.d[active_entry.q] = WORDS_PER_LINEx{1b1} // everything valid
                    age.d[active_entry.q] = 0
                    read_pending.d = 0
                    written.d[active_entry.q] = 0

                    state.d = State.IDLE
                }
        }
    }
}
```

This component is pretty complicated, but it can take the memory interface from the _MIG Wrapper_ component and give you efficient read and write interfaces of selectable word sizes.

This cache is lazy and will only access the RAM when it needs to. 
That means you can read and write to entries in the cache as much as you want without hitting the memory. 
It will only access values in the external memory when it needs to free up a cache line or if you try to read values that aren't in the cache.

The cache presents independent read and write interfaces. 
This comes in handy when you have one section of your design doing only reads and another doing only writes. 
If you read and write the same address in the same cycle, you will read the old value.

You can configure the cache to have multiple entries (AKA cache lines). 
This can save a ton of IO for certain memory access patterns. 
For example, in our [GPU demo project](@/tutorials/projects/gpu.md) the rasterizer reads values from the Z buffer sequentially and writes values back sequentially at a slightly delayed time down the pipeline. 
This cache was used with two entries so that the reads and writes would each have their own cache lines to minimize fighting.

This cache attempts to approximate an LRU (**L**east **R**ecently **U**sed) cache policy. 
This means that when a new cache line is needed, the least recently used (AKA oldest) entry will be evicted.

The age of each entry is kept track of by adding 1 to its age counter every time a read/write is performed to any entry. 
The age counter can saturate if it isn't accessed in a long time.

Each time an entry is accessed, its age counter is reset.

The maximum age can be set with the `AGE_BITS` parameter. 
The default value is `3`, which gives a maximum age of 7. 
This way of keeping track of age isn't perfect and if `AGE_BITS` is too small, in some cases the cache may not act as a perfect LRU. 
However, this typically isn't an issue as it will always evict the oldest or a max age cache line.

Setting `AGE_BITS` to a large value will ensure that the oldest cache line is more likely to be removed but will incur a performance penalty.

## Cache Interface

The interface to the cache is pretty simple.

The addresses used are word address. 
This means you don't need to worry about zero padding anything.

You can set the size of the data word with the `WORD_SIZE` parameter. 
This can be set to 8, 16, 32, 64, or 128. 

To write, you simply check `wr_ready`. 
If this signal is `1`, you can specify a value on `wr_data`, an address on `wr_addr`, and set `wr_valid` to `1`. 

To read, you check if `rd_ready` is `1`. 
If it is, you set `rd_addr` to the address to read and `rd_cmd_valid` to `1`.

You then wait for `rd_data_valid` to be `1`. 
When it is, `rd_data` has your data.

When you perform reads, `rd_data_valid` is guaranteed to take at least one cycle from the request to go high. 
However, `rd_ready` may stay high if it is a cache hit. 
That means you can stream multiple reads back to back with each result delayed a single cycle if they are all hits.

Cache misses will take longer for `rd_data_valid` to go high since it will need to actually fetch the value from the RAM.

If you have a cache in your design and are also reading values from another piece of your design, you may need to occasionally flush the cache to ensure that the values are actually written to the DDR3. 
For this, you can use the `flush` signal. 
When `flush` and `flush_ready` are high, the cache will write all dirty entries to the DDR3 memory.

## Cache Example

With the cache component in our design, we can use it to more efficiently use the DDR3.

```lucid,short
module alchitry_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led[8],          // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx,          // USB->Serial output
    /* DDR3 Connections */
    inout ddr3_dq[16],
    inout ddr3_dqs_n[2],
    inout ddr3_dqs_p[2],
    output ddr3_addr[14],
    output ddr3_ba[3],
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output ddr3_ck_p,
    output ddr3_ck_n,
    output ddr3_cke,
    output ddr3_cs_n,
    output ddr3_dm[2],
    output ddr3_odt
) {
    // clock generator takes 100MHz in and creates 100MHz + 200MHz
    clk_wiz_0 clk_wiz(.resetn(rst_n), .clk_in(clk))
    
    // DDR3 Interface - connect inouts directly
    mig_wrapper mig (
        .ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .sys_rst(!clk_wiz.locked), // reset when clk_wiz isn't locked
        .sys_clk(clk_wiz.clk_100), // 100MHz clock
        .clk_ref(clk_wiz.clk_200)  // 200MHz clock
    )
    
    sig rst = mig.sync_rst // use the reset signal from the mig core
    
    enum State {WRITE_DATA, WRITE_CMD, READ_CMD, WAIT_READ, DELAY}
    
    .clk(mig.ui_clk) {
        .rst(rst) {
            dff state[$width(State)]
            dff ctr[24]
            dff address[8]
            dff led_reg[8]
            
            lru_cache cache(#ENTRIES(1), #WORD_SIZE(8), #AGE_BITS(1))
        }
    }
    
    always {
        /* DDR3 Connections */
        ddr3_addr = mig.ddr3_addr
        ddr3_ba = mig.ddr3_ba
        ddr3_ras_n = mig.ddr3_ras_n
        ddr3_cas_n = mig.ddr3_cas_n
        ddr3_we_n = mig.ddr3_we_n
        ddr3_reset_n = mig.ddr3_reset_n
        ddr3_ck_p = mig.ddr3_ck_p
        ddr3_ck_n = mig.ddr3_ck_n
        ddr3_cke = mig.ddr3_cke
        ddr3_cs_n = mig.ddr3_cs_n
        ddr3_dm = mig.ddr3_dm
        ddr3_odt = mig.ddr3_odt
        
        mig.mem_in = cache.mem_in
        cache.mem_out = mig.mem_out
        
        // default values
        cache.flush = 0 // don't need to flush
        cache.wr_addr = address.q
        cache.wr_data = address.q
        cache.wr_valid = 0
        cache.rd_addr = address.q
        cache.rd_cmd_valid = 0
        
        led = led_reg.q  // set leds to show led_reg value
        
        usb_tx = usb_rx  // echo the serial data
        
        case (state.q) {
            State.WRITE_DATA:
                if (cache.wr_ready) {
                    cache.wr_valid = 1
                    address.d = address.q + 1
                    if (address.q == 8hFF) {
                        state.d = State.READ_CMD
                        address.d = 0
                    }
                }
            
            State.READ_CMD:
                if (cache.rd_ready) {
                    cache.rd_cmd_valid = 1
                    state.d = State.WAIT_READ
                }
            
            State.WAIT_READ:
                if (cache.rd_data_valid) {
                    led_reg.d = cache.rd_data
                    state.d = State.DELAY
                    address.d = address.q + 1
                }
            
            State.DELAY:
                ctr.d = ctr.q + 1 // delay so we can see the value
                if (&ctr.q) {
                    state.d = State.READ_CMD
                }
        }
    }
}
```

This new design performs exactly the same as before, but now we are using the DDR3 more efficiently. 
We are using 1/16th the memory as we were before without having to complicate our design. 
It actually simplifies the design since the writes don't require separate operations to write the data and command.

Note that `ENTRIES` is set to `1` since our access pattern is super simple and having more entries won't increase the number of cache hits we have (unless `ENTRIES` was set to 16 which would mean everything would fit in the cache).

We also set `AGE_BITS` to `1` since there isn't much of a choice which entry to evict when there is only one.

In this super basic use case, the cache component is overkill. 
However, the tools will optimize a lot of the logic out keeping it fairly efficient.

# Multiple devices

It is common to want to interface multiple parts of your design with the one memory interface. 
To make this easy there is a component in the _Components Library_ called _DDR Arbiter_ under the _Memory_ section.

```lucid,short
module ddr_arbiter #(
    DEVICES ~ 2 : DEVICES > 1
)(
    input clk,  // clock
    input rst,  // reset
    // Master
    output master_in<Memory.in>,
    input master_out<Memory.out>,
    // Devices
    input device_in[DEVICES]<Memory.in>,
    output device_out[DEVICES]<Memory.out>
) {

    enum State {WAIT_CMD, WAIT_WRITE, WAIT_RDY}

    .clk(clk) {
        .rst(rst) {
            dff state[$width(State)]

            fifo fifo (#WIDTH($clog2(DEVICES)), #ENTRIES(256)) // ignore full flag as it can never fill anyways
            dff device[$clog2(DEVICES)]
        }
    }

    sig act

    always {
        fifo.din = bx
        fifo.wput = 0
        fifo.rget = 0

        master_in.enable = 0
        master_in.wr_data = bx
        master_in.cmd = 0
        master_in.wr_mask = 0
        master_in.addr = bx
        master_in.wr_enable = 0

        repeat(i, DEVICES) {
            device_out[i].rdy = 0
            device_out[i].wr_rdy = 0
        }

        act = 0
        case (state.q) {
            State.WAIT_CMD:
                repeat(i, DEVICES) {
                    if ((device_in[i].enable || device_in[i].wr_enable) && !act) {
                        act = 1
                        device.d = i[$width(device.q)-1:0]
                        master_in = device_in[i]
                        device_out[i] = master_out
                        if (device_in[i].enable && (device_in[i].cmd == 3b001)) { // read
                            fifo.wput = 1
                            fifo.din = i[$clog2(DEVICES)-1:0]
                            if (!master_out.rdy) {
                                state.d = State.WAIT_RDY
                            }
                        } else { // write
                            if (!master_out.wr_rdy) {
                                state.d = State.WAIT_WRITE
                            } else {
                                state.d = State.WAIT_RDY
                            }
                        }
                    }
                }

            State.WAIT_WRITE:
                master_in = device_in[device.q]
                device_out[device.q] = master_out
                if (master_out.wr_rdy) {
                    if (device_in[device.q].enable && master_out.rdy) {
                        state.d = State.WAIT_CMD
                    } else {
                        state.d = State.WAIT_RDY
                    }
                }

            State.WAIT_RDY:
                master_in = device_in[device.q]
                device_out[device.q] = master_out
                if (master_out.rdy) {
                    state.d = State.WAIT_CMD
                }
        }

        repeat(i, DEVICES) {
            device_out[i].rd_data = bx
            device_out[i].rd_valid = 0
        }

        if (master_out.rd_valid) {
            device_out[fifo.dout].rd_data = master_out.rd_data
            device_out[fifo.dout].rd_valid = 1
            fifo.rget = 1
        }
    }
}
```

This module can be hooked up to the memory interface via the `master_in` and `master_out` signals. 
You then get `DEVICES` number of similar interfaces on the `device_in` and `device_out` arrays that can be hooked up to different parts of your design.

For example, in our [GPU project](@/tutorials/projects/gpu.md), we have a section that writes frames and another that reads the buffer to display the frames on the LCD.

It is important to order your devices carefully since the device attached to index `0` get full priority. 
If it never has idle bus time, it'll starve out all the other devices.