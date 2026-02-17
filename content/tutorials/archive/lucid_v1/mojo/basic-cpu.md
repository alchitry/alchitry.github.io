+++
title = "Basic CPU"
weight = 9
aliases = ["tutorials/lucid_v1/mojo/basic-cpu.md"]
+++

In this tutorial we will create a super basic CPU that you can then write some assembly for. You can then go brag to all your friends what a badass you are.

## What is a CPU?

If you are reading this, there is an excellent chance you already have a decent idea what a CPU is. However, since we are going to be making one, we need to have a clear idea of exactly we are going to be making.

In its most abstract form, a CPU is a circuit whose behavior is determined by the code it is fed. This way, the same circuit can perform a completely different task simply by changing some values in a ROM. In general, a CPU will also have some form of memory to perform work and they all need a way to input and output data (if you don't have any IO, you can't do anything useful).

A CPU is some circuit that has a stream of instructions fed to it and those instructions determine what it will do. But what sort of operations do we need?

### Instruction Set

A CPU's _instruction set_ is the set of instructions that the CPU understands. It is the language of that particular processor. Each CPU has its own instruction set, however, many CPUs share the same, or very similar, instruction sets. For example, x86 is the name of Intel's instruction set for their 32 bit processors. By keeping the instruction set the same between generations of processors, the exact same software can run on different processors without needing to be modified.

For our super basic CPU, we will be making up our own instruction set (because we are cool like that). Our set will be pretty minimal (16 instructions) and will consist only of the essentials.

There are two important sizes in a CPU. The first, and the one you hear about the most, is the data path size. This determines the largest values that can be operated on at any time. When you hear that a CPU is 8 bit, 32 bit, etc., these are the data path sizes. An 8 bit processor can only operate on 8 bits at a time while a 64 bit processor can operate on 8 times that. The other important size is the instruction size. Depending on the CPU these may or may not be the same size and depending on the instruction set, instructions may actually have varying lengths!

For our CPU, we are going to make it 8 bit with a 16 bit instruction size. This means all our instructions need to be encoded with 16 bits. By having a fixed instruction size, it is easy to know where the next instruction starts without having to inspect every instruction before it.

### Memory

Before we dive into what our CPU will actually do, we need to figure out how data will get in and out and when it is in, how do we work with it? CPUs typically have a tiny bit of super duper fast memory built into them. This memory is known as the CPU's registers and serves as the working memory of the CPU. Our CPU will only be able to perform operations directly on its registers. So if all the work happens on these registers, how do we process outside data? We need a way to load data into a register and output the value of a register. The interface we will use will be basically the same as the RAM interface in the [Hello YOUR_NAME_HERE](@/tutorials/archive/lucid_v1/mojo/hello-your-name-here.md) tutorial. We will specify an address and data (for a write) or an address and we will receive data (for a read). This will be covered a bit more later. For now, just know that we have internal memory called registers and we will have a way to load and store values to/from the outside world.

### Operations

We now need a way to encode the instructions for our CPU. We are going to fit each instruction into 16 bits. The first four bits will be to encode what the operation is (since we will have 16 operations), and the remaining 12 bits will be unique to each operation. The four bits that encode the type of operation are known as the **opcode**.

Because some of our instructions will require 3 arguments, that leaves 4 bits for each argument. If each argument is the address of a register, we can haven at most 16 registers without increasing our instruction size.

#### NOP

What is the most basic operation you can think of? If you thought of nothing, you win! The _do nothing_ instruction, or _no operation_ (often abbreviated to **NOP**), is going to be our first instruction.

|   |   |
|---|---|
|NOP|0|

This instruction does nothing so we can just fill the 12 bits with 0.

#### LOAD and STORE

As you should recall from only a few lines up, all CPUs need some form of IO. If you can't input data and output results, the CPU would be useless. It would be like a fully paralyzed person with no senses. They may have super interesting thoughts, but no one would ever know. We can then create two more instructions, **LOAD** and **STORE** for loading a value (input) and storing a value (output) respectively.

