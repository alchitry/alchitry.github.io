+++
title = "Alchitry Labs V2 - Update 3"
date = "2024-01-15"
inline_language = "lucid"
+++

Simulations are now supported!

![Alchitry Labs 2.0.4 PREVIEW](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.4-preview.png)

## Test Benches

The new update, [2.0.4-PREVIEW](https://new.alchitry.com/Alchitry-Labs-V2/download.html), now has the first draft of the simulation GUI.

To run a simulation you need to first create a test bench.

I've covered these before when you could first run them from the command line so make sure to [check that out](https://alchitry.com/news/lucid-v2-update-2-test-benches) if you haven't already.

There's been an addition to the `$print` function though. You can still pass it a signal directly for the old behavior, but you can now pass in a formatting string followed by the values to use.

This is similar to something like `printf` in C/C++.

The function call looks something like `$print("my value is %d", mySig)` where `mySig` is the signal to print in decimal where the %d is.

The format options are `"%d"` for decimal, `"%b"` for binary, `"%h"` for hexadecimal, and `"%nf"` for fixed point where n is the number of fixed fractional bits (for example `"%2f"`).

## Run the Test

In the code editor, when it detects a test, there is an arrow in the left hand gutter on the line where the test was declared. You can click this arrow to run that test.

Alternatively, clicking the bug icon in the toolbar will run every test.

The results of the test are printed to the console and a new tab is opened displaying the resulting values captured at each `$tick()`. 

The waveform viewer is currently pretty basic but its enough to start messing with it.

You can use the mouse wheel to zoom and click/drag to pan around.

The values at your cursor are show as an overlay.
