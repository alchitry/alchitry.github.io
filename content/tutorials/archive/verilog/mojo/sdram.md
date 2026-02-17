+++
title = "SDRAM"
weight = 18
+++

This tutorial will cover how **DRAM** (**D**ynamic **R**andom **A**ccess **M**emory), or more specifically **SDRAM** (**S**ynchronized **DRAM**), works and how you can use it in your FPGA projects.

### What is RAM?

It is first important to understand what **RAM** is in general before diving into a specific type. RAM is simply a large block of memory that you can access more or less at random very quickly. It provides temporary storage for your design for things like images, video, or sampled data. In some applications it can even be used to store the instructions and data for a processor.

Notice the word **temporary** I used. This is because RAM is a volatile form of memory. That means without power, the contents of the memory will be lost.

RAM is organized into banks, rows, and columns. I like to think of RAM as a set of notebooks where each notebook is a _bank_, each page is a _row_, and each line is a _column_. Each bank, or notebook, can be accessed independently of the other banks. Each bank is comprised of many rows and each row has many columns. To access a specific piece of data you must specify all three pieces of information, the bank, row, and column.

The actual protocol required to access data depends on the type of RAM being used. However, all RAM breaks our a very similar interface. You generally have an address input, which specifies the row and column, a bank select input, which specifies the bank, a data input/output, which is used for reading and writing data, and a few control signals.

### How DRAM works

So now you know that any type of RAM is used to store large amount of data, how does it actually store this data?

The basic storage element behind DRAM is the capacitor. Just as a basic refresher, a capacitor is a device that is able to store a charge. You can think of them much like a balloon. Just as you can fill a balloon with some air, you can fill a capacitor with some charge.

The basic cell in DRAM looks like the following.

