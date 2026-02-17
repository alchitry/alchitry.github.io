+++
title = "SDRAM"
weight = 12
+++

This tutorial will cover how **DRAM** (**D**ynamic **R**andom **A**ccess **M**emory), or more specifically **SDRAM** (**S**ynchronized **DRAM**), works and how you can use it in your projects. We will be using the SDRAM Shield.

### What is RAM?

It is first important to understand what **RAM** is in general before diving into a specific type. RAM is simply a large block of memory that you can access more or less at random very quickly. It provides temporary storage for your design for things like images, video, or sampled data. In some applications it can even be used to store the instructions and data for a processor.

Notice the word **temporary** I used. This is because RAM is a volatile form of memory. That means without power, the contents of the memory will be lost.

RAM is organized into banks, rows, and columns. I like to think of RAM as a set of notebooks where each notebook is a _bank_, each page is a _row_, and each line is a _column_. Each bank, or notebook, can be accessed independently of the other banks. Each bank is comprised of many rows and each row has many columns. To access a specific piece of data you must specify all three pieces of information, the bank, row, and column.

The actual protocol required to access data depends on the type of RAM being used. However, all RAM breaks our a very similar interface. You generally have an address input, which specifies the row and column, a bank select input, which specifies the bank, a data input/output, which is used for reading and writing data, and a few control signals.

### How DRAM works

So now you know that any type of RAM is used to store large amount of data, how does it actually store this data?

The basic storage element behind DRAM is the capacitor. Just as a basic refresher, a capacitor is a device that is able to store a charge. You can think of them much like a balloon. Just as you can fill a balloon with some air, you can fill a capacitor with some charge.

The basic cell in DRAM looks like the following.

