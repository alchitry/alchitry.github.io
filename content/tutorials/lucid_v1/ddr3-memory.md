+++
title = "DDR3 Memory"
weight = 6
+++

In this tutorial we are going to setup an interface to the DDR3 memory with the FPGA on the Alchitry Au.

# Setup

**Before starting, you need to have Alchitry Labs 1.1.6 and Vivado 2019.1 or newer.**

The first step is to setup your project. Open [Alchitry Labs](@/alchitry-labs.md), and go to **Project->New Project**. From here, make a new project based on the _Base Project_. We called ours _DDR Demo_, but feel free to name yours whatever you want.

Also make sure that the project is for the Alchitry Au. The Alchitry Cu and Mojo don't have DDR memory on board so this tutorial is only for the Alchitry Au.

## Adding the memory controller

There is special hardware on the Artix 7 FPGA that is used for interfacing with the DDR chip. To efficiently use this, Xilinx provides customizable IP via their IP catalog in Vivado.

Customizing this IP requires full knowledge of the DDR3 chip being used and the board pinout. While you can find all the information you need to set this up for the Alchitry Au, we have drastically simplified it for you in Alchitry Labs.

To invoke the commands needed to add the Xilinx memory interface to your project with everything already setup, go to **Project->Add Memory Controller**. Note that this option is only visible if your project is for the Alchitry Au board.

Once you click this, Alchitry Labs will add a Vivado IP Project to your project and invoke the necessary commands to add the memory interface.

![Screenshot_from_2019-09-16_09-31-38.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_09-31-38.png)

The initial setup can take a couple minutes since it actually builds the core. Once it is done it should look like the above screen shot.

If you open the **Cores** section of the project tree, you should see the _mig_7series_0_ core. Under its heading you can find the stub file. This is an empty Verilog file that defines all the connections to the core.

## Adapting to Lucid

You can use this core directly in your design if you want, but it is generally more convenient to wrap it. Go to **Project->Add Components** and under **Memory** select the **MIG Wrapper**. Click **Add** to add it to your project.

```lucid,short
global Memory {
  struct in {
    addr[28],
    cmd[3],
    en,
    wr_data[128],
    wr_en,
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
    input              sys_clk,
    // Single-ended iodelayctrl clk (reference clock)
    input              clk_ref,
    // user interface signalsa
    input<memory.in>   mem_in,
    output<memory.out> mem_out,
    output             ui_clk,
    output             sync_rst,
    input              sys_rst
  ) {
   
  mig_7series_0 mig(.ddr3_dq(ddr3_dq),.ddr3_dqs_n(ddr3_dqs_n),.ddr3_dqs_p(ddr3_dqs_p));
   
  always {
    ddr3_addr = mig.ddr3_addr;
    ddr3_ba = mig.ddr3_ba;
    ddr3_ras_n = mig.ddr3_ras_n;
    ddr3_cas_n = mig.ddr3_cas_n;
    ddr3_we_n = mig.ddr3_we_n;
    ddr3_reset_n = mig.ddr3_reset_n;
    ddr3_ck_p = mig.ddr3_ck_p;
    ddr3_ck_n = mig.ddr3_ck_n;
    ddr3_cke = mig.ddr3_cke;
    ddr3_cs_n = mig.ddr3_cs_n;
    ddr3_dm = mig.ddr3_dm;
    ddr3_odt = mig.ddr3_odt;
     
    mig.app_sr_req = 0;
    mig.app_ref_req = 0;
    mig.app_zq_req = 0;
     
    mig.app_wdf_data = mem_in.wr_data;
    mig.app_wdf_end = mem_in.wr_en;
    mig.app_wdf_wren = mem_in.wr_en;
    mig.app_wdf_mask = mem_in.wr_mask;
    mig.app_cmd = mem_in.cmd;
    mig.app_en = mem_in.en;
    mig.app_addr = mem_in.addr;
     
    mem_out.rd_data = mig.app_rd_data;
    mem_out.rd_valid = mig.app_rd_data_valid;
    mem_out.rdy = mig.app_rdy;
    mem_out.wr_rdy = mig.app_wdf_rdy;
     
    mig.sys_clk_i = sys_clk;
    mig.clk_ref_i = clk_ref;
    mig.sys_rst = sys_rst;
     
    sync_rst = mig.ui_clk_sync_rst;
    ui_clk = mig.ui_clk;
  }
}
```

This component wraps the _mig_7series_0_ core you previously generated and defines two global structures to make hooking up other modules to it easier.

If you look at the module declaration of the wrapper, you will see a bunch of inouts and outputs that start with _ddr3__. These are all top level signals that need to connect to the DDR3 chip.

These names are actually important since the pins they connect to are defined in the _mig_7series_0_ core. You don't need to specify a pinout for them in your constraints file.

## Hooking up the wrapper

We can copy/paste these connections to our top level module and hook them up.