|   |   |   |   |
|---|---|---|---|
|LOAD|DEST|ADDR|OFFSET|
|STORE|SRC|ADDR|OFFSET|

Since the loads and stores need to provide both a value and an address, we need two arguments. The **DEST** argument is the register that will get the value from a **LOAD**. The **SRC** argument is the register whose value will be output. The **ADDR** argument is the register whose value should be used as the address. Finally, **OFFSET** is a constant that will be added to the value of the **ADDR** register to get the address. This offset can be convenient to have, but you don't really need it. I added it because there were 4 extra bits we could do something with.

#### SET

We will commonly need to set the value of a register to some constant. The **SET** operation will let us do that.

|   |   |   |
|---|---|---|
|SET|DEST|CONST|

Here **DEST** is the register that will be set and **CONST** is the 8 bit value to set it to. Keep in mind that since we are making an 8 bit processor, the registers are 8 bits wide.

#### LT and EQ

We will likely want to be able to compare two different values. To do any comparison, we only need two operators, less-than (**LT**) and equal (**EQ**). If we then wanted to perform a greater-than we could simply use less-than and flip the arguments. Less-than or equal to can be achieved by using both.

|   |   |   |   |
|---|---|---|---|
|LT|DEST|OP1|OP2|
|EQ|DEST|OP1|OP2|

In the **LT** case the **DEST** register will be 1 if **OP1** is less than **OP2** and 0 otherwise. **EQ** is the same, except it checks for equality.

#### BEQ and BNEQ

Typically, a program will execute instruction after instruction. However, it can be really powerful to be able to control the flow. This is where branching instructions are useful.

|   |   |   |
|---|---|---|
|BEQ|OP1|CONST|
|BNEQ|OP1|CONST|

If register **OP1** is equal to the value **CONST** then the **BEQ** instruction will skip the instruction following it. Otherwise, the program will continue as normal. **BNEQ** does the same thing but skips is they are not equal.

These instructions allow you to create _if statements_ in your code.

#### The ALU

CPUs commonly need to manipulate the values in the registers. Operations like addition, AND, OR, bit shifting, etc. are all typically contained in something called the **ALU** or **A**rithmetic **L**ogic **U**nit. These types of instructions will make up the remainder of our instruction set.

|   |   |   |   |
|---|---|---|---|
|ADD|DEST|OP1|OP2|
|SUB|DEST|OP1|OP2|
|SHL|DEST|OP1|OP2|
|SHR|DEST|OP1|OP2|
|AND|DEST|OP1|OP2|
|OR|DEST|OP1|OP2|
|INV|DEST|OP1|0|
|XOR|DEST|OP1|OP2|

**ADD** and **SUB** add or subtract **OP1** and **OP2** and store the result into **DEST**.

**SHL** and **SHR** shift **OP1** to the right or left by **OP2** bits and store the result into **DEST**.

**AND**, **OR**, and **XOR** perform their respective bit-wise operations on **OP1** and **OP2** and store their result into **DEST**.

**INV** does a bit-wise inversion of **OP1** and stores the result into **DEST**.

### The Program Counter

We are going to put all the instructions for whatever program we write into a ROM. The ROM will need an address in order to know what instruction we need. This address will be specified by the _program counter_. For our CPU, we will use register 0 as our program counter. This will allow us to directly manipulate the flow of program by messing with its value.

### The CPU

Now that we have all the pieces, let's take a look at the actual module. You should create a new project based on the _Base Project_ and create a new module named _cpu_.

