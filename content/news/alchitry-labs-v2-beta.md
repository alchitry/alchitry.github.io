+++
title = "Alchitry Labs V2 - Now in Beta!"
date = "2024-09-16"
inline_language = "lucid"
+++

Alchitry Labs V2.0.14 is now released and with it the status of the project changes from preview to beta!

![Alchitry Labs V2.0.14 Beta](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.14-beta.png)

You can [download it here](https://alchitry.com/Alchitry-Labs-V2/download.html) and help out by reporting any issues you encounter to the [GitHub issues page](https://github.com/alchitry/Alchitry-Labs-V2/issues).

# What's New

Before getting into the technical details of V2, lets look at the fun stuff, what's new.

The first thing you're likely to notice is the UI has been revamped. 
It is based on a modern UI toolkit that allows for easy animations, Sublime-style scroll bars, interactive virtual boards, and drag-and-drop window splitting.

Alchitry Labs V2 supports the new [Lucid V2](@/tutorials/lucid-reference.md).
See the [V1 vs V2 blog post](@/news/lucid-1-vs-2.md) for a summary of what has changed. 

Support for Lucid V2 is so much deeper than Lucid V1 ever was. 
Alchitry Labs now creates a full model of your Lucid code.
This causes plenty of errors that would just fly under the radar in V1 to be caught and reported in real-time.
It also allows for your project to be simulated.

## Simulations

By clicking the little bug icon, you can launch the simulator.
It currently supports the base board (Au, Au+, or Cu) as well as the Io.

The simulator is an interactive virtual board running your design.

![Alchitry Labs 2.0.8](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.8-preview.gif)

You can toggle the DIP switches or press the buttons by clicking on them.
PWM effects are also simulated on LEDs allowing for fade effects or multiplexing of the Io element's 7-segment displays.

The only real catch is the simulator can't run as fast as dedicated hardware.
By default, it runs at 1KHz which is a fair bit slower than the 100MHz clock on the real board.
However, many educational designs don't need a fast clock.
Hopefully, the Io simulator will make learning the basics that much easier.

### Test Benches

Alchitry Labs V2 supports test benches.
These allow you test out Lucid modules to make sure they are doing what you expect them to do.

In a test block, you can manipulate the values feeding into a module then check their outputs.
In the event that things didn't go according to plan, the values of every signal at every step of the simulation are saved, and you can view them after it finishes.
See the [test bench blog post](@/news/lucid-v2-update-2.md) for more details.

## Open Source Tools

Using the open source tools ([yosys](https://github.com/YosysHQ/yosys), [nextpnr](https://github.com/YosysHQ/nextpnr), [icestorm](https://github.com/YosysHQ/icestorm)) for the Cu has never been easier.
Alchitry Labs V1 had support for some of the older open source tools, but you had to install them yourself.
V2 now comes with the open source tools so you can use them out of the box for the Cu.

This also means that you can now build projects for the Cu natively on a Mac!

Currently, the open source tools don't support the Artix 7 used on the Au, but they are in [development](https://github.com/gatecat/nextpnr-xilinx/).

## All The Small Things

Alchitry Labs V2 has been in the works for over two years now.
There are way too many things to list here that has changed.

Most of the important changes are under the hood and will allow future improvements to continue in a sustainable way.

I hope you'll head over to the [download page](https://alchitry.com/Alchitry-Labs-V2/download.html) and check it out.
You can leave any general feedback on the [discussions page](https://github.com/alchitry/Alchitry-Labs-V2/discussions) and report any issues to the [issues page](https://github.com/alchitry/Alchitry-Labs-V2/issues).

# Why V2

Alchitry Labs was originally the Mojo IDE. The goal of the Mojo IDE was to both create an IDE with creature comforts like real-time syntax error checking and support a new HDL, Lucid, to make programming FPGAs more accessible.

The initial Lucid support was very basic. The IDE would show any syntax errors, but nothing more in depth than that.

The focus was on creating a Lucid -> Verilog translator so you could even use it. 
Only later, more indepth parsing was added.

At first, only the widths of signals and expressions were checked. 
It was able to warn you if an assignment would truncate your value.

Over time, the types of errors being checked continued to grow. 
Eventually, it was doing full parsing of constant values.

This lead to the idea that the parser could be used to simulate Lucid. 
All you have to do is run it over and over right... right?
Turned out to be a tad more complicated.

When looking into how to actually turn the parser into a simulator, it was clear the pile of tech debt had grown too much to ignore any longer. 
I started writing the Mojo IDE a decade ago during my junior year of college. 
It was by far the biggest piece of software I had written and I made plenty of questionable design choices.

To make any meaningful improvements, a full rewrite looked like the only practical way forward.

## New Tools

Since things were starting over, I was able to overhaul the GUI. 
V1 was based on the aging SWT. 
V2 is based on Compose.
While I appreciated that SWT kept the look and feel of the native desktop environment, Compose is enormously more flexible.
The new interactive virtual boards would have been incredibly difficult to pull off with SWT. 

The other major shift is that V2 is pure Kotlin. 
I was notoriously bad at checking for null values in the original Java based parser causing a vast number of bugs that would simply crash the IDE.
Kotlin's built-in null safety has been incredibly helpful.

Kotlin's other features, like coroutines, have also been instrumental for building out the simulator in an efficient manner.

The last fundamental change was in the build system.
Before V2, building distributables was a nightmare.
It was a multistep error-prone process including firing up a Windows VM to build the Windows executable and installer.
This inherently lead to infrequent updates since they were such a pain.

The new system relies on [Hydraulic Conveyor](https://conveyor.hydraulic.dev/).
This software is awesome.
It lets me build and publish distributables for Windows, Linux, and Mac, with one click from Linux.
It is also free for open source software.

# What's Next

With the beta released, the next step is to update the tutorials.
I'll be working on the first few this week.

Looking back at the V1 tutorials, I'm a bit disappointed I never got into the depth I should have.
I'm planning to rectify that with V2.

These will go hand in hand with work on the IDE.
The best place to see what's coming is the [issues page](https://github.com/alchitry/Alchitry-Labs-V2/issues).