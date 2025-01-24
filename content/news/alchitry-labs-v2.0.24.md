+++
title = "Alchitry Labs V2.0.24 - Negative Indices"
date = "2025-01-24"
inline_language = "acf"
+++

[Alchitry Labs V2.0.24-BETA](@/alchitry-labs.md) is now out bringing many updates from the last blog post on 2.0.21.
<!-- more -->

# New Components
Alchitry Labs now has a few new components baked in to support the [Ft](https://shop.alchitry.com/products/alchitry-ft-v2),
[Ft+](https://shop.alchitry.com/products/alchitry-ft-v2?variant=48644641161493), and [Hd](https://shop.alchitry.com/products/alchitry-hd).

Most importantly, constraint files for these boards are now in the _Components Library_.
This also includes the much overdue constraint file for the original Ft.

A new `ft` component was added under the _Interfaces_ category of the _Components Library_.
This component supports the Ft and Ft+ with both read and write operations.
It's a great starting point for any project using either of these boards.

It handles switching between reads and writes automatically.
The interface to the rest of your design is simply two FIFOs.
One for sending data and one for receiving data.

Parameters can be set to prioritize sending or receiving to ensure you don't accidentally starve out one direction.

A tutorial showing how to design an interface and actually get data off is planned.

The `spi_controller` and `spi_peripheral` components also got a facelift.
The `spi_peripheral` has improved synchronization of its inputs and now provides a clock cycle to use the last
received byte to influence the next byte to send.

The `spi_peripheral` is great when bus speeds are fairly low (<1/16th the system clock).
However, sometimes you need a faster bus.
This is where the new `spi_fast_peripheral` comes in.

This component supports bus speeds right up to the system clock.
Being able to handle this speed has a few tradeoffs over the standard version.
First, the byte to be sent out on the next cycle is read during the previous byte.
This means that the first byte of a transaction is always 0 and a dummy byte must be inserted if you need to respond
to a previous byte.

A typical transaction usually starts with the controller sending a command followed by the peripheral responding.
A dummy byte is required between the command and the response to give it type to get the byte received across clock
domains and the byte to send back across.

# Asynchronous Resets

When writing the `spi_fast_peripheral`, I ran into a fairly unique scenario where I needed to reset some `dff` when
there wasn't a clock present.
This means I needed to use an asynchronous reset.
Typically, you don't want to use these in an FPGA because they can lead to timing issues if you aren't careful about
how the reset edges will line up with the clock edge.
This issue is exactly why the `reset_conditioner` is used to synchronize the input from the reset button to create a
synchronous reset.

Sometimes, there is no way around needed an asynchronous reset though and there was no way to implement one in Lucid.
This lead me to add the `arst` signal to `dff`.
This signal works identically to `rst` except it is implemented as an asynchronous reset instead of synchronous.
You can only provide `rst` or `arst` for any `dff`, not both.

An asynchronous reset will cause the value of the `dff` to immediately change to its reset value.
A synchronous reset waits for the next rising edge of the clock.

In the case of the `spi_fast_periperal`, an asynchronous reset was used to reset some `dff` that are clocked off the 
bus clock when the chip select line is high.
During that time, there typically aren't any clock edges so a synchronous reset would never actually reset.

While this is now available, you should almost always opt for just using `rst` in your design unless you have a really
good reason not to.

# Negative Indices

While `arst` is a feature you generally won't use, negative indices are something I think you'll use all the time.

If you've ever used Python, you've likely encountered negative indices.
This is when indices of an array _wrap around_ 0 instead of being invalid.
That means that index -1 is actually the highest index.

There are many places where I'll have some signal like `my_really_long_signal_name` and I'll need to access its MSB
(most significant bit).
If the size of the signal could change, I would have had to write 
`my_really_long_signal_name[$width(my_really_long_signal_name)-1]` to get the MSB.
With negative indices, I can now simply write `my_really_long_signal_name[-1]` and the tools will figure it out.

Essentially, if the index is negative, it is added to the width of the signal.
That means -1 is the MSB, -2 is one bit down from the MSB, etc.

You can use this anywhere you would have used an index before including in range selectors.
For example, `my_really_long_signal_name[-1:-2]` would select the top most two bits.

Hopefully you'll find this as helpful as I do!

# Updates

Some major work went into updating things to work with the latest Compose (GUI) version.

It seems like they did a lot of work with Compose to improve its performance and only redraw/compose things that fully 
need it but that cause some issues in our custom code editor.
I think it got it all working but if you notice any weird UI artifacts, post 
[an issue on GitHub](https://github.com/alchitry/Alchitry-Labs-V2/issues).

A lot of work also went into creating a new workflow for working with the open source [YosysHQ](https://github.com/YosysHQ)
projects.
This trip down this rabbit hole was started from an issue raised where `yosys-abc` was creating access denied errors 
when installed on Windows.
After figuring out the issue, I ended up [forking the build scrips](https://github.com/alchitry/oss-cad-suite-build)
that YosysHQ uses to build specifically for Alchitry Labs.
With this, it'll be easy to keep the open source tools bundled with Alchitry Labs up to date.

Running the gradle task `download-oss-cad-suite` fetches the latest build and adds it to Alchitry Labs.

Thanks for reading and I hope you enjoy the new updates!