```lucid,short,linenos
global Inst {
  const NOP   = 4d0;  // 0 filled
  const LOAD  = 4d1;  // dest, op1, offset  : R[dest] = M[R[op1] + offset]
  const STORE = 4d2;  // src, op1, offset   : M[R[op1] + offset] = R[src]
  const SET   = 4d3;  // dest, const        : R[dest] = const
  const LT    = 4d4;  // dest, op1, op2     : R[dest] = R[op1] < R[op2]
  const EQ    = 4d5;  // dest, op1, op2     : R[dest] = R[op1] == R[op2]
  const BEQ   = 4d6;  // op1, const         : R[0] = R[0] + (R[op1] == const ? 2 : 1)
  const BNEQ  = 4d7;  // op1, const         : R[0] = R[0] + (R[op1] != const ? 2 : 1)
  const ADD   = 4d8;  // dest, op1, op2     : R[dest] = R[op1] + R[op2]
  const SUB   = 4d9;  // dest, op1, op2     : R[dest] = R[op1] - R[op2]
  const SHL   = 4d10; // dest, op1, op2     : R[dest] = R[op1] << R[op2]
  const SHR   = 4d11; // dest, op1, op2     : R[dest] = R[op1] >> R[op2]
  const AND   = 4d12; // dest, op1, op2     : R[dest] = R[op1] & R[op2]
  const OR    = 4d13; // dest, op1, op2     : R[dest] = R[op1] | R[op2]
  const INV   = 4d14; // dest, op1          : R[dest] = ~R[op1]
  const XOR   = 4d15; // dest, op1, op2     : R[dest] = R[op1] ^ R[op2]
}
 
module cpu (
    input clk,         // clock
    input rst,         // reset
    output write,      // CPU write request
    output read,       // CPU read request
    output address[8], // read/write address
    output dout[8],    // write data
    input din[8]       // read data
  ) {
 
  .clk(clk), .rst(rst) {
    dff reg[16][8]; // CPU Registers
  }
 
  instRom instRom;  // program ROM
 
  sig op[4];        // opcode
  sig arg1[4];      // first arg
  sig arg2[4];      // second arg
  sig dest[4];      // destination arg
  sig constant[8];  // constant arg
 
  always {
    // defaults
    write = 0;      // don't write
    read = 0;       // don't read
    address = 8hxx; // don't care
    dout = 8hxx;    // don't care
 
    instRom.address = reg.q[0];   // reg 0 is program counter
    reg.d[0] = reg.q[0] + 1;      // increment PC by default
 
    op = instRom.inst[15:12];     // opcode is top 4 bits
    dest = instRom.inst[11:8];    // dest is next 4 bits
    arg1 = instRom.inst[7:4];     // arg1 is next 4 bits
    arg2 = instRom.inst[3:0];     // arg2 is last 4 bits
    constant = instRom.inst[7:0]; // constant is last 8 bits
 
    // Perform the operation
    case (op) {
      Inst.LOAD:
        read = 1;                                  // request a read
        reg.d[dest] = din;                         // save the data
        address = reg.q[arg1] + arg2;              // set the address
      Inst.STORE:
        write = 1;                                 // request a write
        dout = reg.q[dest];                        // output the data
        address = reg.q[arg1] + arg2;              // set the address
      Inst.SET:
        reg.d[dest] = constant;                    // set the reg to constant
      Inst.LT:
        reg.d[dest] = reg.q[arg1] < reg.q[arg2];   // less-than comparison
      Inst.EQ:
        reg.d[dest] = reg.q[arg1] == reg.q[arg2];  // equals comparison
      Inst.BEQ:
        if (reg.q[dest] == constant)               // if R[dest] == constant
          reg.d[0] = reg.q[0] + 2;                 // skip next instruction
      Inst.BNEQ:
        if (reg.q[dest] != constant)               // if R[dest] != constant
          reg.d[0] = reg.q[0] + 2;                 // skip next instruction
      Inst.ADD:
        reg.d[dest] = reg.q[arg1] + reg.q[arg2];   // addition
      Inst.SUB:
        reg.d[dest] = reg.q[arg1] - reg.q[arg2];   // subtraction
      Inst.SHL:
        reg.d[dest] = reg.q[arg1] << reg.q[arg2];  // shift left
      Inst.SHR:
        reg.d[dest] = reg.q[arg1] >> reg.q[arg2];  // shift right
      Inst.AND:
        reg.d[dest] = reg.q[arg1] & reg.q[arg2];   // bit-wise AND
      Inst.OR:
        reg.d[dest] = reg.q[arg1] | reg.q[arg2];   // bit-wise OR
      Inst.INV:
        reg.d[dest] = ~reg.q[arg1];                // bit-wise invert
      Inst.XOR:
        reg.d[dest] = reg.q[arg1] ^ reg.q[arg2];   // bit-wise XOR
    }
  }
}
```

