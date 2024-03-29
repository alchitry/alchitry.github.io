+++
title = "Servos"
weight = 8
+++

This tutorial will explain how servos work and how to use them in your Lucid projects. We will be using a pre-written module (found in the Components Library in the Mojo IDE) but the module will be fully explained. Enjoy!

Servos, for those unfamiliar, are typically little boxes that have a spline that a _servo horn_ can be attached to. Inside the box is a set of gear, a motor, a potentiometer and some control electronics. What makes a servo useful is that you can simply specify a position and the electronics inside will drive the motor to move the spline to that position. A typical servo has a travel range of a little over 180 degrees. However, you can find servos with more. There are even special servos that act more as a motor and spin continuously. Similar to servos would be electronic speed controllers, or **ESC**, which can be used to accept the same signal as a servo but will drive a motor for you. These are commonly used in RC hobbies (cars, planes, helicopters, etc.) and can be great for robots.

## The PWM Signal

Servos require that you send them a PWM signal, but the signal has some special requirements. Typically, a PWM signal will have a duty cycle that ranges from 0% (always off) to 100% (always on). However, a servo uses a much narrower range and it is less helpful to think of duty cycle as it is pulse width.

![servo_signal.png](https://cdn.alchitry.com/lucid_v1/mojo/servo_signal.png)

A typical servo expects a pulse every 20ms, or 50 times per second. The width of these pulses specifies the position of the servo. The center, or neutral point, is generally set with a 1.5ms pulse. It is pretty safe to assume that any servo will then accept +/-0.5ms. In other words, 1ms to 2ms pulses.

It's important not to exceed the servo's range as servos are typically stupid and will try to drive the motor past a fixed stopping point potentially burning it out.

Lucky for us, there's a component that will make this super easy.

## Controlling Servos

Make a new Lucid project based on the _Base Project_ and open the _Components Library_. Add the servo controller, which can be found under _Controllers_. While you are there, also add the _Counter_ component to your project (found under _Miscellaneous_).

Before I explain how this component works, let's put it to use.

Open up _mojo_top.luc_ and make it look like the following.

```lucid
module mojo_top (
    input clk,              // 50MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input cclk,             // configuration clock, AVR ready when high
    output spi_miso,        // AVR SPI MISO
    input spi_ss,           // AVR SPI Slave Select
    input spi_mosi,         // AVR SPI MOSI
    input spi_sck,          // AVR SPI Clock
    output spi_channel [4], // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,           // AVR TX (FPGA RX)
    output avr_rx,          // AVR RX (FPGA TX)
    input avr_rx_busy,      // AVR RX buffer full
    output servo            // My servo
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst) {
      servo servo_controller(#RESOLUTION(16));
      counter ctr(#SIZE(17), #DIV(10));
    }
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    led = 8h00;             // turn LEDs off
    spi_miso = bz;          // not using SPI
    spi_channel = bzzzz;    // not using flags
    avr_rx = bz;            // not using serial port
 
    // Connect the counter to the servo controller
    servo_controller.position = ctr.value[15:0]^(16x{ctr.value[16]});
 
    // Output the servo signal
    servo = servo_controller.servo;
  }
}
```

First, I added the _servo_ output. You will also need to add the following to _mojo.ucf_.

```ucf
NET "servo" LOC = P50 | IOSTANDARD = LVTTL;
```

This will be the pin we use to control the servo.

The _servo_ module has a few parameters, but the one you will change most is probably _RESOLUTION_. This sets how precise you can control the width of the pulse. Most of the time 8 bits will be plenty, but, we will use 16 here just to show off the FPGA (buttery smooth servo motion).

We then have a counter that outputs 17 bits with 10 bits of extra division to slow things down.

The reason we need 17 instead of simply 16 is because of the neat little trick on line 40 that allows you to use the 17th bit to make the counter count up then count down.

```lucid
servo_controller.position = ctr.value[15:0]^(16x{ctr.value[16]});
```

Here we take bit 16 (the 17th bit) and duplicate it 16 times. We then XOR this with the lower 16 bits of the counter. When bit 16 is 0, the XOR with 0 does nothing and the counter behaves exactly as you would expect. However, once bit 16 is 1, all the bits of the output are XORed with 1. XOR with 1 will invert the bits. Inverting the bits is the same as taking the max value and subtracting the counter value from it, so in effect it will start counting down. What will happen is the counter will count from 16h0000 to 16hFFFF then back to 16h0000.

Here are some images to help explain what is happening.

![basic_counter_921e6f82-afd0-4cf9-96b8-321bfebf005d.png](https://cdn.alchitry.com/lucid_v1/mojo/basic_counter_921e6f82-afd0-4cf9-96b8-321bfebf005d.png)

This is what a basic counter looks like. As it reaches the max value, it resets back to 0. The areas in gray are where the MSB is 1.

![basic_counter_wo_msb_d14b6cb0-2987-4653-ad9e-26e877d2dfec.png](https://cdn.alchitry.com/lucid_v1/mojo/basic_counter_wo_msb_d14b6cb0-2987-4653-ad9e-26e877d2dfec.png)

If we now simply ignore the MSB, we get the same thing but with twice the frequency and half the max value.

![basic_counter_inversion_00da0619-17b4-408f-a85f-ebb2e9df7f91.png](https://cdn.alchitry.com/lucid_v1/mojo/basic_counter_inversion_00da0619-17b4-408f-a85f-ebb2e9df7f91.png)

Finally, if we use the MSB to invert every other section, we get a nice saw-tooth wave without any discontinuities.

You can now build the project and load it to your Mojo.

Plug a servo into P50, RAW (make sure the Mojo is powered with 5V), and GND. The servo should move back and forth. You should notice that the servo stops at both extremes for a short period. This will be explained in the next section.

## The Servo Controller

Now we will take a look at the controller itself.

```lucid
module servo #(
    // Clock frequency (Hz)
    CLOCK_FREQ = 50000000 : CLOCK_FREQ > 0,   
    // How much the pulse width can change (us)                
    MIN_MAX_DIFF = 500    : MIN_MAX_DIFF > 0,   
    // Neutral pulse width (us)                
    CENTER_WIDTH = 1500   : CENTER_WIDTH > MIN_MAX_DIFF,
    // PWM period (us)
    PERIOD = 20000        : PERIOD > MIN_MAX_DIFF + CENTER_WIDTH,
    // Number of bits used to set the position
    RESOLUTION = 8        : RESOLUTION <= $clog2((CLOCK_FREQ/1000000)*(2*MIN_MAX_DIFF))
                            && RESOLUTION > 0
  )(
    input clk,                  // clock
    input rst,                  // reset
    input position[RESOLUTION], // servo position
    output servo                // servo output
  ) {
 
  // Max value of counter
  const TOP = (CLOCK_FREQ/1000000) * PERIOD;
  // Min/max offsets
  const MIN_MAX = (CLOCK_FREQ/1000000) * MIN_MAX_DIFF;
  // Amount to shift input by to get close to MIN_MAX range
  const SHIFT = $clog2(MIN_MAX*2) - RESOLUTION;
  // Offset to get a pulse centered around CENTER_WIDTH
  const OFFSET = (CLOCK_FREQ/1000000) * CENTER_WIDTH - $pow(2,RESOLUTION+SHIFT-1);
 
  .clk(clk), .rst(rst) {
    dff pos[RESOLUTION];    // buffer for input
    dff ctr[$clog2(TOP)];   // counter for PWM
  }
 
  always {
    ctr.d = ctr.q + 1;      // increment the counter
 
    if (ctr.q == TOP - 1) { // if the counter overflowed
      // We only update the position when the counter overflows to avoid glitches
 
      // if position is over-saturated
      if (position > $pow(2,RESOLUTION-1) + MIN_MAX)
        pos.d = $pow(2,RESOLUTION-1) + MIN_MAX;
 
      // if position is under-saturated
      else if (position < $pow(2,RESOLUTION-1) - MIN_MAX)
        pos.d = $pow(2,RESOLUTION-1) - MIN_MAX;
 
      // else it is safe to just assign it
      else
        pos.d = position;
 
      // reset the counter
      ctr.d = 0;
    }
 
    // PWM output
    servo = (pos.q << SHIFT) + OFFSET > ctr.q;
  }
}
```

This module is pretty dense due to all the stuff to make it easily configurable.

Let's first talk about the parameters. _CLOCK_FREQ_ is used to specify the clock frequency (who would have guessed?). For the vast majority of projects, this will be 50MHz, or 50,000,000Hz. _CENTER_WIDTH_ is used to specify the neutral point for the servo. As mentioned before this is typically 1.5ms. All the time parameters are specified in micro seconds so this is 1500 by default. _MIN_MAX_DIFF_ is used to set how much the pulse can vary off center. Since most servos accept 1-2ms pulses, 500us gives us exactly that (1500 +/- 500 = 1000 to 2000). _PERIOD_ is used to specify how often a pulse occurs. Again, 20ms is typical so 20000us is used.

Finally, _RESOLUTION_ we already talked about. It is the number of bits used to specify the servo's position. Note that there are some kinda crazy looking restrictions on this parameter. This is because there's a limit to how high this can be. It's the number of bits needed to represent the number of clock cycles in the difference between the min and max pulse widths. By default, the difference is 1ms and we have a clock of 50MHz. This means there are 50,000 clock cycles, or 50,000 possible steps we can use for the pulse width. Since you need 16 bits to represent this, 16 is the maximum value _RESOLUTION_ can take.

Note that the way this is setup is very different than is you use PWM on something like an Arduino to control a servo. There if you use a 16bit counter, you will only get a small sliver of that in actual usable resolution. Most of it will be wasted in waiting for the reset of the pulse period. The FPGA can achieve a **MUCH** higher resolution than any microcontroller I've ever seen.

The constants on lines 61 to 67 are just some more calculations for all the flexibility. _TOP_ is the value to reset the timer at so we get a period of exactly _PERIOD_. _MIN_MAX_ is the number of clock cycles to allow in either direction of the center. _SHIFT_ is the number of bits to shift our input position by if we aren't operating at maximum resolution._OFFSET_ is the offset to use to make sure the pulse width is _CENTER_WIDTH_ when the input position is half of its max value.

When the counter reaches its maximum value (_TOP - 1_), we reset the counter and update the position value. The reason we update the value here is because it prevents us from updating when the pulse could be active. If the pulse could be active and we change the desired position, we could get half a pulse which causes servos to glitch (jitter).

Here we also cap the values of the position so that we never output a pulse outside the set bounds. This is why the servo pauses at either extreme as it sweeps back and forth. The two extremes have values that aren't being used but the counter sweeps them anyways. If we wanted to open these up, we could simply set _MIN_MAX_DIFF_ to be a bit larger.

Finally, we output a 1 only when the shifted position plus offset is greater than the counter.

That's it for this module! You could totally use the _PWM_ component instead, but you would have to do a lot of calculations to set the TOP value correctly and then you would need to be careful about what duty cycle you requested to not damage your servo. With this module, you don't have to think about the details and it won't let you send values outside the range you specify.