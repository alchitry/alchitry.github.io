+++
title = "Analog Inputs"
weight = 7
aliases = ["tutorials/lucid_v1/mojo/analog-inputs.md"]
+++

Welcome to the Analog Inputs Tutorial! In this tutorial, you will learn how to read the analog inputs on the Mojo. To demo this, we will modify the _AVR Interface Project_ so that the analog values are displayed on the LEDs.

## Reading a Channel

We will start off by first reading only the _A0_ input and displaying its value on all eight LEDs.

First, make a new project based on the _AVR Interface Project_. This project already has the _avr_interface_ module added and the basic connections wired up.

### ADC to LEDs

We are going to create a new module named **adc_to_leds**. But before we do that, add the _Pulse Width Modulator_ component to your project. It can be found under _LED Effects_ in the _Component Selector_. We will be using this to fade the LEDs based on the voltage read.

With all the components we need added, create a new module named **adc_to_leds** and fill it with the following.

```lucid
module adc_to_leds (
    input clk,               // clock
    input rst,               // reset
    output channel[4],       // channel we want to sample
    input sample[10],        // sample value
    input sample_channel[4], // channel the sample is from
    input new_sample,        // 1 = new sample
    output leds[8]           // output to leds
  ) {
 
  .clk(clk), .rst(rst) {
    pwm pwm(#WIDTH(10));     // 10bit PWM to show ADC value
  }
 
  always {
    channel = 0;             // always read channel 0
 
    pwm.value = sample;      // set the PWM to the ADC sample value
    pwm.update = new_sample; // update the PWM when we have new samples
 
    leds = 8x{pwm.pulse};    // send PWM signal to all LEDs
  }
}
```

The way the ADC interface works is that we specify a channel we want to sample on _channel_. Then when a new sample is ready, the _new_sample_ signal will go high. This signals that _sample_ and _sample_channel_ have valid data. The signal _sample_channel_ specifies which channel the sample came from. This is important because as you start switching the channel to sample from, you are not guaranteed that the next sample will come from the new channel if a sample was already being read from the old channel. In this particular case, we are only ever reading one channel so all the samples must have come from channel 0.

Note that the channel number corresponds to the analog input number. In other words, channel 0 is A0, channel 8 is A8, etc. If you set channel to an invalid number (like 15), the ADC is disabled and no channels are sampled. This is useful if you don't need the ADC running as it frees up the AVR to send and receive USB data faster.

The PWM module is pretty simple. Since we set the _WIDTH_ to 10, we specify a 10 bit value on _pwm.value_ and set _pwm.update_ to 1 whenever there is a new value. The output, _pwm_pulse_, is then a PWM signal with a duty cycle of _pwm.value_/210.

Finally, we simply duplicate the pwm output to all LEDs.

### Connect it Up

We now need to add our new module to _mojo_top_.

```lucid
.rst(rst){
  // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
  avr_interface avr;
 
  adc_to_leds adc; // reads the analog inputs and shows them on the LEDs
}
```

We also need to connect it up.

```lucid
// connect the adc module
avr.channel = adc.channel;
adc.sample = avr.sample;
adc.sample_channel = avr.sample_channel;
adc.new_sample = avr.new_sample;
led = adc.leds;
```

Note that the lines where _avr.channel_ and _led_ were previously assigned should be removed.

You should be able to build the project and load it onto your Mojo. With the project loaded, if you take a potentiometer and connected one end to +V (3.3v), the other to gnd (0v), and the arm to _A0_ then you should be able to use the potentiometer to control the brightness of the LEDs.

## Multiple Channels

This is super cool and all, but we have 8 inputs so it feels like a waste to only use one. Since there are conveniently 8 analog inputs and 8 LEDs, lets show each analog input on its own LED.

To do this we only need to change the _adc_to_leds_ module.

```lucid
module adc_to_leds (
    input clk,               // clock
    input rst,               // reset
    output channel[4],       // channel we want to sample
    input sample[10],        // sample value
    input sample_channel[4], // channel the sample is from
    input new_sample,        // 1 = new sample
    output leds[8]           // output to leds
  ) {
 
  // This is used to convert 0 to 7 to its corresponding channel 0 to 1 and 4 to 9
  const LED_TO_CHANNEL = {4d9,4d8,4d7,4d6,4d5,4d4,4d1,4d0};
 
  // This is used to convert the sample channel to the corresponding LED
  // Most channels are invalid and will never be seen so we use 'x' as don't cares
  const CHANNEL_TO_LED = {4bx,4bx,4bx,4bx,4bx,4bx,4d7,4d6,4d5,4d4,4d3,4d2,4bx,4bx,4d1,4d0};
 
  .clk(clk), .rst(rst) {
    pwm pwm[8](#WIDTH(10));                           // 10bit PWM to show ADC value
    dff ch[4];                                        // channel counter
  }
 
  always {
    channel = LED_TO_CHANNEL[ch.q];                   // set the channel to sample
 
    pwm.value = 8x{{sample}};                         // all PWM values are from sample
    pwm.update = 8b0;                                 // default to not updating
 
   // when there is a new sample for our given channel
   if (new_sample && sample_channel == LED_TO_CHANNEL[ch.q]) {  
      pwm.update[CHANNEL_TO_LED[sample_channel]] = 1; // update the corresponding PWM channel
      ch.d = ch.q + 1;                                // increment the channel we are sampling
      if (ch.q == 7)                                  // there are only 8 channels (0 to 7)
        ch.d = 0;                                     // restart at 0
    }
 
    leds = pwm.pulse;                                 // send PWM signals to all LEDs
  }
}
```

The analog input channels are slightly strange on the Mojo in that A2 and A3 don't exist. To compensate for this, we use the constants _LED_TO_CHANNEL_ and _CHANNEL_TO_LED_ to map from our LED indices (0 to 7) to the ADC channel indices. Notice that there are 16 possible values for the channel, but we are only using 8 so we filled the remaining slots with _4bx_. This is because these values should never be used anyways and it gives the tools freedom to choose whatever makes our design simplest.

Notice that we now have eight _pwm_ modules as _pwm_ is now an array. This is because we want a different PWM output for each of the eight LEDs.

Remember that the PWM modules only update their values when _update_ is 1. This allows us to set all the modules to have the same _value_ input and only set the corresponding module's _update_ to be 1 when we have a new sample.

Line 26 has some interesting syntax. We are duplicating an array of sample 8 times. This builds a two dimensional array with dimensions of 8 by 10. If instead we simply did _8x{sample}_ we would have a single dimensional array of 80 bits wide and the dimensions wouldn't match _pwm.value_. The reason this works is because _{sample}_ is a 2D array with dimensions of 1 by 10. The _8x{}_ part then duplicates the outermost dimension making it 8 by 10.

Each time a new sample comes in, we increment the _ch_ counter. This is so that we continue to sample all the channels in a round-robin fashion.

If you now build and load your project, you should see all eight LEDs working independently. You can test each one by plugging in your potentiometer to each channel.

That's it for this tutorial. You should now know how to make use of the analog inputs on the Mojo. A good challenge would be to modify _adc_to_leds_ so that instead of using PWM to display the analog values, you set a single LED on to show which channel has the largest value. For example, if _A1_ has the highest value, then LED\[1] should be lit and the rest should be off. You should have all the tools for this if you've followed the tutorials up to this point. If you need help you can always [visit our forum](http://forum.alchitry.com/).