The astute observer will notice that the entire CPU file is less than 100 lines long! It's pretty amazing how much functionality you can get with such a simple design.

Take a look at the _global block_ at the beginning of the file.

```lucid,linenos
global Inst {
  const NOP   = 4d0;  // 0 filled
  const LOAD  = 4d1;  // dest, op1, offset  : R[dest] = M[R[op1] + offset]
  const STORE = 4d2;  // src, op1, offset   : M[R[op1] + offset] = R[src]
  const SET   = 4d3;  // dest, const        : R[dest] = const
  const LT    = 4d4;  // dest, op1, op2     : R[dest] = R[op1] < R[op2]
  const EQ    = 4d5;  // dest, op1, op2     : R[dest] = R[op1] == R[op2]
  const BEQ   = 4d6;  // op1, const         : R[0] = R[0] + (R[op1] == const ? 2 : 1)
  const BNEQ  = 4d7;  // op1, const         : R[0] = R[0] + (R[op1] != const ? 2 : 1)
  const ADD   = 4d8;  // dest, op1, op2     : R[dest] = R[op1] + R[op2]
  const SUB   = 4d9;  // dest, op1, op2     : R[dest] = R[op1] - R[op2]
  const SHL   = 4d10; // dest, op1, op2     : R[dest] = R[op1] << R[op2]
  const SHR   = 4d11; // dest, op1, op2     : R[dest] = R[op1] >> R[op2]
  const AND   = 4d12; // dest, op1, op2     : R[dest] = R[op1] & R[op2]
  const OR    = 4d13; // dest, op1, op2     : R[dest] = R[op1] | R[op2]
  const INV   = 4d14; // dest, op1          : R[dest] = ~R[op1]
  const XOR   = 4d15; // dest, op1, op2     : R[dest] = R[op1] ^ R[op2]
}
```

This block allows us to define constants that can be used in any Lucid file in out project. This is helpful since we will be using these in our instruction ROM. The name you give a _global block_ is the _namespace_ that its contents live in. To access a globally defined constant, you use the syntax _Namespace.CONST_. The name of a _namespace_ needs to start with a capital and contain at least one lowercase letter.

```lucid,linenos,linenostart=30
.clk(clk), .rst(rst) {
  dff reg[16][8]; // CPU Registers
}
```

Our CPU's registers are nothing other than a set of _dffs_. We use a 2D array of 16 by 8 since we want 16 registers of width 8.

```lucid,linenos,linenostart=34
instRom instRom;  // program ROM
```

We can't forget out program ROM! We will cover the actual ROM in a bit. However, it has only two ports, _address_ and _inst_. It simply outputs the corresponding instruction on _inst_ for the given _address_.

```lucid,linenos,linenostart=36
sig op[4];        // opcode
sig arg1[4];      // first arg
sig arg2[4];      // second arg
sig dest[4];      // destination arg
sig constant[8];  // constant arg
```

These signals aren't strictly needed, but they help make the code a bit more readable by allowing us to rename parts of the instruction.

```lucid,linenos,linenostart=52
op = instRom.inst[15:12];     // opcode is top 4 bits
dest = instRom.inst[11:8];    // dest is next 4 bits
arg1 = instRom.inst[7:4];     // arg1 is next 4 bits
arg2 = instRom.inst[3:0];     // arg2 is last 4 bits
constant = instRom.inst[7:0]; // constant is last 8 bits
```

