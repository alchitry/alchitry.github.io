+++
title = "Custom Elements"
weight = 2
date = "2025-02-25"
+++

This tutorial goes over all the information you need to create your own custom elements.

<!-- more -->

# Pinout

The Alchitry V2 boards have
three [DF40](https://www.hirose.com/en/product/document?clcode=&productname=&series=DF40&documenttype=Catalog&lang=en&documentid=en_DF40_CAT)
connectors on a side.

The 50-pin connector is the _Control_ header.
It has pins for power and miscellaneous control and status pins.

The two 80-pin connectors have up to 52 IO pins on each with the remaining pins being used as grounds.
The connector closest to the _Control_ header is _Bank A_ and the other is _Bank B_.

The 50-pin connector is `DF40HC(4.0)-50DS-0.4V(51)` when used on the top and the mating `DF40C-50DP-0.4V(51)` when on
the bottom.

The 80-pin connectors are `DF40HC(4.0)-80DS-0.4V(51)` when used on the top and the mating `DF40C-80DP-0.4V(51)` when on
the bottom.

<img src="https://cdn.alchitry.com/elements/AU_v2_Banks_Labeled.svg" alt="Alchitry V2 Banks" style="width: min(100%, 600px);" />

Pin 1 of each connector is at the bottom left for each in the image above.

The pinout of each board follows a general template, but they all vary a little from each other.
See below for the full pinouts.

## Cu

[Schematic](https://cdn.alchitry.com/docs/Cu-V2/CuSchematic.pdf)

{{ cu_pinout() }}

## Au

[Schematic](https://cdn.alchitry.com/docs/Au-V2/AuSchematic.pdf)

{{ au_pinout() }}

## Pt

[Schematic](https://cdn.alchitry.com/docs/Pt-V2/Alchitry%20Platinum%20Rev%20A.pdf)

{{ pt_pinout() }}

# PCB Layout

* [Connector Positions](https://cdn.alchitry.com/docs/Au-V2/AuDrawing.pdf)
* [Au Trace Lengths](https://docs.google.com/spreadsheets/d/1WxeS5YJ1MgcgeiRLXJ_PuZC4l7f2cVPHpaNJcFdKyg8/edit?gid=731807636#gid=731807636)
* [Pt Trace Lengths](https://docs.google.com/spreadsheets/d/1t2A2apBwaQrpOtj8-f1AKn4eQP6NPnVamPfEwm4tclc/edit?gid=731807636#gid=731807636)

## Alchitry V2 Element Libraries

These are libraries that already have the connectors in the right place and the pins labeled with the signal names.

* [KiCad](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements%20KiCAD.zip)
* [Altium Develop](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.IntLib)
* [Fusion](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.flbr)
* [Eagle 9.x](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.lbr)