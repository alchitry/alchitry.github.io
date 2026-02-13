+++
title = "Why Use FPGAs?"
weight = 1
inline_language = "lucid"
date = "2026-02-11"
aliases = ["tutorials/background/what-is-an-fpga", "tutorials/background/how-does-an-fpga-work"]
+++

So you've heard the term _FPGA_ and want to know what they are and why people use them?
Well, you've come to the right place!

First, FPGA stands for **F**ield **P**rogrammable **G**ate **A**rray.
Phew, with that mouthful out of the way, we can get into what that actually means.

FPGAs belong to a family of devices known as _programmable hardware_.
They let you design a digital circuit using text on a computer, similar to writing code.
However, FPGAs don't _run_ code. 
Instead, the text is something called a **H**ardware **D**escription **L**anguage (HDL).

These are languages designed specifically for describing digital circuits.

The tools on your computer take your HDL and turn it into a configuration file for the FPGA.
Almost like magic, once loaded onto the FPGA, the FPGA becomes the circuit you described.

Ok, ok let's get out of the weeds and take a step back.
While this sounds cool, why bother with it when we have powerful processors we can make do whatever we want with code?

# Processors vs FPGAs

Let me give a quick analogy for these two systems to give you some intuition on when you might use one or the other.

Imagine you sell sandwiches.
You have a small shop with a few sandwiches on the menu, and you even allow customers to create their own custom orders.

However, you find that the majority of your customers order one of three sandwiches.
As your business grows, you have a hard time keeping up with demand of these three sandwiches.
You decide that personally creating hundreds of the exact same three sandwiches every day isn't very efficient.

Instead, you decide to set up an assembly line.
You invest in some robots that can cut the bread, place the cheese, spray on condiments, etc.

While setting up this line was a lot more work than just making a sandwich, you can now pump out way more than you could
before very efficiently.

In this scenario, you, a sandwich master chef capable of creating any unique sandwich to order, are like a processor.
Processors are fantastic at handling a wide variety of complicated tasks and dealing with complicated control flow.
Someone wants their one sandwich cut into a star shape?
No problem, you can do that.

On the other hand, the assembly line is like an FPGA.

Each piece of the assembly line operates in tandem with every other piece.
Where you, the processor, do one task at a time, cut the bread, then place the cheese, etc., the assembly line does them all at once.
Sandwiches flow through the line continuously.
When one sandwich is having mayo dispensed on it, another is having the cheese placed, and yet another is just being started by slicing bread.

The individual pieces all work together in parallel.
This makes the throughput of the assembly line very high.

The _assembly line_ equivalent in digital design is known as a _pipeline_.
You've likely heard that term before, and in this context it describes a circuit where each section processes some data
in some way before passing to the next section.
All the sections run in parallel with many pieces of data flowing through the pipeline at any given time in various stages of completeness.

However, while pipelines are very powerful and common place, FPGAs can implement any digital circuit you want.
That includes things like processors.

## Processors _and_ FPGAs

While it's common to want to compare FPGAs to processors, it isn't really a strictly fair comparison.
That's because you can implement processors inside an FPGA.

Just for reference, processors inside an FPGA are often called _soft_ processors.

You can imagine a situation on our hypothetical sandwich line where one stage is very complicated to automate or requires immense flexibility.
In that case, it might be worth hiring someone to fill that role instead.

That's the power of being able to incorporate a processor directly into an FPGA.

Inside the FPGA, you can also scale up or down that processor's capabilities depending on the job it needs to perform.
If all it has to do is cut the sandwich into a funny shape, it doesn't need a PhD in astrophysics.

There are even some FPGAs that have _hard_ processors (i.e. ones that are fixed) in them to give you both high software
performance and custom hardware flexibility.
It's also common to see FPGAs paired with external processors.
They're often complimentary rather than exclusive.

## FPGAs vs ASIC

All the benefits I've said up to this point aren't specific to FPGAs. 
Instead, they're just benefits to creating a custom circuit.

The term ASIC, or **A**pplication **S**pecific **I**ntegrated **C**ircuit, is used to describe a custom circuit made into a custom chip.

This is the gold standard when it comes to performance (both speed and power consumption).
However, it isn't always in reach.

There are two major downsides to having your design turned into an ASIC.

First, once you get your chip back from the fab, that's it.
If you find you made a mistake, even a tiny one, it is baked into the design and requires new chips to be made to fix.

Second, getting them made a slow and expensive process.
Typically, you're looking somewhere North of a million USD.

This is where FPGAs come into play.
FPGAs allow you to _make_ your digital circuit without having to actually **make** it.

That flexibility comes at a cost.