Here is the actual assignment. The way we defined our instruction set, the _opcode_ is always the 4 most-significant bits. The other four signals are just the common names for the different parts of the instruction.

```lucid,linenos,linenostart=43
// defaults
write = 0;      // don't write
read = 0;       // don't read
address = 8hxx; // don't care
dout = 8hxx;    // don't care
```

In the beginning of an _always_ block, it is a good idea to assign defaults at the top so you don't have to worry about assigning a value in every possible conditional branch. In this case, by default we don't want to perform a read or write and if we aren't performing a read or write we don't care what the values of _address_ or _dout_ are.

```lucid,linenos,linenostart=49
instRom.address = reg.q[0];   // reg 0 is program counter
reg.d[0] = reg.q[0] + 1;      // increment PC by default
```

We decided to use the first register as our program counter. This means we are going to feed its value into the instruction ROM. We also need to increment it each cycle so that our program continues to execute. Since the line to perform the increment comes before the code to execute the instruction, if the instruction writes to the first register it will have precedence over the increment. This will allow us to manipulate the program counter with our code.

```lucid,linenos,linenostart=58
// Perform the operation
case (op) {
  Inst.LOAD:
    read = 1;                                  // request a read
    reg.d[dest] = din;                         // save the data
    address = reg.q[arg1] + arg2;              // set the address
  Inst.STORE:
    write = 1;                                 // request a write
    dout = reg.q[dest];                        // output the data
    address = reg.q[arg1] + arg2;              // set the address
  Inst.SET:
    reg.d[dest] = constant;                    // set the reg to constant
  Inst.LT:
    reg.d[dest] = reg.q[arg1] < reg.q[arg2];   // less-than comparison
  Inst.EQ:
    reg.d[dest] = reg.q[arg1] == reg.q[arg2];  // equals comparison
  Inst.BEQ:
    if (reg.q[dest] == constant)               // if R[dest] == constant
      reg.d[0] = reg.q[0] + 2;                 // skip next instruction
  Inst.BNEQ:
    if (reg.q[dest] != constant)               // if R[dest] != constant
      reg.d[0] = reg.q[0] + 2;                 // skip next instruction
  Inst.ADD:
    reg.d[dest] = reg.q[arg1] + reg.q[arg2];   // addition
  Inst.SUB:
    reg.d[dest] = reg.q[arg1] - reg.q[arg2];   // subtraction
  Inst.SHL:
    reg.d[dest] = reg.q[arg1] << reg.q[arg2];  // shift left
  Inst.SHR:
    reg.d[dest] = reg.q[arg1] >> reg.q[arg2];  // shift right
  Inst.AND:
    reg.d[dest] = reg.q[arg1] & reg.q[arg2];   // bit-wise AND
  Inst.OR:
    reg.d[dest] = reg.q[arg1] | reg.q[arg2];   // bit-wise OR
  Inst.INV:
    reg.d[dest] = ~reg.q[arg1];                // bit-wise invert
  Inst.XOR:
    reg.d[dest] = reg.q[arg1] ^ reg.q[arg2];   // bit-wise XOR
}
```

Here we execute the instruction. You may be surprised how simple this is. We simply use a _case statement_ to select what behavior we want.

## The Program

Now that we have a CPU, we need to write a program for it. Before getting deep into it, let's get something running to make sure everything is working.

Create a new module _instRom_ and paste in the following.

