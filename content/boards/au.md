+++
title = "Alchitry Au"
weight = 0
+++

Dive into the world of programmable hardware with the very capable Alchitry Au. This board features a powerful Artix 7 FPGA with 102 IO pins broken out and 256MB of DDR3 memory onboard!

![Au](https://cdn.alchitry.com/boards/au.jpg)
# Features At A Glance
## IO Pins

The Au features an eye watering 102 IO pins at 3.3V. 20 of these pins can be switched to operate at 1.8V allowing for LVDS. The signals for the on-board LEDs and reset button are also broken out giving you access to a maximum of 111 IO pins.

## Analog Inputs

The FPGA on the Au has a built in analog to digital converter with 9 differential inputs broken out. Eight of these are shared with digital IO and one pair is a dedicated input.

## DDR3

The Au has a built in memory controller that is connected to 256MB of DDR3 RAM on board. The FPGA itself already has quite a bit of internal memory but this gives you plenty of extra to work with in your designs.

## Power

The board is powered through the USB C port, 0.1” holes, or through its surface mount headers. The board requires 5V and generates 3.3V for IO, 1.8V for IO and FPGA internals, 1.8V for analog circuitry, 1.35V for the DDR3, and 1V for the FPGA internal logic. The amount of current drawn is incredibly varied by your FPGA design but the power supply can pump out 3.5A on the 3.3V rail and 2.2A on the 1V rail so you don’t need to worry.

## Peripherals

Like all Alchitry boards, you get exactly what you need built into the board without all the extra fluff. The Au has a 8 general use LEDs and a button typically used as a reset. It also has a 100MHz oscillator for clocking your designs. The FPGA is capable of synthesizing new frequencies from this if you need to clock your design faster or slower.

## USB C

The USB C port on the board is used to configure the FPGA as well as transfer data to and from your design via a serial interface capable of up to 12M baud. This port can also supply the board its power and is protected by a diode if you decide to power the board externally.

# Documents

- [Product Brief (includes dimensional drawing)](https://cdn.alchitry.com/docs/Alchitry%20Au%20Product%20Brief.pdf)
- [Schematic](https://cdn.alchitry.com/docs/alchitry_au_sch.pdf)
- [3D Model (IGES File)](https://cdn.alchitry.com/docs/Alchitry%20Au.iges)
- [Element Eagle Library](https://cdn.alchitry.com/docs/alchitry_elements.lbr)