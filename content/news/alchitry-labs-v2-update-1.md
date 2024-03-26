+++
title = "Alchitry Labs V2 - Update 1"
date = "2023-10-13"
+++

Today was the first time I built a .bin file from Alchitry Labs V2!

Before we get too far ahead, there is a lot more to cover.

In the last release, I use the Compose Multiplatform Gradle plugin to create [native distributions](https://github.com/JetBrains/compose-multiplatform/blob/master/tutorials/Native_distributions_and_local_execution/README.md).
At first, this seemed like an awesome solution. However, it has one fatal flaw.

The plugin requires you to build each target on its respective platform. That means if you want to build for Windows, you need to be on Windows. If you want to build for an ARM based Mac, you need to have an ARM based Mac.

This requirement was the same issue I had before with the original Alchitry Labs but it wasn't that bad since I only ever built for Windows and Linux X64. I was able to do everything from Linux using a Window VM.

This time around, I want to add support for more systems. Alchitry Labs runs on a JVM (Java Virtual Machine) so in theory it should run in a ton of places with minimal work.

I'm hoping to target everything that Compose supports, Windows x64, Linux x64, Linux ARM, Mac x64, and Mac ARM.

When looking for solutions to this, I came across [Conveyor](https://www.hydraulic.dev/) which seems to be almost everything I was looking for. Best of all, it is free for open source projects like Alchitry Labs!

Conveyor lets you build for every target from a single system. It also deals with code signing and pushing updates.

The only downside right now is that it doesn't support Linux AArch64 (ARM). I became a paid subscriber to get this feature onto the dev's radar and I was told it will likely make it into the next major release.

Now that I have this all setup, I can run a single command that builds my project, creates update packages, creates an update website, and pushes it all to GitHub.

You can now download the latest version from the [GitHub page here](https://labs.alchitry.com/download.html)

I'm currently just self signing everything. This only really matters for Windows and Macs where you'll see more security warnings when trying to install it.

I'll likely get everything officially signed for the next release. For the Window's release, this means that it'll be available from the Microsoft Store.

The Linux version is now packaged as a deb which makes installation so much easier! Installing the deb also adds an update site so that when updates for Alchitry Labs are available they show up in the package manager with everything else.

## Mac Support

As I've mentioned above, the new releases have Mac versions.

Before you get too excited, no, you still can't run Vivado or iceCube 2 on a Mac. This means that you still can't build FPGA projects using the proprietary tools.

So why bother supporting Macs? First, many people run the build tools inside of virtual machines inside a Mac. USB devices don't always play nicely going across the VM layer so by having native support for the Alchitry Loader, we can avoid that issue.

The Mac versions of the loader are already working!

Second, there are open source tools that _can_ run on a Mac. I'm hoping to bundle these with a later release of Alchitry Labs so that you will be able to develop for the Alchitry Cu natively on a Mac.

## The New Verilog Converter

The biggest update to the Alchitry Labs V2 codebase is the Verilog converter.

Continuing with the full rewrite, the new converter is much cleaner than the old one. The original converter was one of the first things I wrote back when the IDE was the "Mojo IDE."

Back then, the converted was responsible for everything. Given some Lucid text, it had to spit out a Verilog version.

The new converted is instead given a fully parsed Lucid module instance. A lot of the complicated tasks are already done in the previous stage such as dealing with signal indexing, declarations, etc.

This, along with better coding practices, has made the new converter about 40% of the size of the original! I'm pretty excited for it.

## ACF Parser

With a Lucid->Verilog translator working, the next step was to add support for constraint files.

The Alchitry Constraint File format is super simple and adding a parser for it wasn't too complicated.

I ended up modifying the format a bit from V1 though. 

Keeping with the change to Lucid, semicolons are now optional. Also, clock statements are considered a special type of pin statement so you don't need to specify both for a single pin.

It now checks that the names of the ports and pins are valid. Wildly, I apparently never checked the pin names properly for V1 so they would just show up as "null" in the converted constraint file and cause silent issues.

For now, I just have an ACF->XDC converter (XDC is the Xilinx format).

## Test Build

With all the pieces in place, I was able to get a test build running.

Once a project is open, calling `Project.build()` simply builds the entire project!

This only works for the Au/Au+ right now as I still have to port the Cu builders but it is a big milestone!

Building Au projects is accessible from the command line interface now.

If you want to check out the progress, see [the GitHub page](https://github.com/alchitry/Alchitry-Labs-V2).

You can install the [latest version here](https://labs.alchitry.com/download.html).