```lucid,short
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
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
   
  sig rst;                  // reset signal
   
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
  }
   
  // DDR3 Interface - connect inouts directly
  mig_wrapper mig (.ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p));
   
  always {
    /* DDR3 Connections */
    ddr3_addr = mig.ddr3_addr;
    ddr3_ba = mig.ddr3_ba;
    ddr3_ras_n = mig.ddr3_ras_n;
    ddr3_cas_n = mig.ddr3_cas_n;
    ddr3_we_n = mig.ddr3_we_n;
    ddr3_reset_n = mig.ddr3_reset_n;
    ddr3_ck_p = mig.ddr3_ck_p;
    ddr3_ck_n = mig.ddr3_ck_n;
    ddr3_cke = mig.ddr3_cke;
    ddr3_cs_n = mig.ddr3_cs_n;
    ddr3_dm = mig.ddr3_dm;
    ddr3_odt = mig.ddr3_odt;
     
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
     
    led = 8h00;             // turn LEDs off
 
    usb_tx = usb_rx;        // echo the serial data
  }
}
```

Note that you'll get an error on the _mig_ instantiation since we haven't hooked up the user interface yet.

Again, it is important you don't change the names of these signals since they are used in the constraint file included with the _mig_7series_0_ core. If you change the names, the tools won't know what pins they need to connect to on the FPGA.

## Setting up the clock

The memory interface requires both a 100MHz and a 200MHz clock. Since the Alchitry Au only has a 100MHz clock, we need to synthesize the 200MHz one.

We can do this using the _Vivado IP Catalog_. Go to **Project->Vivado IP Catalog** to launch it.

After a few seconds, a window should open that looks likes this.

![Screenshot_from_2019-09-16_10-08-09.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_10-08-09.png)

Note that there is already a core in our project, the _mig_7series_0_.

In the right **IP Catalog** panel, navigate to **FPGA Features and Design->Clocking->Clocking Wizard** and double click on **Clocking Wizard**.

This will open a new dialog to customize the IP.

![Screenshot_from_2019-09-16_10-10-53.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_10-10-53.png)

The defaults on the first page are all fine. However, by default, it is set to output only a single 100MHz clock.

Go to the **Output Clocks** tab and check the **clk_out2** box.

Under **Output Freq (MHz) Requested**, enter 200.

![Screenshot_from_2019-09-16_10-12-53.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_10-12-53.png)

We can now click _OK_ to close the dialog.

Another dialog will open with some generation settings, just click on **Generate** to generate the core.

After a few seconds, another dialog saying _Out-of-context module run was launched for generating output products._ Simply click OK and wait until you see 100% under the **Progress** section in the bottom of the main window.

![Screenshot_from_2019-09-16_10-15-51.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_10-15-51.png)

You can now close the IP catalog.

Back in Alchitry Labs, you should see some text in the console about finding the new core. You should also see _clk_wiz_0_ added to the **Cores** section of the project tree.