```lucid
module instRom (
    input address[8],
    output inst[16]
  ) {
 
  always {
    inst = c{Inst.NOP, 12b0};
 
    case (address) {
      // begin:
      0: inst = c{Inst.SET, 4d2, 8d0};              // SET R2, 0
      // loop:
      1: inst = c{Inst.SET, 4d1, 8d128};            // SET R1, 128
      2: inst = c{Inst.STORE, 4d2, 4d1, 4d0};       // STORE R2, R1, 0
      3: inst = c{Inst.SET, 4d1, 8d1};              // SET R1, 1
      4: inst = c{Inst.ADD, 4d2, 4d2, 4d1};         // ADD R2, R2, R1
      5: inst = c{Inst.SET, 4d15, 8d1};             // SET R15, loop
      6: inst = c{Inst.SET, 4d0, 8d7};              // SET R0, delay
      // delay:
      7: inst = c{Inst.SET, 4d11, 8d0};             // SET R11, 0
      8: inst = c{Inst.SET, 4d12, 8d0};             // SET R12, 0
      9: inst = c{Inst.SET, 4d13, 8d0};             // SET R13, 0
      10: inst = c{Inst.SET, 4d1, 8d1};             // SET R1, 1
      // delay_loop:
      11: inst = c{Inst.ADD, 4d11, 4d11, 4d1};      // ADD R11, R11, R1
      12: inst = c{Inst.BEQ, 4d11, 8d0};            // BEQ R11, 0
      13: inst = c{Inst.SET, 4d0, 8d11};            // SET R0, delay_loop
      14: inst = c{Inst.ADD, 4d12, 4d12, 4d1};      // ADD R12, R12, R1
      15: inst = c{Inst.BEQ, 4d12, 8d0};            // BEQ R12, 0
      16: inst = c{Inst.SET, 4d0, 8d11};            // SET R0, delay_loop
      17: inst = c{Inst.ADD, 4d13, 4d13, 4d1};      // ADD R13, R13, R1
      18: inst = c{Inst.BEQ, 4d13, 8d0};            // BEQ R13, 0
      19: inst = c{Inst.SET, 4d0, 8d11};            // SET R0, delay_loop
      20: inst = c{Inst.SET, 4d1, 8d0};             // SET R1, 0
      21: inst = c{Inst.ADD, 4d0, 4d15, 4d1};       // ADD R0, R15, R1
    }
  }
}
```

This code will slowly increment a counter and output it to address 128. We will go over the details of it a bit later, but first let us hook it up to the LEDs.

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
      cpu cpu;        // our snazzy CPU
      dff led_reg[8]; // storage for LED value
    }
  }
 
  always {
    reset_cond.in = ~rst_n;   // input raw inverted reset signal
    rst = reset_cond.out;     // conditioned reset
 
    spi_miso = bz;            // not using SPI
    spi_channel = bzzzz;      // not using flags
    avr_rx = bz;              // not using serial port
 
    cpu.din = 8hxx;           // default to don't care
 
    // if cpu uses address 128
    if (cpu.address == 128) {
      if (cpu.write)
        led_reg.d = cpu.dout; // update the LED value
      if (cpu.read)
        cpu.din = led_reg.q;  // let the CPU read the LED value
    }
 
    led = led_reg.q;          // connect LEDs to led_reg
  }
}
```

In _mojo_top_ we need to add the CPU and a _dff_ to hold the value for the LEDs. When the CPU writes to address 128, we can save the value in the _dff_ and connect that to the LEDs. This way, the CPU can directly control the LEDs by writing to this address!

Why use address 128? In practice could have chosen any address, but the reason we used 128 instead of say 0, is because the first half of the address space is typically reserved for RAM. Our CPU doesn't currently have access to RAM, but we _could_ hook it up to some. Using a memory interface like this to perform IO is known as **memory mapped IO**. This is how basically all CPUs perform IO. If you've ever worked with AVRs and written something like _PORTA = 0x5A;_, _PORTA_ is actually just a special memory address that instead of writing to RAM writes to the IO port (exactly what we are doing here).

Go ahead and build/load the project to your Mojo. The LEDs should now count slowly.

## The Assembler

While we could write the _instRom_ module ourselves to create programs, but it becomes a huge pain to edit them. If you want to insert an instruction you have to renumber everything. It is a nightmare. Luckily we don't have to! I wrote a basic assembler for us (you're welcome <3). You can find the assembler code on [GitHub](https://github.com/embmicro/SkinnyAssembler). If you just want to download the runnable JAR you can [click here](https://github.com/embmicro/SkinnyAssembler/raw/master/skinny-asm.jar). It should run on any OS with Java 1.7.

I used [ANTLR](http://www.antlr.org/) to parse the assembly. This is an awesome library that makes writing something like this pretty easy.

To use the assembler, use the following command.

```bash
java -jar skinny-asm.jar assembly-file.asm
```

It should then turn your assembly in _assembly-file.asm_ into the _instRom_ module, or tell you what's wrong with your file.

Here is the assembly file I used to generate the ROM from earlier.

```lucid
begin:  
  SET R2, 0           // R2 = 0