![sdram_cell.png](https://cdn.alchitry.com/verilog/mojo/sdram_cell.png)

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

![sram_cell.png](https://cdn.alchitry.com/verilog/mojo/sram_cell.png)

This solves the two problems discussed earlier about destructive reads and forgetting the value. However, this comes at a price, literally. SRAM is much more expensive than DRAM due to the fact that the technology is much less dense. Each cell in SRAM is much larger than each cell of DRAM, meaning you can't pack nearly as many into the same area.

SRAM is, however, faster and uses less power than DRAM. Because of this, it is still used frequently in digital systems for things like caches. Modern CPUs have something like 8-16MB of very fast SRAM cache, but the computer can have 1000x that much (8+GB) DRAM.

### SDRAM Controllers

Dealing with downsides to SDRAM is too much effort to have to think about whenever you need to read or write a some data. Wouldn't it be nice if it was all abstracted away and you could just say "what is the data in bank 0, column 4, row 12" with the result returned momentarily? Luckily for you, you're not alone. This is where the **SDRAM controller** comes in.

The controller's job is to deal with all the ugly parts of SDRAM and to break out a simple interface. This interface generally consists of an address input, a data input, a data output, and some control signals to specify a read/write, to tell when data is ready, and if the RAM is busy. That's it. No banks, no rows, no precharge, no opening, no hassle.

If this sounds wonderful and you just want to forget about all the inner workings of SDRAM, go ahead and download the [example project](http://cdn.embeddedmicro.com/sdram-shield/SDRAM-example-project.zip) for the SDRAM shield which has the SDRAM controller (**sdram.v**) in it.

This is all fine and dandy, but if you are the kind of person who wants to know how this is all accomplished, read on.

You should download the [example project](https://cdn.alchitry.com/emb/sdram-shield/SDRAM-example-project.zip) and take a look at **sdram.v** since the file is a bit long to paste here in it's entirety. Instead, we will break it apart looking at each piece individually.

First let's take a look at the interface.

```verilog
module sdram (
    input clk,
    input rst,
 
    // these signals go directly to the IO pins
    output sdram_clk,
    output sdram_cle,
    output sdram_cs,
    output sdram_cas,
    output sdram_ras,
    output sdram_we,
    output sdram_dqm,
    output [1:0] sdram_ba,
    output [12:0] sdram_a,
    inout [7:0] sdram_dq,
 
    // User interface
    input [22:0] addr,      // address to read/write
    input rw,               // 1 = write, 0 = read
    input [31:0] data_in,   // data from a read
    output [31:0] data_out, // data for a write
    output busy,            // controller is busy when high
    input in_valid,         // pulse high to initiate a read/write
    output out_valid        // pulses high when data from read is valid
  );
```

The first set of signals connect right to the SDRAM. It's important that they do as I'll explain a bit later.

The interesting part here is the **user interface** signals. These are the ones you'll need to worry about when using this controller in your own projects.

You may notice that the data ports are **32bits** wide, while, if you look at the SDRAM connections carefully, you may notice the SDRAM only has an **8bit** wide bus (**sdram_dq**). This is because each read or write the user does actually performs four read or writes to the SDRAM. This is done for efficiency (especially for reads).

The way you use this module is by first checking **busy** is 0 then setting **addr** to be the address you want, **data_in** to be your data, **rw** to be 1 (write), and **in_valid** to be 1 for one clock cycle to write some data. The following cycle, **busy** will be 1 letting you know the controller is doing something. Once the controller is ready to take another command, **busy** will be 0 again. At that point you can then set **addr** to be your address, **rw** to be 0 (read), and **in_valid** to be 1. After a few cycles, **out_valid** will be 1. During that clock cycle, you can read **data_out** for the data at the address you specified. That's the entire protocol.

It's worth noting that the number of cycles between when you ask for data and when you get the data will vary. This is also true for the number of cycles **busy** will be 1 between commands. It is also possible for **busy** to be 0 before you get your data from a read. This is because the controller buffers a single command and is only _busy_ when the buffer is full.

### Diving deep

Now would be a great time to download the [datasheet](http://cdn.embeddedmicro.com/sdram-shield/256Mb_sdr.pdf) for the SDRAM and take a look at it.

The following **localparams** are used to define the various commands the SDRAM will accept.

```verilog,linenos,linenostart=38
// Commands for the SDRAM
localparam CMD_UNSELECTED    = 4'b1000;
localparam CMD_NOP           = 4'b0111;
localparam CMD_ACTIVE        = 4'b0011;
localparam CMD_READ          = 4'b0101;
localparam CMD_WRITE         = 4'b0100;
localparam CMD_TERMINATE     = 4'b0110;
localparam CMD_PRECHARGE     = 4'b0010;
localparam CMD_REFRESH       = 4'b0001;
localparam CMD_LOAD_MODE_REG = 4'b0000;
```

If you take a look at the output assignments, you can see that these bits correspond to **CS**, **RAS**, **CAS**, and **WE**.

```verilog,linenos,linenostart=134
assign sdram_cs = cmd_q[3];
assign sdram_ras = cmd_q[2];
assign sdram_cas = cmd_q[1];
assign sdram_we = cmd_q[0];
```

For now, don't worry about these too much. Just know that they are used to specify commands for the SDRAM. You can look these commands up in the datasheet (page 31) if you want.

To manage the complexity of all the operations the controller does, it uses a **FSM**. If you aren't familiar with **F**inite **S**tate **M**achines, make sure to check out the [FSM Tutorial](@/tutorials/archive/verilog/mojo/finite-state-machines.md). The states for the FSM are defined below.

```verilog,linenos,linenostart=49
localparam STATE_SIZE = 4;
localparam INIT = 0,
  WAIT = 1,
  PRECHARGE_INIT = 2,
  REFRESH_INIT_1 = 3,
  REFRESH_INIT_2 = 4,
  LOAD_MODE_REG = 5,
  IDLE = 6,
  REFRESH = 7,
  ACTIVATE = 8,
  READ = 9,
  READ_RES = 10,
  WRITE = 11,
  PRECHARGE = 12;
```

The flow of these states is shown in the diagram below (excluding the WAIT stage for clarity).

![sdram_controller.png](https://cdn.alchitry.com/verilog/mojo/sdram_controller.png)

When the board is powered on (or reset) the FSM starts in the **INIT** state. SDRAM requires a bit of initialization before you can read and write to it. This is also covered in the datasheet (page 42) for those curious.

After the board is initialized, it sits in the **IDLE** state until one of two things happen, either it's time to perform a refresh or there is a pending operation.

First, let's talk about the refresh. To manage the refreshing, there is a timer that tells the controller to send another refresh operation. The SDRAM requires 8,192 refresh commands to be sent every 64ms. That means you can either send a refresh command every 7.813µs or all 8,192 commands in a batch every 64ms. To provide a more uniform interface, this controller sends the refresh commands evenly spaced. This limits the maximum amount of time the controller will be busy doing refreshes. In some applications where you need very fast burst speeds, but have some known down time, performing burst refreshing can be better.

When a read or write command is pending, the controller first checks to see if the row is open. If the requested row is already open, life is great, it simply reads or writes to the row. If the row isn't open then it first opens the row before performing the operation. The worst case is if there is already another row open. In this case the other row must be precharged, before the controller can open the new row and perform the operation.

Each of these operations has some number of cycles the SDRAM requires to complete (the reason for the **WAIT** state). These sometimes vary with the clock frequency (in other words, they have a set amount of real time). This controller assumes a clock rate of 100MHz. This is important for other reasons as well that will be discussed a little later. All of these delays and timing specifications can be found in the datasheet (many of them are on pages 27-28).

This mostly sums up how the controller works. If you want an even deeper understanding, you need to take a look at the rest of the code in the controller as well as the SDRAM datasheet.

However, there is some advanced voodoo magic going on in the controller code that is worth mentioning.

### Dealing with the hardware

There are a few sections of code in the controller that you probably haven't seen code like before unless you have done a lot of FPGA programming. This code is required simply because the SDRAM is an **external** chip and we are talking to it at a decently high clock speed.

First let's take a look at the code that is responsible for outputting the clock.

```verilog,linenos,linenostart=66
// This is used to drive the SDRAM clock
ODDR2 #(
  .DDR_ALIGNMENT("NONE"),
  .INIT(1'b0),
  .SRTYPE("SYNC")
) ODDR2_inst (
  .Q(sdram_clk_ddr), // 1-bit DDR output data
  .C0(clk), // 1-bit clock input
  .C1(~clk), // 1-bit clock input
  .CE(1'b1), // 1-bit clock enable input
  .D0(1'b0), // 1-bit data input (associated with C0)
  .D1(1'b1), // 1-bit data input (associated with C1)
  .R(1'b0), // 1-bit reset input
  .S(1'b0) // 1-bit set input
);
```

This is the instantiation of a **ODDR2** module. If you look the project files, you will notice there is no **ODDR2.v** file. This is because this isn't really a module, but rather an **FPGA primitive**. ODDR2 or **O**utput **D**ouble **D**ata **R**ate 2, is a primitive that is generally used to output data on both the rising and falling edges of the clock (hence, _double_ data rate). However, in this case we are using the ODDR2 to simply output our clock signal. You can't output the clock signal directly due to how the FPGA is structured internally. So instead, you can use the ODDR with the data pins wired to 0 or 1.

When **C0** has a rising edge, **D0** is output until **C1** has a rising edge. At that point **D1** is output. Notice that in our case **C1** is actually just the clock inverted. That means **D0** is output when the clock rises and **D1** is output when the clock falls.

You may be thinking now "Ok... but if **D0** is output when the clock _rises_, shouldn't **D0** be 1 and **D1** be 0"? Very good my young padawan. That is exactly right _if_ you wanted to output to be the same as the clock. However, we **don't** want this. We want the output clock to be our clock inverted!

Why the *&^$# would we want the clock to be inverted? Wouldn't that mean that the SDRAM would read it's inputs and change it's outputs on our falling edge? Oh wait... that's exactly what we want! We want this because that gives both devices half a clock cycle for their output to become stable before the other device. This all has to do with satisfying **setup** and **hold** times of both devices. If you don't know what the means, check out the [FPGA Timing Tutorial](@/tutorials/archive/verilog/mojo/fpga-timing.md).

There are two more pieces of code that are used to make sure timing is met.

Take a look at the following other FPGA primitive, the **IODELAY2**.

```verilog,linenos,linenostart=82
IODELAY2 #(
  .IDELAY_VALUE(0),
  .IDELAY_MODE("NORMAL"),
  .ODELAY_VALUE(100), // value of 100 seems to work at 100MHz
  .IDELAY_TYPE("FIXED"),
  .DELAY_SRC("ODATAIN"),
  .DATA_RATE("SDR")
) IODELAY_inst (
  .IDATAIN(1'b0),
  .T(1'b0),
  .ODATAIN(sdram_clk_ddr),
  .CAL(1'b0),
  .IOCLK0(1'b0),
  .IOCLK1(1'b0),
  .CLK(1'b0),
  .INC(1'b0),
  .CE(1'b0),
  .RST(1'b0),
  .BUSY(),
  .DATAOUT(),
  .DATAOUT2(),
  .TOUT(),
  .DOUT(sdram_clk)
);
```

As you may have guessed from the name, the **IODELAY2** block provides a delay to inputs and outputs. In this case we are using it to delay the clock being output to the SDRAM. There are a lot of features of these primitives that aren't being used here. However if you want t check them out in their full glory, take a look at the [UG381](http://www.xilinx.com/support/documentation/user_guides/ug381.pdf) document from Xilinx (ODDR2 starts on page 62 and IODELAY2 starts on page 74).

We need the delay because simply inverting the clock doesn't quite ensure timing is met. We need to shift it a little more.

The important values here are **DELAY_SRC** is set to make the **IODELAY2** delay an output and **ODELAY_VALUE** is how much we want to delay the signal.

The actual amount of delay that is given per step of **ODELAY_VALUE** is a bit fuzzy and will actually vary over temperature and voltage in the Spartan 6 chip. However, with a 100MHz clock, using a delay of 100 (maximum is 255) ensures that the setup and hold times are being met. This delay was found empirically by running lots of tests checking for read/write errors (this is actually what the example project does).

The last piece to the puzzle is making sure that the input and output registers are packed into **IOBs**, or **I**nput **O**utput **B**uffers.

```verilog,linenos,linenostart=115
// We want the output/input registers to be embedded in the
// IO buffers so we set IOB to "TRUE". This is to ensure all
// the signals are sent and received at the same time.
(* IOB = "TRUE" *)
reg cle_q, dqm_q;
(* IOB = "TRUE" *)
reg [3:0] cmd_q;
(* IOB = "TRUE" *)
reg [1:0] ba_q;
(* IOB = "TRUE" *)
reg [12:0] a_q;
(* IOB = "TRUE" *)
reg [7:0] dq_q;
(* IOB = "TRUE" *)
reg [7:0] dqi_q;
reg dq_en_d, dq_en_q;
```

This is done by setting the **IOB** constraint to **"TRUE"**. This tells the tools that we want these in **IOBs**.

What the heck is an IOB? An IOB is simply a flip-flop that is embedded in the pin of the FPGA. They aren't in the typical FPGA fabric, but rather right at the inputs and outputs.

We want to make sure these registers are packed into IOBs to ensure that there are no additional delays due to the signal needing to propagate through the FPGA.

To make sure these registers are actually packed into the IOB, their output/input can't connect to anything other than the top level output/input. If you tried to read these signals in some other part of your design, the tools would be forced to pull the flip-flop out of the IOB, possibly messing up timing. This is why it is important that these signals go directly to the top level inputs/outputs.

If you've made it this far through the tutorial, you should now have a pretty decent understanding of SDRAM and how complicated designing a controller can be. The controller that is in the example project is pretty good, but it is not the fastest controller possible. A more complex controller would allow for read commands to overlap, reads to be canceled, it would reorder operations to improve throughput (minimize open/precharge operations), and many more possible tricks. These are left for you to implement.