![Screenshot_from_2019-09-16_10-17-14.png](https://cdn.alchitry.com/lucid_v1/Screenshot_from_2019-09-16_10-17-14.png)

We can now hook up the clocks to the memory interface core.

```lucid,short
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
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
   
  sig rst;                  // reset signal
   
  clk_wiz_0 clk_wiz;
   
  // DDR3 Interface - connect inouts directly
  mig_wrapper mig (.ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p));
   
  always {
    /* Clock Wizard Connections */
    clk_wiz.clk_in1 = clk; // 100MHz in
    clk_wiz.reset = !rst_n; // reset signal
     
    /* DDR3 Connections */
    ddr3_addr = mig.ddr3_addr;
    ddr3_ba = mig.ddr3_ba;
    ddr3_ras_n = mig.ddr3_ras_n;
    ddr3_cas_n = mig.ddr3_cas_n;
    ddr3_we_n = mig.ddr3_we_n;
    ddr3_reset_n = mig.ddr3_reset_n;
    ddr3_ck_p = mig.ddr3_ck_p;
    ddr3_ck_n = mig.ddr3_ck_n;
    ddr3_cke = mig.ddr3_cke;
    ddr3_cs_n = mig.ddr3_cs_n;
    ddr3_dm = mig.ddr3_dm;
    ddr3_odt = mig.ddr3_odt;
     
    mig.sys_clk = clk_wiz.clk_out1; // 100MHz clock
    mig.clk_ref = clk_wiz.clk_out2; // 200MHz clock
    mig.sys_rst = !clk_wiz.locked;  // reset when clk_wiz isn't locked
    rst = mig.sync_rst;             // use the reset signal from the mig core
 
    led = 8h00;             // turn LEDs off
 
    usb_tx = usb_rx;        // echo the serial data
  }
}
```

Note that we are using the 100MHz output from the _clk_wiz_ module instead of the _clk_ signal directly. This is to keep the routing in the FPGA simple. The _clk_ only needs to route to the _clk_wiz_0_ core and nowhere else. You can often run into issues if you try to route the clock to special resources like the PLL used by the clock wizard and the general fabric.

The two outputs of the clock wizard are also phase aligned (rising edges match up) which may or may not be important for your design. The same is not true for the input clock and the output clocks. In this case, we don't really care about this.

To clock the rest of our design, we will be using the signal _mig.ui_clk_ which is another synthesized clock from the memory interface. This clock is the one that the user interface is synchronized to. In our case, it is 81.25MHz. This is because our DDR3 interface is setup to run at 325MHz with a 4:1 ratio.

Also notice that we are using the _mig.sync_rst_ signal as our reset. Because of this, we can remove the _reset_conditioner_ module from our top level module.

The reset button on the board will still work as the reset since it is used to reset the clock wizard which then resets the memory controller. This works since the _locked_ output of the clock wizard goes low when it is reset. The locked output goes high when it isn't being reset and the clocks are stable. If you don't hold your circuit in reset when this input isn't high, you risk running into glitches as the clocks may be doing weird things.

With all of that we are now fully setup to use the core!

# The user interface

The memory interface abstracts away a ton of the complexities of dealing with DDR3 memory, but the interface we get to it is still reasonably complex.

Check out [this document](https://docs.amd.com/v/u/1.4-English/ug586_7Series_MIS) from Xilinx that details all the information on the core. Skip to page 57 and look at the section labeled **User Interface**.

This section details what each of the signals we will be interacting with do.

The actual signals we need to deal with are a subset of the ones listed. See the two structs declared in the _mig_wrapper_ component for the ones we need.

One thing to note is that while the _cmd_ signal (_app_cmd_ in the Xilinx doc) is three bits wide, it only ever has a value of 0 (for write) and 1 (for read). Other values are used in different configurations of the core (for example, with ECC memory).

There are really three independent interface bundled together used to deal with the controller.

The first is the write FIFO. The controller will store data in a FIFO to be used in subsequent write commands. The signal _wr_rdy_ is 1 when there is space in the buffer. You can write to the buffer by supplying data on _wr_data_ and setting _we_en_ to 1.

The signal _wr_mask_ can be used to ignore bytes in _wr_data_. A 1 means to ignore the corresponding byte. To write the full 16 bytes (128 bits) set _wr_mask_ to 0.

Note that this mask doesn't change which bytes are sent to the DDR3 chip. It is used to control the _DM_ lines which tell the DDR3 chip to ignore certain bytes. If you set _wr_mask_ to 16hFFFF and perform a write, the full 128 bits will still be sent to the DDR3 but nothing will happen.

With data in the FIFO, you can issue a write command.

The command interface can be used when the signal _rdy_ is 1.

To issue a command, set _cmd_ to 0 for a write or 1 for a read, supply the related address on _addr_ and set _en_ to 1.

If you issue a write command, the first value written to the write FIFO will be used as data.

If you issue a read command, once it has been performed, the value will be returned on the read interface.

The read interface consists of _rd_valid_, which is 1 when there is new data, and _rd_data_, which is the data. After sending a read command, you wait for _rd_valid_ to be 1 which means the data you requested is on _rd_data_.

The reason for the three independent interfaces it efficiency. The command interface may be ready to accept more commands before the read data is fully ready. The write FIFO may also be willing to accept data while a read is being performed.

It is also possible to setup the core to allow it to reorder the execution of commands to improve efficiency. In this case you may be issuing many commands while waiting for the first read command to finish. However, to keep things simple, our interface configuration uses strict ordering (commands executed in the order given).

# Write and read example

In this next section, we will create a small state machine that first initializes the DDR3 to have sequential values stored and then reads them back displaying them on the LEDs.

Here's the full top level module.

```lucid,short,linenos
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
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
   
  sig rst;                  // reset signal
   
  clk_wiz_0 clk_wiz;
   
  // DDR3 Interface - connect inouts directly
  mig_wrapper mig (.ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p));
   
  .clk(mig.ui_clk) {
    .rst(rst) {
      fsm state = {WRITE_DATA, WRITE_CMD, READ_CMD, WAIT_READ, DELAY};
      dff ctr[24];
      dff address[8];
      dff led_reg[8];
    }
  }
   
  always {
    /* Clock Wizard Connections */
    clk_wiz.clk_in1 = clk; // 100MHz in
    clk_wiz.reset = !rst_n; // reset signal
     
    /* DDR3 Connections */
    ddr3_addr = mig.ddr3_addr;
    ddr3_ba = mig.ddr3_ba;
    ddr3_ras_n = mig.ddr3_ras_n;
    ddr3_cas_n = mig.ddr3_cas_n;
    ddr3_we_n = mig.ddr3_we_n;
    ddr3_reset_n = mig.ddr3_reset_n;
    ddr3_ck_p = mig.ddr3_ck_p;
    ddr3_ck_n = mig.ddr3_ck_n;
    ddr3_cke = mig.ddr3_cke;
    ddr3_cs_n = mig.ddr3_cs_n;
    ddr3_dm = mig.ddr3_dm;
    ddr3_odt = mig.ddr3_odt;
     
    mig.sys_clk = clk_wiz.clk_out1; // 100MHz clock
    mig.clk_ref = clk_wiz.clk_out2; // 200MHz clock
    mig.sys_rst = !clk_wiz.locked;  // reset when clk_wiz isn't locked
    rst = mig.sync_rst;             // use the reset signal from the mig core
     
    led = led_reg.q;        // set leds to show led_reg value
     
    usb_tx = usb_rx;        // echo the serial data
     
    // default values
    mig.mem_in.en = 0;
    mig.mem_in.cmd = 3bx;
    mig.mem_in.addr = 28bx;
    mig.mem_in.wr_data = 128bx;
    mig.mem_in.wr_mask = 0;
    mig.mem_in.wr_en = 0;
     
    case (state.q) {
      state.WRITE_DATA:
        mig.mem_in.wr_en = 1;
        mig.mem_in.wr_data = address.q;
        if (mig.mem_out.wr_rdy)
          state.d = state.WRITE_CMD;
       
      state.WRITE_CMD:
        mig.mem_in.en = 1;
        mig.mem_in.cmd = 0; // 0 = write
        mig.mem_in.addr = c{address.q, 3b000}; // first three bits of addr are for the 8 words in wr_data
        if (mig.mem_out.rdy) {
          address.d = address.q + 1;
          state.d = state.WRITE_DATA;
          if (address.q == 8hFF) {
            state.d = state.READ_CMD;
            address.d = 0;
          }
        }
       
      state.READ_CMD:
        mig.mem_in.en = 1;
        mig.mem_in.cmd = 1; // 1 = read
        mig.mem_in.addr = c{address.q, 3b000};
        if (mig.mem_out.rdy)
          state.d = state.WAIT_READ;
       
      state.WAIT_READ:
        if (mig.mem_out.rd_valid) {
          led_reg.d = mig.mem_out.rd_data[7:0];
          state.d = state.DELAY;
          address.d = address.q + 1;
        }
       
      state.DELAY:
        ctr.d = ctr.q + 1; // delay so we can see the value
        if (&ctr.q)
          state.d = state.READ_CMD;
    }
  }
}
```

First notice that we used the signal _mig.ui_clk_ in the _.clk_ block for our dffs and fsm. This is the clock that the user interface of the memory interface is synchronized to. If you need to use a different clock for the rest of your design, you'll have to implement some clock domain crossing scheme. It is easiest if you can make your design work at the 81.25MHz of this clock.

If you look a little lower in the _always_ block, you'll see the default values we assign to the _mem_in_ struct on the _mig_ module. The _wr_mask_ signal is active low, meaning a 0 enables the byte. Since we will be writing all the bytes we can fix it to 0.

The other values we don't care about when the enable signals are 0 so they are set to x.

The state machine is simple, it starts in _WRITE_DATA_ where it writes a value to the write FIFO. Once the value is written, which is noted by _wr_en_ and _wr_rdy_ both being 1, it switches to the _WRITE_CMD_ state.

In this state, it sends the write command. One thing to note is that the address associated with the write is the **DDR native address**. This means that the first three bits should always be 0 since each DDR entry is 16 bits (the DDR3 on the Au has a 16 bit bus) and each read/write we preform is on 128 bit blocks.

This is easy to do by concatenating three 0's onto the end of our address.

```lucid,linenos,linenostart=87
mig.mem_in.addr = c{address.q, 3b000}; // first three bits of addr are for the 8 words in wr_data
```

The 128 bit operation size isn't configurable. Xillinx's memory interface uses bursts of 8 to increase efficiency. This is common practice when working with DDR memory. Also note that the DDR interface is clocked at 4x the system clock which means that you complete an entire burst in the span of a single system clock cycle (4x freq * 2 for double data rate = 8 values per system cycle).

The burst operation is actually supported by the DDR3 chip itself. The address you give the memory interface is sent directly the the DDR3 chip. If you don't set the last three bits to 0 weird things happen. For writes, these bits are ignored and everything works as if they were 0.

For reads, the same 16 bit words in the burst will be read from same 128 bit block but in a different order. For example, if the last three bits are 0, then they are read in the expected order, 0, 1, 2, 3, 4, 5, 6, and 7. However, if you set the last three bits to 2 then it will read them in the order 2, 3, 0, 1, 6, 7, 4, and 5. See page 145 of [this document](https://media-www.micron.com/-/media/client/global/documents/products/data-sheet/dram/ddr3/2gb_1_35v_ddr3l.pdf) for the full behavior. The memory controller is setup to use the sequential burst type.

It is generally best to just ensure these bits are always 0. The reason this feature exists is so that you can get a specific 16 bit value as soon as possible while still reading in a burst of 8.

Note that we are writing the address' value to each address. In other words, address 0 gets value 0, address 1 gets value 1, and so on. This means when we read these back in order, it'll look like a counter.

Once all 256 addresses have been written, it switches to reading. The _READ_CMD_ state issues the read command and then transitions to the _WAIT_READ_ state.

In the _WAIT_READ_ state, it waits for _rd_valid_ to be 1. It then uses the read value to set the LED's state.

Finally, it goes into the _DELAY_ state to waste some time so we can see the LED value before it loops to _READ_CMD_ again.

It will continue reading the first 256 addresses of the DDR3 over and over.

If you change what value is written in the _WRITE_DATA_ state, it'll change what the LEDs show.

With this you should be able to build the project and load it onto your board to see the LEDs counting.

# Caching

You may have noticed that this example is incredibly wasteful. We are reading and writing full 128 bit blocks of data when we are only using the first 8 bits.

This could be fixed if we just combined 16 values into 128 bit blocks and wrote those to a single address. When we read them we could then store a while line and iterate over each byte before reading in another line.

For our trivial example, it wouldn't be too hard to implement this directly. However, for more complex read/write patterns, this could be very difficult to do efficiently.

Luckily, there is a component in the _component library_ that can help us with this.

Go to **Project->Add Components** and under _Memory_ select _LRU Cache_.

```lucid,short
module lru_cache #(
    ENTRIES = 2 : ENTRIES > 0,
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
    input<Memory.out> mem_out,
    output<Memory.in> mem_in
  ) {
   
  const WORDS_PER_LINE = 128 / WORD_SIZE;
  const BYTES_PER_WORD = WORD_SIZE / 8;
  const SUB_ADDR_BITS = $clog2(WORDS_PER_LINE);
  const ADDR_SIZE = 24 + SUB_ADDR_BITS;
   
  .clk(clk) {
    .rst(rst) {
      dff active[ENTRIES];
       
      fsm state = {IDLE, PREP_WRITE_ENTRY, PREP_READ_ENTRY, FLUSH, WRITE_DATA, WRITE_CMD, READ_CMD, WAIT_READ};
      fsm write_state = {IDLE, PUT};
      fsm read_state = {IDLE, FETCH};
    }
     
    dff buffer[ENTRIES][WORDS_PER_LINE][WORD_SIZE];
    dff address[ENTRIES][25];
     
    dff written[ENTRIES];
    dff valid[ENTRIES][WORDS_PER_LINE];
    dff age[ENTRIES][AGE_BITS];
     
    dff active_entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1];
     
    dff read_data[WORD_SIZE];
    dff read_valid;
     
    dff read_pending;
    dff read_addr[ADDR_SIZE];
     
    dff write_pending;
    dff write_addr[ADDR_SIZE];
    dff write_data[WORD_SIZE];
     
    dff old_active[ENTRIES];
    dff return_state[state.WIDTH];
  }
   
  var i;
  sig handled;
  sig oldest_entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1];
  sig entry[ENTRIES > 1 ? $clog2(ENTRIES) : 1];
  sig max_age[age.WIDTH[1]];
   
  always {
    mem_in.en = 0;
    mem_in.wr_data = $flatten(buffer.q[active_entry.q]);
    mem_in.cmd = bx;
    mem_in.addr = c{address.q[active_entry.q], 3b000};
    mem_in.wr_en = 0;
    flush_ready = state.q == state.IDLE;
    wr_ready = write_state.q == write_state.IDLE;
    rd_ready = read_state.q == read_state.IDLE;
    rd_data = read_data.q;
    rd_data_valid = read_valid.q;
     
    read_valid.d = 0;
     
    // only write out valid bytes (0 = write)
    for (i = 0; i < WORDS_PER_LINE; i++)
      mem_in.wr_mask[i*BYTES_PER_WORD+:BYTES_PER_WORD] = BYTES_PER_WORDx{~valid.q[active_entry.q][i]};
     
    // Keep track of the oldest entry (the one to replace)
    max_age = 0;
    oldest_entry = 0;
     
    handled = 0;
    for (i = 0; i < ENTRIES; i++) {
      if (!handled) {
        if (!active.q[i]) { // entry isn't in use
          oldest_entry = i; // use the inactive entry
          handled = 1;      // stop the for loop
        }
        if (age.q[i] > max_age) {
          max_age = age.q[i];
          oldest_entry = i;
        }
      }
    }
     
    case (read_state.q) {
      read_state.IDLE:
        if (rd_cmd_valid) {
          for (i = 0; i < ENTRIES; i++) // increment all the entry ages
            if (!(&age.q[i]))
              age.d[i] = age.q[i] + 1;
           
           
          handled = 0;
          for (i = 0; i < ENTRIES; i++) {
            if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? rd_addr[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == rd_addr[ADDR_SIZE-1:SUB_ADDR_BITS])) {
              handled = 1;
              read_valid.d = 1;
              read_data.d = buffer.q[i][SUB_ADDR_BITS > 0 ? rd_addr[SUB_ADDR_BITS-1:0] : 0];
              age.d[i] = 0; // reset the age on an access
            }
          }
          if (!handled) { // entry isn't in the cache
            read_pending.d = 1;
            read_addr.d = rd_addr;
            read_state.d = read_state.FETCH;
          }
        }
       
      read_state.FETCH:
        read_pending.d = 1;
         
        handled = 0;
        for (i = 0; i < ENTRIES; i++) {
          if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
            handled = 1;
            read_valid.d = 1;
            read_data.d = buffer.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0];
            age.d[i] = 0; // reset the age on an access
          }
        }
        if (handled) {
          read_pending.d = 0;
          read_state.d = read_state.IDLE;
        }
    }
     
    case (write_state.q) {
      write_state.IDLE:
        if (wr_valid) {
          for (i = 0; i < ENTRIES; i++) // increment all the entry ages
            if (!(&age.q[i]))
              age.d[i] = age.q[i] + 1;
           
          handled = 0;
          for (i = 0; i < ENTRIES; i++) {
            if (!handled && active.q[i] && (address.q[i] == wr_addr[ADDR_SIZE-1:SUB_ADDR_BITS])) {
              handled = 1;
              written.d[i] = 1;
              valid.d[i][SUB_ADDR_BITS > 0 ? wr_addr[SUB_ADDR_BITS-1:0] : 0] = 1;
              buffer.d[i][SUB_ADDR_BITS > 0 ? wr_addr[SUB_ADDR_BITS-1:0] : 0] = wr_data;
              age.d[i] = 0; // reset the age on an access
            }
          }
           
          if (!handled) { // entry isn't in the cache
            write_pending.d = 1;
            write_data.d = wr_data;
            write_addr.d = wr_addr;
            write_state.d = write_state.PUT;
          }
        }
       
      write_state.PUT:
        write_pending.d = 1;
         
        handled = 0;
        for (i = 0; i < ENTRIES; i++) {
          if (!handled && active.q[i] && (address.q[i] == write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
            handled = 1;
            written.d[i] = 1;
            valid.d[i][SUB_ADDR_BITS > 0 ? write_addr.q[SUB_ADDR_BITS-1:0] : 0] = 1;
            buffer.d[i][SUB_ADDR_BITS > 0 ? write_addr.q[SUB_ADDR_BITS-1:0] : 0] = write_data.q;
            age.d[i] = 0; // reset the age on an access
          }
        }
         
        if (handled) {
          write_pending.d = 0;
          write_state.d = write_state.IDLE;
        }
    }
     
    case (state.q) {
      state.IDLE:
        if (flush) { // flush command takes priority
          active.d = 0;
          old_active.d = active.q;
          state.d = state.FLUSH;
           
        } else if (read_pending.q) { // Read command is pending
          entry = oldest_entry; // default to oldest
           
          // check for a cache line that was written but never read (ie only partially valid)
          handled = 0;
          for (i = 0; i < ENTRIES; i++) {
            if (!handled && active.q[i] && valid.q[i][SUB_ADDR_BITS > 0 ? read_addr.q[SUB_ADDR_BITS-1:0] : 0] && (address.q[i] == read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])) {
              handled = 1;
              entry = i;
            }
          }
           
          // save the entry
          active_entry.d = entry;
           
          // if entry is active and not our address
          if (active.q[entry] && address.q[entry] != read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS]) {
            // need to mark inactive then wait for any potential writes
            active.d[entry] = 0;
            state.d = state.PREP_READ_ENTRY;
          } else {
            state.d = state.READ_CMD;
            address.d[entry] = read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS];
            if (address.q[entry] != read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS])
              valid.d[entry] = 0;
          }
           
        } else if (write_pending.q) { // Write command is pending
          // if oldest entry is active
          if (active.q[oldest_entry]) {
            // need to mark inactive then wait for any potential writes
            active.d[oldest_entry] = 0;
            active_entry.d = oldest_entry;
            state.d = state.PREP_WRITE_ENTRY;
          } else { // oldest entry can be cleared
            // prep the new entry
            written.d[oldest_entry] = 0;
            valid.d[oldest_entry] = 0;
            address.d[oldest_entry] = write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS];
            age.d[oldest_entry] = 0;
            active.d[oldest_entry] = 1;
            write_pending.d = 0;
          }
        }
       
      state.PREP_WRITE_ENTRY:
        // if entry was written to
        if (written.q[active_entry.q]) {
          // write the data out
          return_state.d = state.PREP_WRITE_ENTRY;
          state.d = state.WRITE_DATA;
        } else {
          // prep the new entry
          written.d[active_entry.q] = 0;
          valid.d[active_entry.q] = 0;
          address.d[active_entry.q] = write_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS];
          age.d[active_entry.q] = 0;
          active.d[active_entry.q] = 1;
          state.d = state.IDLE;
          write_pending.d = 0;
        }
       
      state.PREP_READ_ENTRY:
        if (written.q[active_entry.q]) {
          // write the data out
          return_state.d = state.PREP_READ_ENTRY;
          state.d = state.WRITE_DATA;
        } else {
          // read in new active_entry
          state.d = state.READ_CMD;
          address.d[active_entry.q] = read_addr.q[ADDR_SIZE-1:SUB_ADDR_BITS];
          valid.d[active_entry.q] = 0;
        }
       
      state.FLUSH:
        state.d = state.IDLE; // default to returning if no entries to flush
         
        handled = 0;
        for (i = 0; i < ENTRIES; i++) {
          // find the first entry that needs to be flushed
          if (!handled && old_active.q[i] && written.q[i]) {
            handled = 1;
            active_entry.d = i;
            state.d = state.WRITE_DATA;
            old_active.d[i] = 0;
            return_state.d = state.FLUSH;
          }
        }
       
      state.WRITE_DATA:
        mem_in.wr_en = 1;
        if (mem_out.wr_rdy) {
          state.d = state.WRITE_CMD;
        }
       
      state.WRITE_CMD:
        mem_in.en = 1;
        mem_in.cmd = 0; // write
        if (mem_out.rdy) {
          state.d = return_state.q;
          written.d[active_entry.q] = 0;
        }
       
      state.READ_CMD:
        mem_in.en = 1;
        mem_in.cmd = 1; // read
        if (mem_out.rdy) {
          state.d = state.WAIT_READ;
        }
       
      state.WAIT_READ:
        if (mem_out.rd_valid) {
          for (i = 0; i < WORDS_PER_LINE; i++)
            if (!valid.q[active_entry.q][i]) // only read in unwritten words
              buffer.d[active_entry.q][i] = mem_out.rd_data[WORD_SIZE*i+:WORD_SIZE];
           
          // prep the new entry
          active.d[active_entry.q] = 1;
          valid.d[active_entry.q] = WORDS_PER_LINEx{1b1}; // everything valid
          age.d[active_entry.q] = 0;
          read_pending.d = 0;
          written.d[active_entry.q] = 0;
           
          state.d = state.IDLE;
        }
    }
  }
}
```

This component is pretty complicated but it can take the memory interface from the _MIG Wrapper_ component and give you efficient read and write interfaces of selectable word sizes.

This cache is lazy and will only access the RAM when it needs to. That means you can read and write to entries in the cache as much as you want without hitting the memory. It will only access values in the external memory when it needs to free up a cache line or if you try to read values that aren't in the cache.

The cache presents independant read and write interfaces. This comes in handy when you have one section of your design doing only reads and another doing only writes. If you read and write the same address in the same cycle, you will read the old value.

You can configure the cache to have multiple entries (AKA cache lines). This can save a ton of IO for certain memory access patterns. For example, in our GPU demo project the rasterizer reads values from the Z buffer sequentially and writes values back sequentially at a slightly delayed time down the pipeline. This cache was used with two entries so that the reads and writes would each have their own cache lines to minimize fighting.

This cache attempts to approximate a LRU (**L**east **R**ecently **U**sed) cache policy. This means that when a new cache line is needed, the least recently used (AKA oldest) entry will be evicted.

The age of each entry is kept track of by adding 1 to its age counter every time a read/write is performed to any entry. The age counter can saturate if it isn't accessed in a long time.

Each time an entry is accessed, its age counter is reset.

The maximum age can be set with the _AGE_BITS_ parameter. The default value is 3, which gives a maximum age of 7. This way of keeping track of age isn't perfect and if _AGE_BITS_ is too small, in some cases the cache may not act as a perfect LRU. However, this typically isn't an issue as it will always evict the oldest or a max age cache line.

Setting _AGE_BITS_ to a large value will ensure that the oldest cache line is more likely to be removed but will incur a performance penalty.

## Cache interface

The interface to the cache is pretty simple.

The addresses used are word address. This means you don't need to worry about zero padding anything.

You can set the size of the data word with the _WORD_SIZE_ parameter. This can be set to 8, 16, 32, 64, or 128. 

To write, you simply check _wr_ready_. If this signal is 1, you can specify a value on _wr_data_, an address on _wr_addr_, and set _wr_valid_ to 1. 

To read, you check if _rd_ready_ is 1. If it is, you set _rd_addr_ to the address to read and _rd_cmd_valid_ to 1.

You then wait for _rd_data_valid_ to be 1. When it is, _rd_data_ has your data.

When you perform reads, _rd_data_valid_ is guaranteed to take at least one cycle from the request to go high. However, _rd_ready_ may stay high if it is a cache hit. That means you can stream multiple reads back to back with each result delayed a single cycle if they are all hits.

Cache misses will take longer for _rd_data_valid_ to go high since it will need to actually fetch the value from the RAM.

If you have a cache in your design and are also reading values from another piece of your design, you may need to occasionally flush the cache to ensure that the values are actually written to the DDR3. For this, you can use the ﻿_flush_﻿ signal. When ﻿_flush_﻿ and ﻿_flush_ready_﻿ are high, the cache will write all dirty entries to the DDR3 memory.

## Cache example

With the cache component in our design, we can use it to more efficiently use the DDR3.

```lucid,short
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
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
   
  sig rst;                  // reset signal
   
  clk_wiz_0 clk_wiz;
   
  // DDR3 Interface - connect inouts directly
  mig_wrapper mig (.ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p));
   
  .clk(mig.ui_clk) {
    .rst(rst) {
      fsm state = {WRITE_DATA, READ_CMD, WAIT_READ, DELAY};
      dff ctr[24];
      dff address[8];
      dff led_reg[8];
       
      lru_cache cache(#ENTRIES(1), #WORD_SIZE(8), #AGE_BITS(1));
    }
  }
   
  always {
    /* Clock Wizard Connections */
    clk_wiz.clk_in1 = clk; // 100MHz in
    clk_wiz.reset = !rst_n; // reset signal
     
    /* DDR3 Connections */
    ddr3_addr = mig.ddr3_addr;
    ddr3_ba = mig.ddr3_ba;
    ddr3_ras_n = mig.ddr3_ras_n;
    ddr3_cas_n = mig.ddr3_cas_n;
    ddr3_we_n = mig.ddr3_we_n;
    ddr3_reset_n = mig.ddr3_reset_n;
    ddr3_ck_p = mig.ddr3_ck_p;
    ddr3_ck_n = mig.ddr3_ck_n;
    ddr3_cke = mig.ddr3_cke;
    ddr3_cs_n = mig.ddr3_cs_n;
    ddr3_dm = mig.ddr3_dm;
    ddr3_odt = mig.ddr3_odt;
     
    mig.sys_clk = clk_wiz.clk_out1; // 100MHz clock
    mig.clk_ref = clk_wiz.clk_out2; // 200MHz clock
    mig.sys_rst = !clk_wiz.locked;  // reset when clk_wiz isn't locked
    rst = mig.sync_rst;             // use the reset signal from the mig core
     
    led = led_reg.q;        // set leds to show led_reg value
     
    usb_tx = usb_rx;        // echo the serial data
     
    mig.mem_in = cache.mem_in;
    cache.mem_out = mig.mem_out;
     
    // default values
    cache.flush = 0; // don't need to flush
    cache.wr_addr = address.q;
    cache.wr_data = address.q;
    cache.wr_valid = 0;
    cache.rd_addr = address.q;
    cache.rd_cmd_valid = 0;
     
    case (state.q) {
      state.WRITE_DATA:
        if (cache.wr_ready) {
          cache.wr_valid = 1;
          address.d = address.q + 1;
          if (address.q == 8hFF) {
            state.d = state.READ_CMD;
            address.d = 0;
          }
        }
 
      state.READ_CMD:
        if (cache.rd_ready) {
          cache.rd_cmd_valid = 1;
          state.d = state.WAIT_READ;
        }
       
      state.WAIT_READ:
        if (cache.rd_data_valid) {
          led_reg.d = cache.rd_data;
          state.d = state.DELAY;
          address.d = address.q + 1;
        }
       
      state.DELAY:
        ctr.d = ctr.q + 1; // delay so we can see the value
        if (&ctr.q)
          state.d = state.READ_CMD;
    }
  }
}
```

This new design performs exactly the same as before, but now we are using the DDR3 more efficiently. We are using 1/16th the memory as we were before without having to complicate our design. It actually simplifies the design since the writes don't require separate operations to write the data and command.

Note that _ENTRIES_ is set to 1 since our access pattern is super simple and having more entries won't increase the number of cache hits we have (unless _ENTRIES_ was set to 16 which would mean everything would fit in the cache).

We also set _AGE_BITS_ to 1 since there isn't much of a choice which entry to evict with there is only 1.

In this super basic use case, the cache component is overkill. However, the tools will optimize a lot of the logic out keeping it fairly efficient.

# Multiple devices

It is common to want to interface multiple parts of your design with the one memory interface. To make this easy there is a component in the _Components LIbrary_ called _DDR Arbiter_ under the _Memory_ section.

```lucid,short
module ddr_arbiter #(
    DEVICES = 2 : DEVICES > 1
  )(
    input clk,  // clock
    input rst,  // reset
    // Master
    output<memory.in> master_in,
    input<memory.out> master_out,
    // Devices
    input<memory.in> device_in[DEVICES],
    output<memory.out> device_out[DEVICES]
  ) {
   
  .clk(clk) {
    .rst(rst) {
      fsm state = {WAIT_CMD, WAIT_WRITE, WAIT_RDY};
       
      fifo fifo (#SIZE($clog2(DEVICES)), #DEPTH(256));
      dff device[$clog2(DEVICES)];
    }
  }
   
  var i, act;
   
  always {
    fifo.din = bx;
    fifo.wput = 0;
    fifo.rget = 0;
     
    master_in.en = 0;
    master_in.wr_data = bx;
    master_in.cmd = 0;
    master_in.wr_mask = 0;
    master_in.addr = bx;
    master_in.wr_en = 0;
     
    for (i = 0; i < DEVICES; i++) {
      device_out[i].rdy = 0;
      device_out[i].wr_rdy = 0;
    }
     
    case (state.q) {
      state.WAIT_CMD:
        act = 0;
        for (i = 0; i < DEVICES; i++) {
          if ((device_in[i].en || device_in[i].wr_en) && !act) {
            act = 1;
            device.d = i;
            master_in = device_in[i];
            device_out[i] = master_out;
            if (device_in[i].en && (device_in[i].cmd == 3b001)) { // read
              fifo.wput = 1;
              fifo.din = i;
              if (!master_out.rdy) {
                state.d = state.WAIT_RDY;
              }
            } else { // write
              if (!master_out.wr_rdy) {
                state.d = state.WAIT_WRITE;
              } else {
                state.d = state.WAIT_RDY;
              }
            }
          }
        }
       
      state.WAIT_WRITE:
        master_in = device_in[device.q];
        device_out[device.q] = master_out;
        if (master_out.wr_rdy) {
          if (device_in[device.q].en && master_out.rdy) {
            state.d = state.WAIT_CMD;
          } else {
            state.d = state.WAIT_RDY;
          }
        }
       
      state.WAIT_RDY:
        master_in = device_in[device.q];
        device_out[device.q] = master_out;
        if (master_out.rdy) {
          state.d = state.WAIT_CMD;
        }
    }
     
    for (i = 0; i < DEVICES; i++) {
      device_out[i].rd_data = bx;
      device_out[i].rd_valid = 0;
    }
     
    if (master_out.rd_valid) {
      device_out[fifo.dout].rd_data = master_out.rd_data;
      device_out[fifo.dout].rd_valid = 1;
      fifo.rget = 1;
    }
  }
}
```

This module can be hooked up to the memory interface via the _master_in_ and _master_out_ signals. You then get _DEVICES_ number of similar interfaces on the _device_in_ and _device_out_ arrays that can be hooked up to different parts of your design.

For example, in our GPU project, we have a section that writes frames and another that reads the buffer to display the frames on the LCD.

It is important to order your devices carefully since the device attached to index 0 get full priority. If it never has idle bus time, it'll starve out all the other devices.