+++
title = "Alchitry Labs V2.0.5 - Simulations"
date = "2024-02-06"
inline_language = "lucid"
+++

[Version 2.0.5-Preview](https://new.alchitry.com/Alchitry-Labs-V2/download.html) of Alchitry Labs is now available. It now supports simulating the main Alchitry boards as well as the Io Element.
<!-- more -->

![Alchitry Labs V2.0.5 Preview](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.5-preview.png)

## Simulation Setup

Minimally, if your design connects to the `CLOCK` pin on the Alchitry board, you can click the little bug icon in the tool bar. This will open up a tab that will show a virtual version of your Au or Cu.

If you also connect to the `RESET` pin or the `LED0` through `LED7` pins, the main board will also simulate those.

By "connect" I mean that you have valid pin constraints for them in your .acf file.

With these connected, you can write your design how you normally would. However, when you click the "bug" the simulation will start almost immediately.

![Counter Simulation](https://cdn.alchitry.com/labs-v2/au_sim.gif)

Here's a GIF of a counter running on the board. Note that I have the simulation speed set way down so you can easily see the LEDs blinking.

When writing this I discovered a bug in 2.0.5 that prevents you from setting the speed really low (~20Hz or less) where it just doesn't do anything. It's fixed and will make it into the next release.

What's really cool about the simulation is that the LED state isn't just on or off. It actually keeps track of all the values from the previous frame and averages them to allow for PWM.

![Wave Animation](https://cdn.alchitry.com/labs-v2/wave_sim.gif)

Here's the classic wave pattern that the Alchitry boards ship with being simulated.

This fake persistence of vision effect was important when implementing the 7-segment digits on the Io Element. These are multiplexed so you typically only have one of the four lit at any given time.

This is all accurately simulated and you can see in the first screen shot an example of it showing some numbers.

The buttons and switches are also all intractable. Clicking on a button momentarily presses it while click on the dip switch toggles it.

When the simulator detects that your design is connected to all the signals of the Io Element, it'll stack one on top automatically.
## Controlling the Simulation

In the simulation tab, there is a toolbar with a couple of buttons and a text box for controlling the simulation.

The first button lets you play/pause the simulation.

When the simulation is paused, you can enter a target into the "Target Rate" field. This is the number of cycles per second the simulator will attempt to hit.

It may not be able to actually hit your target depending on your design and computer.

When the simulation is running, in the top right you can see the actual simulation rate.

For example, my computer is able to hit about 3,200 Hz when running the wave and Io demo.

Replacing the fancy wave pattern with a basic counter, I can hit about 13,800 Hz. 

The `repeat` loop in the wave pattern module is relatively slow to simulate as it can't be parallelized in simulation. Each `always` block runs in it's own job so many `always` blocks can be run in parallel but a single always block can't be.

Back to the simulator, the last button is the reset button. This just simple resets your design as if you power cycled it.
## Next Steps

I'm now pretty happy with the simulator. I put a ton of work into getting it to run faster and got about 4x the performance from where I started.

It's kind of hilarious to see all 32 monster cores of my desktop struggling reach 100 Hz in some benchmarks  when the real FPGA does it all at 100,000,000 Hz with room to spare.

Obviously, this type of simulation is no substitute for actually running stuff on the board. However, with the addition of the Io Element, I hope it'll let some people get into digital design by lowering the barrier to entry just a little more.

Please let me know if you try it out and what you think! You can email me at [justin@alchitry.com](mailto:justin@alchitry.com) or post on the [discussion page](https://github.com/alchitry/Alchitry-Labs-V2/discussions).

Next, I'll be working on the quality of life features of the IDE. 

You can already format you code with Ctrl+Alt+L but stuff like auto-indenting on new lines needs to be done.

I also plan to create a robust auto-complete feature. The old one wasn't awful, but it wasn't context aware and would recommend things that would auto-complete into an error.

There's also a known bug where the cursor position will get a little messed up. Hitting Ctrl+Alt+L works as a workaround but I need to track down what's causing it.

Until next time!