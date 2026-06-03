+++
title = "Upcomming Alchitry Labs Updates"
date = "2026-06-03"
inline_language = "acf"
+++

A lot is still planned for Alchitry Labs!
Let's dive into a few of the major ones.

<!-- more -->

# Alchitry Interface

When working on building out a stand-alone board tester using a Raspberry Pi, it became clear that breaking out the
code that interfaces with the Alchitry boards would be really useful.
This would've been the third or fourth time I copy/pasted the USB code from Alchitry Labs into another project, and that
was just one too many.

That code is now part of the [Alchitry Interface](https://github.com/alchitry/Alchitry-Interface) repository.
You can add this to your own Kotlin/JVM projects using JitPack.

This repository has everything you need to program and talk to Alchitry boards cross-platform.

It even includes support for the Ft and Ft+ via D3xx.

Check out the [Alchitry Tester](https://github.com/alchitry/Alchitry-Tester) repository for an example on how to use it.
This is the code that we use now to test boards during production.

## No More yad2xx

Alchitry Labs used to use the [yad2xx](https://github.com/aushacker/yad2xx) library for D2xx support.
However, now _Alchitry Interface_ now uses the D2xx library directly via Java's FFM (from [Project Panama](https://openjdk.org/projects/panama/)).

The main benefit of this is a wider range of supported platforms, including ARM on Linux and Windows.
Alchitry Labs isn't built for these yet (the OSS tools build needs to also be updated), but it lays the groundwork for that soon.

# Python Testbenches?

When looking at some of the open bug reports for Alchitry Labs, I was going to fix the 
[one about simulation support for inouts](https://github.com/alchitry/Alchitry-Labs-V2/issues/106).
This got me thinking more about testbenches in general.

Right now, testbenches are kind of bolted onto Lucid.
Lucid was designed from the ground up for writing synthesizable code for FPGAs.
It is overly restrictive when trying to write a program, which is really what a testbench is.

This leads me to think that it would likely be better to remove support for testbenches in Lucid and make testbenches use Python.

Using [GraalPy](https://graalpy.org/), I can create bindings for Python into the Lucid interpreter that would let Python code
control the flow of a simulation.

I'm not exactly sure how all this would look yet, so let me know if you have any strong opinions about it at [support@alchitry.com](mailto:support@alchitry.com).

# On Chip Debugging

Writing testbenches can only get you so far.
For a lot of testing, it is often easier and more useful to just take a peak at what's happening on real hardware.

Alchitry Labs V1 had a crude version of this, but I'm now starting work on a much more robust version.

I'm currently thinking it would be great to both support using the basic link over the on-board USB (SPI or JTAG) and 
a high-performance link using an Ft or Ft+.
The added bandwidth from an Ft(+) would allow data to be streamed instead of just collected in bursts.

Again, this is all in fairly early stages, so if you have strong opinions about any of it, let me know [support@alchitry.com](mailto:support@alchitry.com).

# Beta and Stable Releases

Right now there is only one release channel for Alchitry Labs V2.
I'm working on splitting that into a stable channel and a beta channel.

The current channel will become the stable channel and a beta release will be added.

This will let people opt into whatever update cycle suits them best.