![sdram_cell_0234e479-2cf8-4dc8-aedc-e20317664098.png](https://cdn.alchitry.com/lucid_v1/mojo/sdram_cell_0234e479-2cf8-4dc8-aedc-e20317664098.png)

There is simply a capacitor that stores a charge, and a transistor that allows charge to either be put into the capacitor or taken out.

These cells are arranged into a large 2D array of _rows_ and _columns_. These are the same rows and columns from before.

When you write data to DRAM, charge is placed on capacitors that should have a value of 1, but no charge is placed on capacitors that have a value of 0.

When you read data from DRAM, the charge on the capacitor is measured using a circuit called a **sense amplifier**. If the sense amplifier detected charge on the capacitor then it outputs a 1, otherwise it assumes the cell was a 0.

There are a two main problems to the fundamental design of DRAM. First, to read the charge from the capacitor, the charge must be drained. This causes all reads to be destructive. Once you read a piece of data from DRAM, the value is no longer being stored in the memory array. To deal with this, the data **must** be written back into the array when you are done with it. This is called **precharging**.

To make the interface to DRAM a bit more efficient, an entire row is read into a buffer in the DRAM. The process of reading a row into that buffer is referred to as **opening** or **activating** the row. Once a row is open, data can be read or written to any columns in that row without having to open it again.

However, only one row per bank can be open at a time. To read from a different row in the same bank, you must first **precharge** the current row, then **open** the new row.

The second fundamental flaw of DRAM, and the reason it is called **dynamic** RAM, is that capacitors _leak_ charge. That means that once a charge is stored on a capacitor, it will start losing that charge. This happens either through the transistor connected to it, or through the capacitor itself. What this means for your data is that, if neglected, the values stored will be lost.

The fix to this problem is to periodically **refresh** each row. A refresh consists of simply reading a row then writing it back into the array. This process ensures that the capacitors retain their charge.

The amount of time a row can go between refreshes depends on the DRAM. However, the SDRAM chip on the SDRAM Shield, must be refreshed every **64ms**.

Generally, SDRAM will be able to perform the refresh operation for you. However, you still must tell it when to refresh.

### DRAM vs SDRAM

The difference between these two types of RAM is that SDRAM is **synchronous** and DRAM is not. All this means is that the SDRAM uses a clock while DRAM does not. The benefits to SDRAM are that inputs and outputs are synchronized to whatever it is connected to, in our case the FPGA, as well as some speed benefits due to pipelining.

SDRAM is much more common than plain DRAM.

It is also worth noting that **DDR** (**D**ouble **D**ata **R**ate) RAM, usually heard in the context of computers, is a form of SDRAM.

### DRAM vs SRAM

The difference between DRAM and SRAM is a bit more interesting. SRAM operates fundamentally differently than DRAM. It doesn't store data on capacitors, but instead uses two inverters back to back.

![sram_cell_5e0b76ab-6ad6-4443-bfde-d976110ff738.png](https://cdn.alchitry.com/lucid_v1/mojo/sram_cell_5e0b76ab-6ad6-4443-bfde-d976110ff738.png)

This solves the two problems discussed earlier about destructive reads and forgetting the value. However, this comes at a price, literally. SRAM is much more expensive than DRAM due to the fact that the technology is much less dense. Each cell in SRAM is much larger than each cell of DRAM, meaning you can't pack nearly as many into the same area.

SRAM is, however, faster and uses less power than DRAM. Because of this, it is still used frequently in digital systems for things like caches. Modern CPUs have something like 8-16MB of very fast SRAM cache, but the computer can have 1000x that much (8+GB) DRAM.

## The Controller

Create a new project based on the _Base Project_. We now need to add the SDRAM controller to our project. In the _Component Selector_, select _Controllers/SDRAM Controller_. We also need the pin definitions for the SDRAM Shield, so also check off _Constraints/SDRAM Shield_. Add these to your project.

Open up the _sdram.luc_ file and take a look at it. It can be helpful to have the [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf) for the SDRAM chip open.

```lucid,short
// Interface to the SDRAM chip
global Sdram {
  // Outputs
  struct out {
    clk,           // clock
    cle,           // clock enable
    cs,            // chip select
    cas,           // column address strobe
    ras,           // row address strobe
    we,            // write enable
    dqm,           // data tri-state mask
    bank [2],      // bank address
    addr [13]      // column/row address
  }
 
  // Inouts
  struct inOut {
    dq [8]         // data bus
  }
}
 
module sdram (
    input clk,  // clock
    input rst,  // reset
 
    // SDRAM interface
    inout<Sdram.inOut> sdramInOut,
    output<Sdram.out> sdramOut,
 
    // Memory interface
    input<Memory.master> memIn,
    output<Memory.slave> memOut
  ) {
 
  // Commands for the SDRAM
  //const CMD_UNSELECTED    = 4b1000; // Unused
  const CMD_NOP           = 4b0111;   // No operation
  const CMD_ACTIVE        = 4b0011;   // Activate a row
  const CMD_READ          = 4b0101;   // Start a read
  const CMD_WRITE         = 4b0100;   // Start a write
  //const CMD_TERMINATE     = 4b0110; // Unused
  const CMD_PRECHARGE     = 4b0010;   // Precharge a row
  const CMD_REFRESH       = 4b0001;   // Perform a refresh
  const CMD_LOAD_MODE_REG = 4b0000;   // Load mode register
 
  .clk(clk) {
    .rst(rst) {
      fsm state = {
        INIT,            // Initial state
        WAIT,            // Generic wait state
        PRECHARGE_INIT,  // Start initial precharge
        REFRESH_INIT_1,  // Perform first refresh
        REFRESH_INIT_2,  // Perform second refresh
        LOAD_MODE_REG,   // Load mode register
        IDLE,            // Main idle state
        REFRESH,         // Perform a refresh
        ACTIVATE,        // Activate a row
        READ,            // Start a read
        READ_RES,        // Read results
        WRITE,           // Perform a write
        PRECHARE         // Precharge bank(s)
      }; 
    }
 
    // DFF to store the next state to go into after WAIT state
    dff next_state[state.WIDTH];
 
    // IO buffer flip-flops are important for timing
    // The #IOB parameter tells the tools to pack the
    // dff into the IO buffer which is important for
    // consistant timing.
    dff cle (#IOB(1));       // clock enable
    dff dqm (#IOB(1));       // data mask
    dff cmd [4] (#IOB(1));   // command (we, cas, ras, cs)
    dff bank [2] (#IOB(1));  // bank select
    dff a [13] (#IOB(1));    // address
    dff dq [8] (#IOB(1));    // data output
    dff dqi [8] (#IOB(1));   // data input
    dff dq_en;               // data bus output enable
 
    dff addr [23];           // operation address
    dff data [32];           // operation data
    dff rw_op;               // operation read/write flag
 
    dff out_valid;           // output valid
 
    dff delay_ctr [16];      // delay counter
    dff byte_ctr [2];        // byte counter
 
    dff refresh_ctr [10];    // refresh counter
    dff refresh_flag;        // refresh counter expired flag
 
    dff ready;               // controller ready flag
    dff saved_rw;            // saved command read/write flag
    dff saved_addr [23];     // saved command address
    dff saved_data [32];     // saved command data
 
    dff row_open [4];        // row in bank open flags
    dff row_addr [4][13];    // open row addresses
 
    dff precharge_bank [3];  // bank(s) to precharge
  }
 
  // xil_XXX modules aren't real modules but rather
  // hardware primitives inside the FPGA.
 
  // The OODR2 is used to output the FPGA clock to
  // an output pin because a clock can't be directly
  // routed as an output.
  xil_ODDR2 oddr (
    #DDR_ALIGNMENT("NONE"),
    #INIT(0),
    #SRTYPE("SYNC")
  );
 
  // The IODELAY2 is used to delay the clock a bit
  // in order to align the data with the clock edge.
  // These settings assume a 100MHz clock and the
  // SDRAM Shield being stacked next to the Mojo.
  xil_IODELAY2 iodelay (
    #IDELAY_VALUE(0),
    #IDELAY_MODE("NORMAL"),
    #ODELAY_VALUE(100),
    #IDELAY_TYPE("FIXED"),
    #DELAY_SRC("ODATAIN"),
    #DATA_RATE("SDR")
  );
 
  // Connections
  always {
    // Connect the dffs to the outputs
    sdramOut.cle = cle.q;
    sdramOut.cs = cmd.q[3];
    sdramOut.ras = cmd.q[2];
    sdramOut.cas = cmd.q[1];
    sdramOut.we = cmd.q[0];
    sdramOut.dqm = dqm.q;
    sdramOut.bank = bank.q;
    sdramOut.addr = a.q;
    sdramOut.clk = iodelay.DOUT;    // delayed clock
    sdramInOut.enable.dq = dq_en.q;
    sdramInOut.write.dq = dq.q;
 
    memOut.data = data.q;
    memOut.busy = !ready.q;
    memOut.valid = out_valid.q;
 
    // Connections for the IODELAY2
    iodelay.ODATAIN = oddr.Q; // use the ODDR2 output as the source
    iodelay.IDATAIN = 0;
    iodelay.T = 0;
    iodelay.CAL = 0;
    iodelay.IOCLK0 = 0;
    iodelay.IOCLK1 = 0;
    iodelay.CLK = 0;
    iodelay.INC = 0;
    iodelay.CE = 0;
    iodelay.RST = 0;
 
    // Connections for the ODDR2
    oddr.C0 = clk;
    oddr.C1 = ~clk;
    oddr.CE = 1;
    oddr.D0 = 0; // using 0 for D0 and 1 for D1 inverts the clock
    oddr.D1 = 1; // because D0 is output on the rising edge of C0
    oddr.R = 0;
    oddr.S = 0;
  }
 
  // Logic
  always {
    // default values
    dqi.d = sdramInOut.read.dq;
    dq_en.d = 0;
    cmd.d = CMD_NOP;
    dqm.d = 0;
    bank.d = 0;
    a.d = 0;
    out_valid.d = 0;
    byte_ctr.d = 0;
 
    // Continuously increment the refresh counter
    // If it reaches 750, 7.5us has elapsed and a refresh needs to happen
    // The maximum delay is 7.813us
    refresh_ctr.d = refresh_ctr.q + 1;
    if (refresh_ctr.q > 750) {
      refresh_ctr.d = 0;  // reset the timer
      refresh_flag.d = 1; // set the refresh flag
    }
 
    // If we are ready for a new command and we get one...
    if (ready.q && memIn.valid) {
      saved_rw.d = memIn.write;  // save the type
      saved_data.d = memIn.data; // save the data
      saved_addr.d = memIn.addr; // save the address
      ready.d = 0;               // don't accept new commands
    }
 
    case (state.q) {
      ///// INTIALIZE /////
      state.INIT:
        ready.d = 0;                          // not ready while initializing
        row_open.d = 0;                       // no rows open yet 
        cle.d = 1;                            // enable the clock
        state.d = state.WAIT;                 // need to wait
        delay_ctr.d = 10100;                  // for 101us (100us minimum)
        next_state.d = state.PRECHARGE_INIT;  // move to PRECHARGE_INIT after
 
      state.WAIT:
        delay_ctr.d = delay_ctr.q - 1;        // decrement counter
        if (delay_ctr.q == 0) {               // if 0
          state.d = next_state.q;             // go to the next state
          if (next_state.q == state.WRITE) {  // if it's WRITE
            dq_en.d = 1;                      // enable the data bus
            dq.d = data.q[7:0];               // and output the first byte
          }
        }
 
      state.PRECHARGE_INIT:
        cmd.d = CMD_PRECHARGE;                // need to precharge all banks
        a.d[10] = 1;                          // all banks
        state.d = state.WAIT;                 // need to wait after
        next_state.d = state.REFRESH_INIT_1;  // move to REFRESH_INIT_1 after
        delay_ctr.d = 0;                      // delay 20ns (min 15ns)
 
      state.REFRESH_INIT_1:
        cmd.d = CMD_REFRESH;                  // need to perform two refreshes
        state.d = state.WAIT;                 // need to wait after a refresh
        next_state.d = state.REFRESH_INIT_2;  // move to REFRESH_INIT_2 after
        delay_ctr.d = 7;                      // delay 90ns (min 66ns)
 
      state.REFRESH_INIT_2:
        cmd.d = CMD_REFRESH;                  // need to perform two refreshes
        state.d = state.WAIT;                 // need to wait after a refresh
        next_state.d = state.LOAD_MODE_REG;   // move to LOAD_MODE_REG after
        delay_ctr.d = 7;                      // delay 90ns (min 66ns)
 
      state.LOAD_MODE_REG:
        cmd.d = CMD_LOAD_MODE_REG;            // load the mode register
 
        // Reserved, Burst Access, Standard Op, CAS = 2, Sequential, Burst = 4
        a.d = c{3b000, 1b0, 2b00, 3b010, 1b0, 3b010};
 
        state.d = state.WAIT;                 // need to wait 
        next_state.d = state.IDLE;            // move to IDLE after
        delay_ctr.d = 1;                      // delay 30ns (min 2 clock cycles)
        refresh_flag.d = 0;                   // don't need refresh
        refresh_ctr.d = 1;                    // reset the counter
        ready.d = 1;                          // we can now accept commands
 
      ///// IDLE STATE /////
      state.IDLE:
        if (refresh_flag.q) {                 // if we need to perform a refresh
          state.d = state.PRECHARE;           // first precharge everything
          next_state.d = state.REFRESH;       // then refresh
          precharge_bank.d = 3b100;           // precharge all banks
          refresh_flag.d = 0;                 // refresh was taken care of
        } else if (!ready.q) {                // if we have a waiting command
          ready.d = 1;                        // we can accept another now
          rw_op.d = saved_rw.q;               // save the command type
          addr.d = saved_addr.q;              // save the address
 
          if (saved_rw.q)                     // if write
            data.d = saved_data.q;            // save the data
 
          // if there is already an open row
          if (row_open.q[saved_addr.q[9:8]]) {
            // if the row is the one we want
            if (row_addr.q[saved_addr.q[9:8]] == saved_addr.q[22:10]) {
              // the row is already open so just perform the operation
              if (saved_rw.q)
                state.d = state.WRITE;
              else
                state.d = state.READ;
            } else {                          // need to open the row
              state.d = state.PRECHARE;       // first need to close current one
              precharge_bank.d = c{1b0, saved_addr.q[9:8]}; // row to close
              next_state.d = state.ACTIVATE;  // then open the correct one
            }
          } else {                            // nothing is already open
            state.d = state.ACTIVATE;         // so just open the row
          }
        }
 
      ///// REFRESH /////
      state.REFRESH:
        cmd.d = CMD_REFRESH;                  // send refresh command
        state.d = state.WAIT;                 // need to wait
        next_state.d = state.IDLE;            // go back to IDLE after
        delay_ctr.d = 6;                      // wait 8 cycles, 80ns (min 66ns)
 
      ///// ACTIVATE /////
      state.ACTIVATE:
        cmd.d = CMD_ACTIVE;                   // activate command
        a.d = addr.q[22:10];                  // row address
        bank.d = addr.q[9:8];                 // bank select
        delay_ctr.d = 0;                      // delay 20ns (15ns min)
        state.d = state.WAIT;                 // need to wait
 
        // set the next state based on the command
        next_state.d = rw_op.q ? state.WRITE : state.READ;
 
        row_open.d[addr.q[9:8]] = 1;          // row is now open 
        row_addr.d[addr.q[9:8]] = addr.q[22:10]; // address of row
 
      ///// READ /////
      state.READ:
        cmd.d = CMD_READ;                     // read command
        a.d = c{2b0, 1b0, addr.q[7:0], 2b0};  // address of column
        bank.d = addr.q[9:8];                 // bank select
        state.d = state.WAIT;                 // need to wait
        next_state.d = state.READ_RES;        // go to READ_RES after
        delay_ctr.d = 2;                      // wait 3 cycles
 
      state.READ_RES:
        byte_ctr.d = byte_ctr.q + 1;          // count 4 bytes
        data.d = c{dqi.q, data.q[31:8]};      // shift in each byte
        if (byte_ctr.q == 3) {                // if we read all 4 bytes
          out_valid.d = 1;                    // output is valid
          state.d = state.IDLE;               // return to IDLE
        }
 
      ///// WRITE /////
      state.WRITE:
        byte_ctr.d = byte_ctr.q + 1;          // count 4 bytes
 
        if (byte_ctr.q == 0)                  // first byte is write command
          cmd.d = CMD_WRITE;                  // send command
 
        dq.d = data.q[7:0];                   // output the data
        data.d = data.q >> 8;                 // shift data
        dq_en.d = 1;                          // enable data bus output
        a.d = c{2b0, 1b0, addr.q[7:0], 2b0};  // column address
        bank.d = addr.q[9:8];                 // bank select
 
        if (byte_ctr.q == 3)                  // if we wrote all 4 bytes
          state.d = state.IDLE;               // return to IDLE
 
      ///// PRECHARGE /////
      state.PRECHARE:
        cmd.d = CMD_PRECHARGE;                // precharge command
        a.d[10] = precharge_bank.q[2];        // all banks flag
        bank.d = precharge_bank.q[1:0];       // single bank select
        state.d = state.WAIT;                 // need to wait
        delay_ctr.d = 0;                      // delay 20ns (15ns min)
 
        if (precharge_bank.q[2])              // if all banks flag
          row_open.d = 0;                     // they are all closed
        else                                  // otherwise
          row_open.d[precharge_bank.q[1:0]] = 0; // only selected was closed
 
      default:                                // shouldn't be here
        state.d = state.INIT;                 // restart the FSM
    }
  }
}
```

This module uses some new advanced features that we haven't covered yet so let's get right into it.

### Structs

The most obvious new part to this module is the the use of _structs_. In this case, two structs are declared in the global namespace _Sdram_.

```lucid
// Interface to the SDRAM chip
global Sdram {
  // Outputs
  struct out {
    clk,           // clock
    cle,           // clock enable
    cs,            // chip select
    cas,           // column address strobe
    ras,           // row address strobe
    we,            // write enable
    dqm,           // data tri-state mask
    bank [2],      // bank address
    addr [13]      // column/row address
  }
 
  // Inouts
  struct inOut {
    dq [8]         // data bus
  }
}
```

You can declare structs inside your module, but they are then local to your module and can only be used internally (not in port definitions).

A struct definition consists of the _struct_ keyword, followed by the name of the struct, followed by the list of the struct's members. A member declaration consists of a name, an optional struct type, and an optional array size.

Take a look at the following example.

```lucid
struct color {
  red[8],
  green[8],
  blue[8]
}
struct display {
  x[12],
  y[12],
  pixel<color>
}
```

In this example we have two structs, _color_ and _display_. The _color_ struct has three members, _red_, _green_, and _blue_, each an 8bit array.

The _display_ struct is a bit more complex. The first two elements, _x_ and _y_ are 12bit arrays, but the third, _pixel_ is itself a struct of type _color_.

The _\<name>_ notation is used to specify the struct type. This can be used with struct members, _input_, _output_, _inout_, _sig_, and _dff_ types.

### Accessing Struct Members

Now that we know how to declare a struct, we need to be able to access its members. Let's look at another example.

```lucid
struct foo {
  a,
  b[4],
  c[8]
}
 
.clk(clk) {
  dff<foo> bar;
  dff<foo> cat[2];
}
 
sig<foo> dog;
 
always {
  bar.d.b = bar.q.c[3:0]; // d/q must be selected first
  dog = bar.q;            // structs can be assigned directly to others of the same type
  cat.d[0] = dog;         // need to select a single element before accessing the struct
  cat.d[1].a = bar.q.a; 
}
```

The members of a struct are accessed the same way as the d/q signals of a _dff_ or the signals of a module instance.

The SDRAM controller uses two other structs defined in _memory_bus.luc_. These are split into a different file as they may be used by other modules besides the SDRAM controller.

### The Interface

Take a look at the ports of the SDRAM controller.

```lucid
module sdram (
    input clk,  // clock
    input rst,  // reset
 
    // SDRAM interface
    inout<Sdram.inOut> sdramInOut,
    output<Sdram.out> sdramOut,
 
    // Memory interface
    input<Memory.master> memIn,
    output<Memory.slave> memOut
  ) {
```

We have the canonical clock and reset inputs. We then have a bunch of IO condensed into 4 lines by using structs. The connection to the SDRAM chip consists of an output and an inout. The interface from the controller to the rest of the FPGA is broken into an input and an output. Take a look at the struct definitions for details of their contents.

### Commands

The SDRAM chip accepts a series of commands that we define as constants for easier use.

```lucid
// Commands for the SDRAM
//const CMD_UNSELECTED    = 4b1000; // Unused
const CMD_NOP           = 4b0111;   // No operation
const CMD_ACTIVE        = 4b0011;   // Activate a row
const CMD_READ          = 4b0101;   // Start a read
const CMD_WRITE         = 4b0100;   // Start a write
//const CMD_TERMINATE     = 4b0110; // Unused
const CMD_PRECHARGE     = 4b0010;   // Precharge a row
const CMD_REFRESH       = 4b0001;   // Perform a refresh
const CMD_LOAD_MODE_REG = 4b0000;   // Load mode register
```

These commands connect to the _CS_, _RAS_, _CAS_, and _WE_ pins on the SDRAM. See page 31 of the [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf) if you want to know more.

## The FSM

The entire controller is based around a single FSM.

```lucid
.clk(clk) {
  .rst(rst) {
    fsm state = {
      INIT,            // Initial state
      WAIT,            // Generic wait state
      PRECHARGE_INIT,  // Start initial precharge
      REFRESH_INIT_1,  // Perform first refresh
      REFRESH_INIT_2,  // Perform second refresh
      LOAD_MODE_REG,   // Load mode register
      IDLE,            // Main idle state
      REFRESH,         // Perform a refresh
      ACTIVATE,        // Activate a row
      READ,            // Start a read
      READ_RES,        // Read results
      WRITE,           // Perform a write
      PRECHARE         // Precharge bank(s)
    }; 
  }
```

The relations of these states can be summed up in the state diagram shown below. The _WAIT_ state wasn't shown for clarity.

![sdram_controller_38832f10-c391-47b2-b689-16fda4f17e26.png](https://cdn.alchitry.com/lucid_v1/mojo/sdram_controller_38832f10-c391-47b2-b689-16fda4f17e26.png)

When the board is powered on (or reset) the FSM starts in the _INIT_ state. SDRAM requires a bit of initialization before you can read and write to it. This is also covered in the [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf) (page 42) for those curious.

After the board is initialized, it sits in the _IDLE_ state until one of two things happen, either it's time to perform a refresh or there is a pending operation.

First, let's talk about the refresh. To manage the refreshing, there is a timer that tells the controller to send another refresh operation. The SDRAM requires 8,192 refresh commands to be sent every 64ms. That means you can either send a refresh command every 7.813µs or all 8,192 commands in a batch every 64ms. To provide a more uniform interface, this controller sends the refresh commands evenly spaced. This limits the maximum amount of time the controller will be busy doing refreshes. In some applications where you need very fast burst speeds, but have some known down time, performing burst refreshing can be better.

When a read or write command is pending, the controller first checks to see if the row is open. If the requested row is already open, life is great, it simply reads or writes to the row. If the row isn't open then it first opens the row before performing the operation. The worst case is if there is already another row open. In this case the other row must be precharged, before the controller can open the new row and perform the operation.

Each of these operations has some number of cycles the SDRAM requires to complete (the reason for the _WAIT_ state). These sometimes vary with the clock frequency (in other words, they have a set amount of real time). This controller assumes a clock rate of 100MHz. This is important for other reasons as well that will be discussed a little later. All of these delays and timing specifications can be found in the [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf) (many of them are on pages 27-28).

This mostly sums up how the controller works. If you want an even deeper understanding, you need to take a look at the rest of the code in the controller as well as the SDRAM [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf).

However, there is some advanced voodoo magic going on in the controller code that is worth mentioning.

### Dealing with the Hardware

When you start interfacing with a relatively high speed external device, you start having to deal with FPGA specific details. There are two hardware related issues addressed in the controller. The first is that the FPGA can't route a clock signal directly to an output pin. This is because the clock and general logic of an FPGA share different routing resources and there isn't a way for the clock signal to move back into the general routing system. However, we can use an _ODDR2_ primitive to compensate for this.

```
// The OODR2 is used to output the FPGA clock to
// an output pin because a clock can't be directly
// routed as an output.
xil_ODDR2 oddr (
  #DDR_ALIGNMENT("NONE"),
  #INIT(0),
  #SRTYPE("SYNC")
);
```

```
// Connections for the ODDR2
oddr.C0 = clk;
oddr.C1 = ~clk;
oddr.CE = 1;
oddr.D0 = 0; // using 0 for D0 and 1 for D1 inverts the clock
oddr.D1 = 1; // because D0 is output on the rising edge of C0
oddr.R = 0;
oddr.S = 0;
```

This is the instantiation of a _ODDR2_ module. If you look the project files, you will notice there is no _xil_ODDR2.luc_ file. This is because this isn't really a module, but rather an **FPGA primitive**. ODDR2 or **O**utput **D**ouble **D**ata **R**ate 2, is a primitive that is generally used to output data on both the rising and falling edges of the clock (hence, _double_ data rate). However, in this case we are using the ODDR2 to simply output our clock signal. You can't output the clock signal directly due to how the FPGA is structured internally. So instead, you can use the ODDR with the data pins wired to 0 or 1.

When _C0_ has a rising edge, _D0_ is output until _C1_ has a rising edge. At that point _D1_ is output. Notice that in our case _C1_ is actually just the clock inverted. That means _D0_ is output when the clock rises and _D1_ is output when the clock falls.

You may be thinking now "Ok... but if _D0_ is output when the clock _rises_, shouldn't _D0_ be 1 and _D1_ be 0"? Very good my young padawan. That is exactly right _if_ you wanted to output to be the same as the clock. However, we **don't** want this. We want the output clock to be our clock inverted!

Why the *&^$# would we want the clock to be inverted? Wouldn't that mean that the SDRAM would read it's inputs and change it's outputs on our falling edge? Oh wait... that's exactly what we want! We want this because that gives both devices half a clock cycle for their output to become stable before the other device. This all has to do with satisfying _setup_ and _hold_ times of both devices. If you don't know what the means, check out the [External IO Tutorial](@/tutorials/archive/lucid_v1/mojo/external-io.md).

Timing is the other hardware related issue we need to account for and we will use another FPGA primitive, the _IODELAY2_, to deal with it.

```lucid
// The IODELAY2 is used to delay the clock a bit
// in order to align the data with the clock edge.
// These settings assume a 100MHz clock and the
// SDRAM Shield being stacked next to the Mojo.
xil_IODELAY2 iodelay (
  #IDELAY_VALUE(0),
  #IDELAY_MODE("NORMAL"),
  #ODELAY_VALUE(100),
  #IDELAY_TYPE("FIXED"),
  #DELAY_SRC("ODATAIN"),
  #DATA_RATE("SDR")
);
```

```lucid
// Connections for the IODELAY2
iodelay.ODATAIN = oddr.Q; // use the ODDR2 output as the source
iodelay.IDATAIN = 0;
iodelay.T = 0;
iodelay.CAL = 0;
iodelay.IOCLK0 = 0;
iodelay.IOCLK1 = 0;
iodelay.CLK = 0;
iodelay.INC = 0;
iodelay.CE = 0;
iodelay.RST = 0;
```

As you may have guessed from the name, the _IODELAY2_ block provides a delay to inputs and outputs. In this case we are using it to delay the clock being output to the SDRAM. There are a lot of features of these primitives that aren't being used here. However if you want t check them out in their full glory, take a look at the [UG381](http://www.xilinx.com/support/documentation/user_guides/ug381.pdf) document from Xilinx (ODDR2 starts on page 62 and IODELAY2 starts on page 74).

We need the delay because simply inverting the clock doesn't quite ensure timing is met. We need to shift it a little more.

The important values here are _DELAY_SRC_ is set to make the _IODELAY2_ delay an output and _ODELAY_VALUE_ is how much we want to delay the signal.

The actual amount of delay that is given per step of _ODELAY_VALUE_ is a bit fuzzy and will actually vary over temperature and voltage in the Spartan 6 chip. However, with a 100MHz clock, using a delay of 100 (maximum is 255) ensures that the setup and hold times are being met. This delay was found empirically by running lots of tests checking for read/write errors.

The last piece to the puzzle is making sure that the input and output registers are packed into **IOBs**, or **I**nput **O**utput **B**uffers.

```lucid
// IO buffer flip-flops are important for timing
// The #IOB parameter tells the tools to pack the
// dff into the IO buffer which is important for
// consistant timing.
dff cle (#IOB(1));       // clock enable
dff dqm (#IOB(1));       // data mask
dff cmd [4] (#IOB(1));   // command (we, cas, ras, cs)
dff bank [2] (#IOB(1));  // bank select
dff a [13] (#IOB(1));    // address
dff dq [8] (#IOB(1));    // data output
dff dqi [8] (#IOB(1));   // data input
```

The _dff_ type has a parameter, _IOB_, that, when set to 1, will mark that flip-flop to be packed into an IOB.

What the heck is an IOB? An IOB is simply a flip-flop that is embedded in the pin of the FPGA. They aren't in the typical FPGA fabric, but rather right at the inputs and outputs.

We want to make sure these registers are packed into IOBs to ensure that there are no additional delays due to the signal needing to propagate through the FPGA.

To make sure these registers are actually packed into the IOB, their output/input can't connect to anything other than the top level output/input. If you tried to read these signals in some other part of your design, the tools would be forced to pull the flip-flop out of the IOB, possibly messing up timing. This is why it is important that these signals go directly to the top level inputs/outputs.

### Xilinx Primitives

At the time of writing this, the _IODELAY2_ and _ODDR2_ are the only primitives currently supported by the Mojo IDE. All the supported primitives can be found by typing _xil_ and the auto-complete will list the known modules (the primitives are always prefixed with _xil__). More primitives will be added over time.

This sums up how the controller works, but now we need to use it for something.

## Using the Controller

What good is a fancy SDRAM controller if we don't even use it? NO GOOD that what! To demonstrate how to use the controller we are going to create a tester. Our module will write a bunch of stuff to the RAM then read it back to make sure the contents are still there and correct.

There is one big problem with creating a tester like this. What do we write to the RAM? It has to be something easily _generated_ because we don't have enough memory to memorize all the values. If we did we wouldn't be using the SDRAM. We could use part of the address, but this causes a very artificial pattern that can fail to detect some problems.

Instead we will use a pseudo-random number generator. The key word there is _pseudo_. Which is layman's terms translates to _not-really-a-random number generator_. This is something that generates _random-looking_ numbers but they are actually completely predictable. That's a great property for us because we need to be able to regenerate the exact same 8,388,608 long sequence of numbers to verify our write.

From the components library add _Math/Pseudo-random Number Generator_ to your project.

```lucid
module pn_gen #(
    // SEED needs to always be non-zero
    // Since seed is XORed with the 32MSBs of SEED, we need the 96 LSBs to be nonzero.
    SEED = 128h843233523a613966423b622562592c62: SEED.WIDTH == 128 && SEED[95:0] != 0
  )(
    input clk,       // clock
    input rst,       // reset
    input next,      // generate next number flag
    input seed [32], // seed used on reset
    output num [32]  // "random" number output
  ) {
 
  .clk(clk) {
    dff x[32], y[32], z[32], w[32]; // state storage
  }
 
  sig t [32];                       // temporary results
 
  always {
    num = w.q;                      // output is from w
    t = x.q ^ (x.q << 11);          // calculate intermediate value
 
    if (next) {                     // if we need a new number
      x.d = y.q;                    // shift values along
      y.d = z.q;                   
      z.d = w.q;
 
      // magic formula from Wikipedia
      w.d = w.q ^ (w.q >> 19) ^ t ^ (t >> 8);
    }
 
    // Manually reset the flip-flops so we can change the reset value
    if (rst) {
      x.d = SEED[0+:32];
      y.d = SEED[32+:32];
      z.d = SEED[64+:32];
      w.d = SEED[96+:32] ^ seed;
    }
  }
}
```

This algorithm is called **Xorshift** and it simply is a ported version of one presented on [Wikipedia](https://en.wikipedia.org/wiki/Xorshift).

This module will generate a new number each time _next_ is high. It can be reset to start the sequence over. If the value of _seed_ changes, the sequence will be different.

This type of number generator is great for hardware because it only uses XOR and shift operations. Both of which are really cheap. However, it isn't a super great random number generator and should **not** be used for crypto purposes where it isn't good enough to _look_ random.

## The Memory Interface

Before we get into our tester module, we need to understand the interface used for reading and writing the SDRAM. Take a look at _memory_bus.luc_.

```lucid
// Generic Memory Interface
global Memory {
  // Memory slave outputs/master inputs
  struct slave {
    data [32],     // data read
    valid,         // data valid
    busy           // device busy
  }
 
  // Memory master outputs/slave inputs
  struct master {
    data [32],     // data to write
    valid,         // data valid
    addr [23],     // address to write/read
    write          // 1 = write, 0 = read
  }
}
```

The interface consists of a _master_ and a _slave_. The _slave_ in this case is the SDRAM controller (the one receiving commands) and we will play the role of the _master_ by issuing commands.

Whenever we want to issue a command, we need to first make sure that _slave.busy_ is 0. This indicates that the controller can accept a new command.

To issue a write command we set _master.write_ to 1, _master.addr_ to the address we want to write to, _master.data_ to the value we want to write, and finally _master.valid_ to 1 to indicate a new command.

To perform a read we set _master.write_ to 0, _master.addr_ to the address to read, and _master.valid_ to 1. The value of _master.data_ is ignored. We then need to wait for _slave.valid_ to be 1. When it is 1, _slave.data_ is the value we requested. Note that _slave.busy_ may go back to 0 before the read is actually complete. This is because the busy flag only says when the controller can accept a new request, not necessarily when it idle. If you issue multiple read requests, they will be processed in the order they are received.

## The Tester

Create a new module named _ram_test_ and copy the following into it.

```lucid,short
module ram_test (
    input clk,                         // clock
    input rst,                         // reset
    output<Memory.master> memOut,      // memory interface
    input<Memory.slave> memIn,
    output leds [8]                    // status LEDs
  ) {
 
  .clk(clk){ .rst(rst) {
      fsm state = {WRITE, READ};       // states
 
      dff addr [23];                   // current address
      dff error [7];                   // number of errors
      dff seed [32];                   // seed for each run
    }
    pn_gen pn_gen;                     // pseudo-random number generator
  }
 
  always {
    // Show the state and number of errors on the LEDs
    leds = c{state.q == state.READ, error.q};
 
    pn_gen.seed = seed.q;              // use seed.q as the seed
    pn_gen.next = 0;                   // don't generate new numbers
    pn_gen.rst = rst;                  // connect rst by default
 
    memOut.addr = addr.q;              // use addr.q as the address
    memOut.write = 1bx;                // don't care
    memOut.data = pn_gen.num;          // use the pseudo-random number as data
    memOut.valid = 0;                  // invalid
 
    case (state.q) {
      state.WRITE:
        if (!memIn.busy) {             // if RAM isn't busy
          pn_gen.next = 1;             // generate a new number
          addr.d = addr.q + 1;         // increment the address
          memOut.write = 1;            // perform a write
          memOut.valid = 1;            // command is valid
          if (addr.q == 23x{1}) {      // if address is maxed
            addr.d = 0;                // reset to 0
            state.d = state.READ;      // switch states
            pn_gen.rst = 1;            // reset the number generator
          }
        }
      state.READ:
        if (!memIn.busy) {             // if RAM isn't busy
          addr.d = addr.q + 1;         // increment the address
          memOut.valid = 1;            // command is valid
          memOut.write = 0;            // perform a read
          if (addr.q == 23x{1}-1)      // if address is almost max
            seed.d = seed.q + 1;       // generate a new seed
          if (addr.q == 23x{1}) {      // if address is maxed
            addr.d = 0;                // reset to 0
            state.d = state.WRITE;     // switch state            
            pn_gen.rst = 1;            // reset the number generator
          }
        }
 
        if (memIn.valid) {             // if new data
          pn_gen.next = 1;             // go to the next number
 
          // if the data doesn't match the random number and the
          // error counter isn't maxed out
          if (memIn.data != pn_gen.num && !&error.q)
            error.d = error.q + 1;     // increment the error counter
        }
 
      default:                         // should never get here
        state.d = state.WRITE;         // get to a known state
    }
  }
}
```

Our tester has two states, _WRITE_ and _READ_. We start in the _WRITE_ state and fill up the RAM with random stuff. Once the RAM is full, we reset the number generator and move to the _READ_ state.

In the _READ_ state we read each value back and generate the same sequence of numbers again. If the values we read back don't match the number in our sequence, we increment the error counter. The error counter is setup to saturate at 127 error so if there are a ton of errors it will simply max out.

We need to be able to see what our tester is doing so we will use the LEDs to show the status. We hook up _leds\[7]_ to the state (so we know when it's reading or writing) and the rest to the error counter.

## Generating the Clock

If you've been paying attention (you have haven't you?) you probably noticed that the SDRAM controller says it assumes a clock of 100MHz. However, the Mojo's clock is only 50Mhz. Whatever will do? Luckily the FPGA has a super rad circuit called a PLL that lets you generate new clocks. Even more rad is that there are tools to help us set it up.

We are going to be using the **Core Generator** tool from Xilinx. Support for this tool is built into the Mojo IDE, so simply click _Project->Launch CoreGen_.

![coregen.png](https://cdn.alchitry.com/lucid_v1/mojo/coregen.png)

Under _FPGA Features and Design/Clocking_ double click on _Clocking Wizard_.

![clkwiz1.png](https://cdn.alchitry.com/lucid_v1/mojo/clkwiz1.png)

_You're a clocking wizard Harry!_

Change the name to just _clk_wiz_ because the default is UGLY. Also uncheck _Phase alignment_ (we don't care about that) and set the _primary_ input clock to 50MHz.

![clkwiz2.png](https://cdn.alchitry.com/lucid_v1/mojo/clkwiz2.png)

On the next page you shouldn't have to change anything as _CLK_OUT1_ is already set to generate 100MHz.

![clkwiz3.png](https://cdn.alchitry.com/lucid_v1/mojo/clkwiz3.png)

On page 3, uncheck everything because again, we don't care.

![clkwiz5.png](https://cdn.alchitry.com/lucid_v1/mojo/clkwiz5.png)

Skip page 4 and on page 5, remove the _1_ from the signal names. We only have one input and one output so why bother labeling them 1?

Finally, click _Generate_.

Once it finishes generating the core, you can close all the CoreGen windows. The core should automagically (it's a word, trust me) be under the _Cores_ section of your project.

## The Top Level

Now that we have all the pieces we need to hook it all up.

If you take a look at the _sdram_shield.ucf_ file we added in the beginning of the tutorial, you'll notice that there are only two signals defined.

```ucf
NET "sdramOut<0>" LOC = P5 | IOSTANDARD = LVTTL | SLEW = FAST;     # clk
NET "sdramOut<1>" LOC = P2 | IOSTANDARD = LVTTL | SLEW = FAST;     # cle
NET "sdramOut<6>" LOC = P6 | IOSTANDARD = LVTTL | SLEW = FAST;     # cs
NET "sdramOut<2>" LOC = P115 | IOSTANDARD = LVTTL | SLEW = FAST;   # cas
NET "sdramOut<5>" LOC = P111 | IOSTANDARD = LVTTL | SLEW = FAST;   # ras
NET "sdramOut<3>" LOC = P112 | IOSTANDARD = LVTTL | SLEW = FAST;   # we
NET "sdramOut<4>" LOC = P114 | IOSTANDARD = LVTTL | SLEW = FAST;   # dqm
 
NET "sdramOut<7>" LOC = P116 | IOSTANDARD = LVTTL | SLEW = FAST;   # bank[0]
NET "sdramOut<8>" LOC = P117 | IOSTANDARD = LVTTL | SLEW = FAST;   # bank[1]
 
NET "sdramOut<9>" LOC = P118 | IOSTANDARD = LVTTL | SLEW = FAST;   # addr[0]
NET "sdramOut<10>" LOC = P119 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[1]
NET "sdramOut<11>" LOC = P120 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[2]
NET "sdramOut<12>" LOC = P121 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[3]
NET "sdramOut<13>" LOC = P138 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[4]
NET "sdramOut<14>" LOC = P139 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[5]
NET "sdramOut<15>" LOC = P140 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[6]
NET "sdramOut<16>" LOC = P141 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[7]
NET "sdramOut<17>" LOC = P142 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[8]
NET "sdramOut<18>" LOC = P143 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[9]
NET "sdramOut<19>" LOC = P137 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[10]
NET "sdramOut<20>" LOC = P144 | IOSTANDARD = LVTTL | SLEW = FAST;  # addr[11]
NET "sdramOut<21>" LOC = P1 | IOSTANDARD = LVTTL | SLEW = FAST;    # addr[12]
 
NET "sdramInOut<0>" LOC = P101 | IOSTANDARD = LVTTL | SLEW = FAST; # dq[0]
NET "sdramInOut<1>" LOC = P102 | IOSTANDARD = LVTTL | SLEW = FAST; # dq[1]
NET "sdramInOut<2>" LOC = P104 | IOSTANDARD = LVTTL | SLEW = FAST; # dq[2]
NET "sdramInOut<3>" LOC = P105 | IOSTANDARD = LVTTL | SLEW = FAST; # dq[3]
NET "sdramInOut<4>" LOC = P7 | IOSTANDARD = LVTTL | SLEW = FAST;   # dq[4]
NET "sdramInOut<5>" LOC = P8 | IOSTANDARD = LVTTL | SLEW = FAST;   # dq[5]
NET "sdramInOut<6>" LOC = P9 | IOSTANDARD = LVTTL | SLEW = FAST;   # dq[6]
NET "sdramInOut<7>" LOC = P10 | IOSTANDARD = LVTTL | SLEW = FAST;  # dq[7]
```

This is setup so that all the signals will pack into the structs defined in the SDRAM controller.

We can add them to _mojo_top.luc_ like below.

```lucid
output<Sdram.out> sdramOut,   // SDRAM outputs
inout<Sdram.inOut> sdramInOut // SDRAM inouts
```

We now just need to instantiate our modules and hook everything up.

```lucid,short
module mojo_top (
    input clk,                    // 50MHz clock
    input rst_n,                  // reset button (active low)
    output led [8],               // 8 user controllable LEDs
    input cclk,                   // configuration clock, AVR ready when high
    output spi_miso,              // AVR SPI MISO
    input spi_ss,                 // AVR SPI Slave Select
    input spi_mosi,               // AVR SPI MOSI
    input spi_sck,                // AVR SPI Clock
    output spi_channel [4],       // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,                 // AVR TX (FPGA RX)
    output avr_rx,                // AVR RX (FPGA TX)
    input avr_rx_busy,            // AVR RX buffer full
    output<Sdram.out> sdramOut,   // SDRAM outputs
    inout<Sdram.inOut> sdramInOut // SDRAM inouts
  ) {
 
  sig rst;  // reset signal
  sig fclk; // 100MHz clock
 
  // boost clock to 100MHz
  clk_wiz clk_wiz;
  always {
    clk_wiz.CLK_IN = clk;   // 50MHz in
    fclk = clk_wiz.CLK_OUT; // 100MHz out (it's like magic!)
  }
 
  .clk(fclk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst) {
      // inouts need to be connected at instantiation and directly to an inout of the module
      sdram sdram (.sdramInOut(sdramInOut));
      ram_test ram_test;
    }
  }
 
  always {
    reset_cond.in = ~rst_n;        // input raw inverted reset signal
    rst = reset_cond.out;          // conditioned reset
 
    spi_miso = bz;                 // not using SPI
    spi_channel = bzzzz;           // not using flags
    avr_rx = bz;                   // not using serial port
 
    led = ram_test.leds;           // connect LEDs to ram_test
 
    sdram.memIn = ram_test.memOut; // connect ram_test to controller
    ram_test.memIn = sdram.memOut; // connect controller to ram_test
 
    sdramOut = sdram.sdramOut;     // connect controller to SDRAM
  }
}
```

You should be able to build your project now. Stack your SDRAM Shield onto your Mojo and load the project! If everything went well, you should see the left-most LED blinking and the other 7 off (no errors). Each time the LED blinks, 32MB of data was written and read back from the SDRAM!