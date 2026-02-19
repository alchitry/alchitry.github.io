+++
title = "Getting Started"
date = "2026-02-19"
weight = 1
+++

So you want to get started working with FPGAs?
Great!
This page will go through everything you need to know to dive right in.

Not sure what an FPGA is?
Check out our [Why Use FPGAs](@/tutorials/introduction/why-use-fpgas.md) page.

# Requirements

To get started, the only thing you really need is a computer.

[Alchitry Labs](@/alchitry-labs.md) lets you run interactive simulations with a virtual [Io element](https://shop.alchitry.com/products/alchitry-io-v2).
This is enough to get through the first three [starter tutorials](/tutorials#starter-tutorials).
That should give you an idea what programmable hardware is all about without having to spend any money.

Ideally, your computer is running Windows or Linux, however, you can get started on a Mac as well.
While Alchitry Labs runs on all three systems, the tools from the FPGA manufactures only work on Windows and Linux.

On a Mac, you have the option of using the open source tools if you have a [Cu](https://shop.alchitry.com/products/alchitry-cu-v2) or running inside a virtual machine.
While the open source tools are cool, they generally aren't as robust as the proprietary ones.

Go ahead and download [Alchitry Labs](@/alchitry-labs.md) then start [Your First FPGA Project](https://alchitry.com/tutorials/starter/your-first-fpga-project/).

# Choosing a Board

Assuming you've seen enough to want to get some real hardware, the next question is which board should you get?

Our recommendation for most people is to get an [Au](https://shop.alchitry.com/products/alchitry-au).
The reason we recommend it over the [Cu](https://shop.alchitry.com/products/alchitry-cu-v2) is that the FPGA on the board is a modern chip from Xilinx.
The Artix 7 on the Au is supported by Xilinx's tool called Vivado.
This tool is free for the Au's FPGA for both commercial and personal use (you need to make an account).

The iCE40 FPGA on the Cu is an older FPGA made by Lattice and is supported by iCEcube2.
Unfortunately, Lattice decided to make iCEcube2 no-longer free.
It also hasn't been meaningfully updated in almost a decade, so I'm not sure what the new licensing cost is covering.

They still offer a free license to "hobbyists, enthusiasts, community educators & start-up companies."
To get one, you have to email them.
See the _Licensing_ section of [this page](https://www.latticesemi.com/iCEcube2#_12092ABF818047B59CC430396492212C) for more details.
For what it is worth, I haven't heard of them denying anyone and they are pretty quick to get back to you.

Vivado, the tool for the Au and Pt, also has Xilinx's IP catalog, which offers a lot of powerful blocks you can drop into your designs.
Things like digital filters, FFTs, and floating point math.

So what about the [Pt](https://shop.alchitry.com/products/alchitry-pt)?
The Pt is really just a supped-up Au.
The FPGA has about 3x the capacity of the Au, and it has almost twice the IO.

The only feature it has that isn't just _more_ of an Au's feature are the GTPs.
This is a set of specialized pins that allow for up to 6.25 Gbps of data for each pair.
It's an advanced feature.

Here's a table summarizing the different features for the three boards.

| Board | IO Pins | Relative FPGA Capacity | Free Tools | Open Source Tools | IO Voltages      | Differential Signals | On-board DDR | IP Catalogs      |
|-------|---------|------------------------|------------|-------------------|------------------|----------------------|--------------|------------------|
| Cu    | 79      | 1x                     | yes*       | yes               | 3.3V             | No                   | No           | Alchitry         |
| Au    | 104     | 3x                     | yes        | yes**             | 3.3V, 2.5V, 1.8V | LVDS, TMDS           | 256MB        | Alchitry, Xilinx |
| Pt    | 206     | 9x                     | yes        | yes**             | 3.3V, 2.5V, 1.8V | LVDS, TMDS           | 256MB        | Alchitry, Xilinx |

\* for hobbyists, enthusiasts, community educators, and start-up companies <br>
\*\* [they exist](https://github.com/openXC7) but aren't included in Alchitry Labs yet

## Extra Elements

In addition to your main FPGA board, you probably should pick up at least a [Br](https://shop.alchitry.com/products/alchitry-br-v2).
I generally recommend going with the _Wide_ version, which allows you to solder in [headers](https://shop.alchitry.com/products/wide-br-headers) for easy access to signals.

The [Io element](https://shop.alchitry.com/products/alchitry-io-v2) is also a great pickup for experimenting if you want to bring your simulations to life.

The other elements are highly situational.
If you need to dump a lot of data to or from your FPGA, the [Ft](https://shop.alchitry.com/products/alchitry-ft-v2) is what you need.
If you want HDMI in/out, then the [Hd](https://shop.alchitry.com/products/alchitry-hd) has you covered.

# Software Setup

No matter what board you have, you'll need [Alchitry Labs](@/alchitry-labs.md).
Even if you don't plan to use it as an IDE, you still need it for the _Alchitry Loader_ to get the bin file onto your board.

If you have an Au or Pt, you need to install [Vivado](@/tutorials/introduction/vivado.md).

If you have a Cu, you can use the built-in open-source tools by clicking the beaker logo and going to _Settings → Cu Toolchain → Yosys (Open Source)_ in Alchitry Labs.
Alternatively, you can install [iCEcube2](@/tutorials/introduction/icecube2.md).

# Tutorials

With everything set up, you can jump into the catalog of [tutorials](@/tutorials/_index.md).

If you run into issues, have questions, or just want to talk FPGAs, head over to the [forum](https://forum.alchitry.com/).