loop:
  SET R1, 128         // R1 = 128
  STORE R2, R1, 0     // M[128] = R2
  SET R1, 1           // R1 = 1
  ADD R2, R2, R1      // R2++
  SET R15, loop       // R15 = loop, R15 is return address
  SET R0, delay       // goto delay
delay:
  SET R11, 0          // R11 = 0
  SET R12, 0          // R12 = 0
  SET R13, 0          // R13 = 0
  SET R1, 1           // R1 = 1
delay_loop:
  ADD R11, R11, R1    // R11++
  BEQ R11, 0          // skip next if (R11 == 0)
  SET R0, delay_loop  // goto delay_loop
  ADD R12, R12, R1    // R12++
  BEQ R12, 0          // skip next if (R12 == 0)
  SET R0, delay_loop  // goto delay_loop
  ADD R13, R13, R1    // R13++
  BEQ R13, 0          // skip next if (R13 == 0)
  SET R0, delay_loop  // goto delay_loop
  SET R1, 0           // R1 = 0
  ADD R0, R15, R1     // R0 = R15 (return)
```

There are two types of lines that the assembler will accept, labels and instructions. A label is simply a name followed by a ':'. These act as constants that will be replaced with the line number of the instruction following it. For example, the label _begin_ in the above code will have the value 0 since it is before the first instruction. These make it easy to reference instructions without having to relay on fixed numbers (to avoid the insert problem).

Instructions consist of the name of the _opcode_ followed by a list of comma separated arguments. Constants can either be a decimal number or a label. Registers take the form _R#_ where _#_ is the register number.

## Writing Code

While our CPU only treats R0 specially (it's the program counter), it is helpful to assign special roles to some registers for use in our programs. For example, for many instructions it can be handy to have a temporary register to load a constant into. I used R1 for this purpose. The other special register I used was R15 to store the return address from a function call (more on this later).

The goal of this program was to count and output the count to address 128. Since we have no external RAM, all our memory needs to fit in the 16 registers. I chose R2 to store our primary counter.

The first line initializes R2 to 0, we then enter the main loop. The main loop starts by writing R2 to address 128. R1 is used to store the address 128 used by the _STORE_ instruction. We then increment R2 by one. Again, we use R1 to store the constant 1 to add to R2.

We could simply loop here, however, it would count way too fast for us to see on the LEDs. So we need to create a delay function. A function is just a block of code that can be called from anywhere and will return to where it's called from. We use R15 to specify the address we want to return to. In our case, we cheat a little bit and set R15 to the beginning of our loop instead of the instruction after the call to _delay_. This is just a little more efficient.

We can use the _SET_ instruction with R0 to jump to anywhere in our program. There is where labels are really helpful since we don't care what the actual instruction number is as the label will get replaced with the proper value.

The delay function uses R11, R12, and R13 to count from 0 to 16,777,215. This takes a decent amount of time so we can actually see the LEDs change.

Once the counter overflows, the delay function returns to the address in R15 using the _ADD_ instruction to set R0 to R15.

Try editing this code, or write you own program! Feel free to even swap out some of the instructions for your own if you can think of something more useful. Maybe you'd rather an instruction for directly setting a bit instead of XOR, or maybe you would rather be able to tell if a value is even than shifting right.

That's it for this tutorial. I hope you enjoyed making a basic CPU! It's pretty freaking awesome to write code for hardware that you designed! Go make something awesome!