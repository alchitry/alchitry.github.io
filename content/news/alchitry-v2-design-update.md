+++
title = "Alchitry V2 - Production Begins"
date = "2024-12-09"
+++

It has been a busy couple of months and things are starting to come together!
<!-- more -->
![Alchitry Io V2 Prototype](https://cdn.alchitry.com/blog/IoV2Prototype.jpg)

If you head over to [our new shop](https://shop.alchitry.com/collections/all), you'll now see renders for all the new V2 boards!
All the new boards are now at least in the draft stage with a handful about to start production.

The prototypes of the [Au](https://shop.alchitry.com/products/alchitry-au), [Io](https://shop.alchitry.com/products/alchitry-io-v2), 
and [Br](https://shop.alchitry.com/products/alchitry-br-v2) have already been made.
As you can see from the above image, the Io has been tested and is working great!
I'm particularly excited about the new buttons being used that have a taller plugger and a more satisfying click.

The Io and Br are set to start production this week.

The Au had some [changes made to the Done LED](https://forum.alchitry.com/t/alchitry-v2-planning/1811/89?u=alchitry) that will be tested in the Cu prototype before production starts.
The Done LED on the V2 boards now serves double duty as a power and Done status LED.
If you aren't familiar, the Done signal from an FPGA is an open drain signal that is released when the FPGA is configured.

It can be used to synchronize the time multiple FPGAs come up, but it is most commonly just connected to an LED to know the FPGA was correctly configured.

On the old boards, if you erased the FPGA then the board would show no signs of life.
The new design uses a dual color LED that will be red when the board has power but the FPGA isn't configured.
It'll turn green when the FPGA is correctly configured.

This week the prototypes for the [Cu](https://shop.alchitry.com/products/alchitry-cu-v2), 
[Ft](https://shop.alchitry.com/products/alchitry-ft-v2), [Ft+](https://shop.alchitry.com/products/alchitry-ft-v2?variant=48644641161493),
and [Hd](https://shop.alchitry.com/products/alchitry-hd) will start production. 
It usually takes a little under two weeks for these to get made and in my hands.

By the end of the year, everything except the Pt should have started full production.
That means time is running out to get your pre-order in and secure your 20% off!

The layout work on the Pt will be starting fairly soon.
The Pt's density means this will take some time but should be available in Q2 of next year.