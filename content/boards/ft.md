+++
title = "Alchitry Ft"
weight = 4
+++

Send all the data! This element features a FT600 USB 3.0 bridge that adds up to 200MB/s (that is bytes not bits!) of bandwidth from your FPGA to a computer.

![Ft](https://cdn.alchitry.com/boards/ft.jpg)
# Features At A Glance

## USB C

The Ft has extra circuitry to handle the reversible nature of the USB C port. It detects the orientation of the cable and routes the signals to the FT600 correctly.

## FT600

The FT600 from FTDI is capable of 200MB/s of throughput. This is shared for both directions meaning you can get 200MB/s in one direction or any split between transmitting and receiving. The actual maximum rate will be slightly under 200MB/s due to some overhead in reading buffer states. We were able to easily achieve 190+MB/s.

## Stackable

This board has surface mount connectors on both sides with the signals passed through allowing you to stack another element on top.

# Documents

- [FT600Q Datasheet](https://cdn.alchitry.com/docs/DS_FT600Q-FT601Q-IC-Datasheet.pdf)
- [Schematic](https://cdn.alchitry.com/docs/alchitry_ft_sch.pdf)