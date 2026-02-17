+++
title = "Setup"
sort_by = "weight"
paginate_by = 10
weight = 0
+++

Depending on your board, you will need to install different software to work with it. Find the section below and follow the guides for setting up your board.

## Every Board

No matter what board you have, you will need to install [Alchitry Labs](@/alchitry-labs.md). Alchitry Labs is an IDE required to write Lucid code. It has a ton of useful features that are covered on its page.

It is now bundled with the Alchitry Loader. If you don’t want to use the Alchitry Labs IDE, you still need the Alchitry Loader to get the .bin files onto your board.

## Au and Au+

Both the Au and Au+ require [Vivado](@/tutorials/setup/vivado.md) to build projects. This is software supplied by Xilinx. The install is fairly straightforward but does require you to make an account.

## Cu

Using the Cu has never been easier. Alchitry Labs 2 now ships with the  [open source tools](https://symbiflow.github.io/index.html) required to build projects for the Cu meaning you don't need to setup anything else.

The best part is that these even run on Macs (none of the proprietary tools do).

You can still choose to use Lattice's propriety toolchain, [iCEcube2](@/tutorials/setup/icecube2.md), which is more work but can often offer more optimized designs.
## Mojo

The Mojo is no longer actively supported and requires Alchitry Labs V1 and the abandoned [ISE](@/tutorials/setup/ise.md) tool from Xilinx. 

Installing this on Windows 10 or newer can be a bit finicky. We have a detailed guide to help but with ISE being no longer maintained it is recommended to upgrade to an Au which uses supported tools.