First is the real dollars cost.
FPGAs aren't cheap.
While today, you can get a lot for the money, the FPGA itself is rarely less than $10 for the smallest ones and high-end FPGAs
easily go into five digits with some in the six digit range.
On top of that, FPGAs generally require quite a bit of extra stuff to make them work like multiple power supplies and external memory.

The second cost is in performance.
FPGAs are both slower and more power hungry than an ASIC.
There is inherent overhead in the circuitry that makes them so flexible.

So why use them?

While their per-unit cost is terrible compared to a huge batch of ASICs, there is no NRE (non-recurring engineering) costs associated with production.
This is a game changer when you have lower volumes or your design is likely to change.
They're also useful in prototyping designs that will later become ASICs.

FPGAs also can be reconfigured over and over again making any circuit using them _field programmable_ (hey, that's where the FP part of FPGA came from).
This is an incredible superpower.

# When to Use an FPGA

Given that FPGAs are more expensive and power-hungry than a typical microcontroller, you may be wondering when you should use one.
There are a handful of places where FPGAs really excel.

## IO

The first is in anything IO heavy.
By IO, I mean inputs and outputs of the chip.

FPGAs often have a ton of pins to connect to the external world.
On top of that, these pins often have capabilities not seen on microcontrollers.

For example, on our [Au FPGA development board](https://shop.alchitry.com/products/alchitry-au), most of the IO can be used
as differential input pairs capable of receiving 1.2 Gbps (1.2 BILLION bits per second).
This also happens _passively_.
That data simply comes into the FPGA and is fed into whatever circuit is designed to handle it.
The rest of the FPGA is free to do whatever it was designed for.

Contrast that to a microcontroller where something like a basic Arduino could spend 100% of its CPU time toggling a pin at
only around 100 thousand times per second (highly dependent on the code and the specific chip).
And that's leaving _zero_ time for the CPU to do anything else.

The IO on an FPGA offers unparalleled flexibility.
For example, with a typical microcontroller you'll have a bunch of different peripherals (extra dedicated circuits) attached to the
main processors.
Usually, these include things like timers, UART (serial ports), or other communication protocols.

Using one of the built-in peripherals for sending and receiving data is basically mandatory as _bit-banging_ it (using the 
CPU to generate all the signals) is slow and wastes a lot of CPU time.
However, you have a fixed number of each, and they typically route to specific pins on the chip.

In an FPGA, for the most part, IO pins are IO pins.
If you need two of them to be a serial port, connect them to a circuit that knows how to deal with that signal.
If you need 20 serial ports, duplicate that circuit 20 times.

If you have some weird custom protocol you need to interface with, no problem!
Whip up a circuit that can handle it and attach it wherever.

Check out our [FPGA IO video tutorial](https://www.youtube.com/watch?v=dnk6_uN5UyE) for more details!

## Predictable Latency

If we go back to our sandwich shop example, when making sandwiches, you might take 3 minutes per sandwich on average.
However, sometimes in the middle of making one, the phone rings.
You answer the phone and deal with that, but now the total time for that sandwich is 8 minutes.

This is inherent with multitasking.
A CPU may be doing its main task, but then an interrupt fires and that needs to be dealt with before resuming the main task.
Usually that's exactly what you want to happen, but in some systems that unpredictability is unacceptable.

The sandwich assembly line **always** pumps out sandwiches at the same rate.
Timing when each step happens is straightforward and performance is guaranteed by design.

## High Throughput

This point is probably already obvious to you at this point, but the ability to have many small dedicated portions of the 
FPGA all running in parallel lends itself to processing _a lot_ of data.

Think things like a [GPU pipeline](@/tutorials/projects/gpu.md) or heavy digital-signal processing (filters, Fourier transforms, etc.).

The parallel nature of an FPGA is seen in breaking down each task into parallelizable chunks and in that every task can be performed independently.
Adding some extra unrelated functionality to your design does not slow down other parts like it would in a CPU.

# How They Work

Being able to just load a configuration file onto the chip and have it transform into whatever digital circuit we want 
seems a bit magical.
However, at a high level, FPGAs aren't that complicated to understand.

You don't need to know how they work to use them, but you may still find this section interesting.
You will need some [background](@/tutorials/background/_index.md) in digital circuits like knowing what a [multiplexer](@/tutorials/background/multiplexers.md) is.

An FPGA has three main elements, **L**ook-**U**p **T**ables (**LUT**), flip-flops, and the routing matrix.

## Look-Up Tables

Look-up tables are how your logic actually gets implemented. 
A LUT consists of some number of inputs and one output. 
What makes a LUT powerful is that you can _program_ what the output should be for every single possible input.

A LUT consists of a block of RAM (memory) that is indexed by the LUT's inputs. 
The output of the LUT is whatever value is in the indexed location in its RAM.

As an example let's look at a 2-input LUT.

![lut2.png](https://cdn.alchitry.com/background/lut2.png)

Since the RAM in the LUT can be set to anything, a 2-input LUT can become any logic gate!

For example, if we want to implement an AND gate the contents of the RAM would look like this.

|Address (In[1:0])|Value (Out)|
|---|---|
|00|0|
|01|0|
|10|0|
|11|1|

It's important to understand that the column _Value (Out)_ could be set to anything! 
It doesn't have to model a single logic gate. 
If the value for address 01 was a 1, then the LUT would still perform as expected but the equivalent logic circuit would require more than one gate to implement. 
This is why the metric of equivalent gate count for an FPGA is a confusing and poor metric! 
It is tricky to specify how complicated of a circuit you can implement in a given FPGA because of all the variables.

## LUTs in the Mojo

In the Spartan 6 used by the Mojo, each LUT is a 6-input LUT. 
However, it isn't a true 6-input LUT but rather two 5-input LUTs connected by a multiplexer (MUX).

![lut6.png](https://cdn.alchitry.com/background/lut6.png)

The reason the LUT is designed this way is that it can either be used as a single 6-input LUT, or two 5-input LUTs. 
The only restriction is that both 5-input LUTs must share the same inputs. 
When it is configured as two 5-input LUTs, **In[5]** is set to 0.

## Flip-flops and Slices

Each LUT's output can be optionally connected to a [flip-flop](@/tutorials/lucid_v2/synchronous-logic.md). 
Groups of LUTs and flip-flops are called **slices**. 
In the Spartan 6 used by the Mojo, a slice has 4 LUT6 and eight flip-flops. 
These flip-flops are typically configurable allowing the type of reset (asynchronous vs. synchronous) and the reset level (high vs low) to be specified. 

The FPGA used by the Mojo has 1,430 slices in it for a total of 5,720 LUTs!

All slices are not created equal, however. 
In the Mojo's FPGA there are three types of slices, **SLICEX**, **SLICEL**, and **SLICEM**. 
The SLICEX is the most basic type of slice and just consists of the four LUT6's and the eight flip-flops. 
A SLICEL is the same as a SLICEX except it contains extra hardware for a ripple-carry chain used in arithmetic circuits. 
These help speed up circuits like addition and multiplication. 
A SLICEM is the same as a SLICEL except the LUTs can be used as 64 bits of RAM or a shift register up to 32bits long. 
The breakdown of the slices is roughly SLICEX 50%, SLICEL 25%, and SLICEM 25%.

## The Routing Matrix

The next size block in the FPGA is the **C**onfigurable **L**ogic **B**lock (**CLB**) and each CLB consists of two slices. 
Each CLB connects to a _switch matrix_ that is responsible for connecting the CLB to the rest of the FPGA. 
The switch matrix can connect the inputs and outputs of the CLB to the _general routing matrix_ or to each other. 
That way the output from one LUT can feed into the input of another LUT without having to travel far.

The routing resources in an FPGA are pretty complicated, but they are essentially a bunch of multiplexers and wires 
that are used to define what CLBs and other FPGA resources are connected to each other. 
These connections are again defined in RAM which is why the FPGA must be reconfigured every time the power is cycled 
(in the Mojo this is taken care of by the AVR).

There are also special routing resources available on the FPGA. 
The most notable are the clock routing resources. 
When you have a clock being used in your design, it is crucial that the clock signal be distributed as evenly as possible 
throughout the FPGA so all the flip-flops will flip at roughly the same time. 
If you were to try and use the general routing resources for this, the clock signal would have large propagation delays 
from traveling through all the multiplexers. 
To solve this problem, there are global and local routing resources dedicated to clocks. 
These are basically wires that connect through the entire chip (for global) or sections of the chip (for local) with 
very little propagation delay. 
Only inputs from certain pins on the FPGA are allowed to drive a signal on the global clock routing resources. 
These inputs are labeled GCLK in the Mojo schematic.

All of these resources are used in an FPGA to make them very flexible slow things down. 
This is why you will never be able to clock an FPGA at speeds comparable to a dedicated chip. 
An ASIC design can reach speeds faster than 4GHz, while an FPGA is very fast if it's running at 450MHz. 
This is also why FPGAs consume considerably more power than their ASIC counterparts. 
An FPGA will require an order of magnitude more power to run than an 8bit microcontroller, like an AVR. 
However, they still have the huge advantage of being low-cost for small runs (or hobbyists) and reconfigurable virtually unlimited times.