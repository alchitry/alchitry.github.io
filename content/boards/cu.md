+++
title = "Alchitry Cu"
weight = 1
+++

Dive into the world of programmable hardware with the Alchitry Cu. This board features a Lattice iCE40 HX FPGA with 79 IO pins broken out!

![Cu](https://cdn.alchitry.com/boards/cu.jpg)
# Features At A Glance

## IO Pins

The Cu features 79 IO pins at 3.3V. The signals for the on-board LEDs and reset button are also broken out giving you access to a maximum of 88 IO pins.

## Open Source Tools

The Lattice FPGA is supported by the official iceCube2 tools as well as unofficial open source toolchains.

## USB C

The USB C port on the board is used to configure the FPGA as well as transfer data to and from your design via a serial interface capable of up to 12M baud. This port can also supply the board its power and is protected by a diode if you decide to power the board externally.

## Power

The board is powered through the USB C port, 0.1” holes, or through its surface mount headers. The board requires 5V and generates 3.3V for IO and 1.2V for FPGA internal logic. The amount of current drawn is incredibly varied by your FPGA design but the power supply can pump out 3A on the 3.3V rail and 1.5A on the 1.2V rail so you don’t need to worry.

## Peripherals

Like all Alchitry boards, you get exactly what you need built into the board without all the extra fluff. The Cu has a 8 general use LEDs and a button typically used as a reset. It also has a 100MHz oscillator for clocking your designs. The FPGA is capable of synthesizing new frequencies from this if you need to clock your design faster or slower.

# Documents

- [Product Brief (includes dimensional drawing)](https://cdn.alchitry.com/docs/Alchitry%20Cu%20Product%20Brief.pdf)
- [Schematic](https://cdn.alchitry.com/docs/alchitry_cu_sch.pdf)
- [3D Model (IGES File)](https://cdn.alchitry.com/docs/Alchitry%20Cu.iges)
- [Element Eagle Library](https://cdn.alchitry.com/docs/alchitry_elements.lbr)