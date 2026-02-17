+++
title = "Sound Locating"
weight = 14
aliases = ["tutorials/lucid_v1/mojo/sound-locating.md"]
+++

In this tutorial we will use the Microphone Shield to locate the direction that sound comes from. This is a fairly advanced tutorial that pushes the limits of what you can do with the Mojo.

We will start by covering the theory and working into how to implement this on the FPGA.

### Microphone Shield

![dsc_3056-edit_large.jpg](https://cdn.alchitry.com/lucid_v1/mojo/dsc_3056-edit_large.jpg)

The Microphone Shield has seven _PDM_, or **P**ulse **D**ensity **M**odulation, microphones. This type of microphone has a digital interface. You supply a clock and they output a series of bits. The density of these bits represents the magnitude of the audio being detected. Wikipedia has a good [article](https://en.wikipedia.org/wiki/Pulse-density_modulation) on this.

The shield also has 16 LEDs that are arranged in a ring and multiplexed over the Mojo's existing LEDs. 

We will be using these LEDs to visually output the sound direction.

### Theory of Operation

The idea is that we will record a short sample of audio from all seven microphones at exactly the same time. We can then use these samples to calculate the delay between the ring of microphones and the center microphone. These delays can be used to detect the direction of the sound's source.

For this to work, we need to make a few fairly reasonable assumptions. The first is that all sound comes from the sides of the board and not from above or below. This is required because we only have a 2D grid of microphones. The second assumption is that sound waves have a straight wavefront. This isn't typically true as sound originating from a point will have a curved wavefront, but as long as the source isn't too close it'll be a reasonable approximation. inally, we assume that each frequency in a sample comes from a single direction.

So how do we go about calculating the delays between the microphones? If we had a simple pulse and everything was quiet, it would be quite easy by just looking at the peak of the pulse in each sample. However, the real world is hardly that nice. Instead, we will be using the _phase_ of the different frequencies in each sample. This has two major benefits: the phase is pretty easy to calculate with an FPGA by using a _fast fourier transform_ (FFT), and the other being that we can detect multiple sound sources as long as their frequency components are different enough. Imagine a bird chirping and someone talking. The bird chirps will be substantially higher pitch than the person talking, and we should be able to detect these simultaneously.

If you aren't familiar with FFTs, don't worry too much. All you need to know for this example is that a Fourier transform takes a signal in the time domain, meaning the x-axis of the sample is time, and converts it into the frequency domain. It tells you what frequency sine waves (and their magnitudes) you would have to add together to get the exact same signal back. If you've ever seen a music equalizer, you've seen an FFT in action. This is exactly what the demo of the Clock/Visualizer Shield does.

So after collecting a short sample from all seven microphones, we can run each one through an FFT to get the frequency components. The FFT output for each frequency is a complex number. The real portion of the number corresponds to the magnitude of the sine portion, and the imaginary portion corresponds to the cosine portion. By adding together sine and cosine waves of varying amplitudes, you can create a sine wave with any phase.

The raw output of the FFT isn't particularly useful to us. Instead, it would be much better if we knew the phase and magnitude of each frequency. To do this, we need to convert the complex number, which can be thought of as converting a Cartesian coordinate (if that helps you) into a polar coordinate. Basically, if we were to plot the complex number on a regular 2D space, instead of the _x_ and _y_ position of the coordinate, we want to know the angle and distance it is from the origin. Again, this isn't too bad to do with an FPGA, as you'll see later.

With the phase of each frequency calculated, we can subtract the phase of the center microphone from each of the surrounding six microphones to get a phase offset for each one. Using the formula _delay = phase offset / frequency_, we could calculate the delay for that frequency. However, scaling the delay by a constant factor (the frequency) for all six microphones won't make a difference later, and we can use this fact to avoid a costly division in the FPGA. Instead, we will simply use the phase offsets as if they were the delays, since they are proportional to them.

Now that we have a delay for each microphone relative to the center microphone, we need to combine these to get an overall direction. To do this, we need to scale each of the microphone's location vectors by their corresponding delay and sum them. This will give us a single vector pointing in the direction of the sound source.

The following figure shows this geometrically. I drew in only three microphones for simplicity. Adding the other three would make the sum of the scaled vectors twice as long but wouldn't change the direction due to symmetry. I also drew this so that the sound is coming from the _y_ direction and the microphones are rotated by _ϕ_ instead of the sound coming in at angle _ϕ_. This will make it a little easier to show that this method works later. The black circles represent the locations of the microphones, and their coordinates are labeled.

![microphones_4_d7c39a4b-43f3-49d3-ae85-331f5c22eedc_large.png](https://cdn.alchitry.com/lucid_v1/mojo/microphones_4_d7c39a4b-43f3-49d3-ae85-331f5c22eedc_large.png)

The delay of each microphone to the origin (center microphone) is proportional to the _y_ value of the microphone's location. We can draw these in, as shown below.

![microphones_3_large.png](https://cdn.alchitry.com/lucid_v1/mojo/microphones_3_large.png)

If we take the location of each microphone and scale it by the corresponding delay, we get the new purple lines shown in the next figure. Note that the bottom microphone has a negative delay, so the vector points in the opposite direction.

![microphones_2_large.png](https://cdn.alchitry.com/lucid_v1/mojo/microphones_2_large.png)

Finally, we can take the three scaled vectors and sum them together by moving them tip-to-tail. This is shown by the light purple lines below. The orange vector is the result of the summation of the three scaled vectors.

![microphones_large.png](https://cdn.alchitry.com/lucid_v1/mojo/microphones_large.png)

Notice that the _x_ components of the summed scaled vectors cancel, so the resulting sum points only in the positive _y_ direction. To prove that this method works, we need to show that the _x_ components cancel and the _y_ components sum to a positive value for any value of _ϕ_. We don't care about the magnitude of the resulting vector, only the direction.

It's fairly easy to prove this is true but I'm not going to reproduce the proof here. If you are curious it is fully covered in [my book](https://www.amazon.com/gp/product/B074VTXVSM/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B074VTXVSM&linkCode=as2&tag=embeddedmicro-20&linkId=43827df1ca2f36f080be5ef94b9d4bc1).

Now that we have the angle for the frequency, we need to aggregate each angle into something useful. I chose to bin them into 16 directions so that it would be easier to use and display them on the LEDs. I used the magnitude from the center microphone to weight the importance of each frequency's contribution. This was done by iterating through each frequency, determining the bin it belonged to, and keeping a running total of the magnitude of each bin.

The final output is the 16 values representing how much noise came from that direction.

### Implementation Overview

Now that we have an idea of how this is going to work, we need to come up with a plan for implementing this in hardware.

First, we need to gather the audio samples from all seven microphones at exactly the same time. The microphones on this shield are PDM microphones, meaning that they provide a series of 1-bit pulses at a high rate (2.5 MHz in this case) that we can pass through a low-pass filter (basically, a moving average) to recover the audio signal. We also decimate the signal by a factor of 50, so our sampling rate becomes 50 KHz.

With the seven audio samples captured, we need to feed each of them through an FFT to extract their frequency information. The output of the FFT is complex numbers, but we need it to be in phase-magnitude form, so we then pass these values through a module that calculates the new values.

With the phase-magnitude representation of all the samples, we can then subtract the phases of the six surrounding microphones from the center one to get the delays. We need to be careful here because after the subtraction, the phase difference can be outside the +/– pi range. If it is, we need to add or subtract 2 pi to get it back into range.

The calculated phase differences are equal to the delay multiplied by the frequency. Because we are working with one frequency at a time, it is really just the delay scaled by a constant. We can use this fact to avoid having to divide by the frequency.

We then scale the six microphone location vectors by the corresponding phase differences (delays) and sum their components. This gives us a vector that points in the direction of the sound source for this frequency. However, we care only about the direction of this vector, as the magnitude is pretty meaningless. We can convert the Cartesian vector into a phase-magnitude representation by using the same module as before to extract the phase (angle).

Repeating this process for all the frequencies gives us an angle for the direction of sound for each frequency. We can pair each of these directions with the magnitude (volume) of that frequency from the center microphone to find out how relevant it is.

This in itself could be the output of our design, but it is a little more useful to bin the directions into a handful of angles. In our case, we will assign each into one of 16 equally spaced bins. All the magnitudes of the frequencies that fall into a bin are summed to get that bin's overall magnitude. These 16 sums are the final output and represent the amount of sound that came from each bin's direction.

We could implement this design as a full pipeline with each stage simply feeding into the next. The following figure shows what that could look like.

![fpga_1206.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1206.png)

This design would have the highest throughput, but it would also take up a lot of resources. In fact, it would take up way more than we have available in the Mojo's FPGA. However, we can instead perform each step in sequence and take advantage of the fact that a lot of the steps require the same operations, just on different data. In a full pipeline we would need seven FFTs and eight CORDICs (the Cartesian-to-phase-magnitude converts). However, we can reuse just one of each and save a ton of resources.

The following is a drawing of the _data-path_ of the circuit. The data-path shows the way data flows through a design, but it does not, for simplicity, show the control logic that controls the multiplexers and other flow decisions. The fully pipelined version doesn't need any control logic because the data just flows from one end to the other. However, we will need to create an FSM to control the compact version. The steps the FSM will need to take are outlined in the following paragraphs.

![fpga_1207.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1207.png)

First, samples from the microphones pass through the decimation filter and are stored in the RAM. The RAM is organized into seven groups of two (14 RAMs total), each 16 bits wide. The seven groups correspond to the seven microphones, and two RAMs in each group will store even and odd samples, respectively. The reason for the 7 x 2 arrangement will become clear later.

When the blocks of RAM are full of sample data, the data is passed one channel at a time to the FFT. The data is also passed through a Hanning window (not shown) to minimize leakage in the FFT. The purpose of this is outside the scope of this book, but it comes down to multiplying the samples by the Hann function that is stored in a ROM. The output of the FFT is fed into the CORDIC to convert it to phase-magnitude format and then written back into the RAM, overwriting the original channel's sample data. When writing back to the RAM, the seven groups still correspond to each channel, but the two values in each group now are for the phase and magnitude values instead of even and odd samples. By having these two values in different RAMs, we can easily read or write them simultaneously. This is repeated seven times, once for each channel. After this step is done, the RAM contains phase and magnitude data for each channel.

Because the sample data we are feeding into the FFT is all real (no imaginary components), the output of the FFT will be symmetrical. This means that even though each frequency has two values related to it, we have half the number of frequencies as we did samples, so we have the exact same number of values to store in the RAM.

The next step is to take the phase-magnitude data for each frequency and pass it through the direction calculator to get the directional vector for that frequency. The angle (phase) of that vector is then extracted using the same CORDIC as before. The output is then saved back into the RAM. This time, we write the data to group 0, as we don't need the phase-magnitude data for this microphone (nor microphones 1–5) anymore.

Finally, we feed the phase data from the last step and the magnitude data from microphone 6 (the center microphone) into the aggregator. The aggregator adds each sample to its corresponding bin and outputs the final results.

Even with all this reuse, this design still use 77% of the LUTs, 32% of the DFFs, and occupies 94% of the slices in the Mojo. It just fits!

### Implementation

Now that we have a road map of what we need to design, let's get into the code. You can find the full source as an example project in the Mojo IDE. To view it, create a new project and select _Sound Locator_ from the _From Example_ dropdown in the _New Project_ dialog.

We will start with the microphones and work our way through the steps of the sound locator.

#### PDM Microphones

This project relies on PDM microphones. These are a common type of microphone and easy to interface with an FPGA because they have a digital output. As noted previously, _PDM_ stands for _pulse-density modulation_, which means that the density of pulses is correlated to the pressure on the microphone. Because of this simple interface, we need a lot of pulses to be able to get any real definition of the underlying signal. The microphones on the Microphone Shield can output between 1 and 3.25 million pulses per second, depending on the clock provided to it. In our design, we will use the nice middle value of 2.5 million per second.

To convert this high-frequency, low-resolution pulse train into a more useful lower-frequency, higher-resolution signal, we will use a _cascaded integrator–comb_ (CIC) filter. This type of filter is useful for changing sampling rates, decimation (decrease), or interpolation (increase). Lucky for us, Xilinx's CoreGen tool can be used to generate the filter.

If you have the full Sound Locator project open, you can launch CoreGen and take a look at the _decimation_filter_ core. It was created from the CIC Compiler version 3.0, which can be found under Digital Signal Processing → Filters → CIC Compiler and is shown in the following image.

![fpga_1208.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1208.png)

Here we specify that it is a decimation type filter and should have a decimation rate of 50. This will convert the 2.5 MHz input into 50 KHz output. Take a look at the frequency response chart, which shows that it is a low-pass filter. You can play with the other parameters to get it to attenuate the higher frequencies more at the cost of more hardware. For our use, it doesn't really make a difference.

If you look at the second page, shown below, it shows the filter is capable of outputting 25 bits per sample. However, this is set to 20, so the last 5 bits are truncated. This was found empirically to be a good value for sensitivity, and we will be using only 16 bits for each sample anyway. The extra MSBs will be used to check for overflow but will otherwise be ignored.

We also have this set not to use _Xtreme DSP Slices_, as we don't have enough to spare in the FPGA. This option will use the built-in multipliers when selected instead of using the general fabric of the FPGA. However, it will use two multipliers per filter, and we have seven filters. The FPGA on the Mojo has 16 multipliers, so 14 just for this stage would be way too much.

![fpga_1209.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1209.png)

For more information on the CIC filter, check out [the Xilinx LogiCORE documentation](https://www.xilinx.com/support/documentation/ip_documentation/cic_compiler/v3_0/ds845_cic_compiler.pdf).

Armed with the filter, we can now look at the _pdm_mics.luc_ file to see how it is used.

In this module, we need to generate a clock for the microphones. This is a 2.5 MHz signal that is 1/20th of the 50 MHz system clock. To do this, we can use a counter that counts from 0–9 (10 cycles) and toggle the clock each time it overflows. We can detect overflows when the MSB falls.

On each rising edge of the microphone clock, we have another bit of PDM data from each microphone. We first need to convert the single-bit value of 0 or 1 into a 2-bit signed value of –1 or 1 for the CIC filters.

All that's left is to feed the data into the CIC filters and output the data from them after converting it to 16 bits. The CIC filter data is signed, so when we convert to 16 bits and want to saturate on overflows, we need to check for negative and positive overflow separately:

```lucid,short
module pdm_mics (
    input clk,             // clock
    input rst,             // reset
    output mic_clk,        // clock for all the microphones
    input mic_data [7],    // data from each microphone
    output sample [7][16], // sample from all 7 microphones
    output new_sample      // new sample flag
  ) {
 
  .clk(clk) {
    .rst(rst) {
      counter clk_ctr (#SIZE(4), #TOP(9));       // clock divider counter
      dff mic_clk_reg;                           // mic_clk dff
    }
    edge_detector clk_edge (#RISE(0), #FALL(1)); // clock counter reset detector
    edge_detector new_data (#RISE(1), #FALL(0)); // clock rising edge detector
  }
 
  // decimates by a factor of 50
  decimation_filter dfilter [7] (.aclk(clk));
 
  const SAMPLE_MSB = 19;
  const SAMPLE_LSB = 0;
 
  // used to store unused MSBs
  sig left_over [SAMPLE_MSB - SAMPLE_LSB + 1 - 16];
 
  var i;
 
  always {
    // generate a clock at 1/20 the system clock (2.5 MHz)
    clk_edge.in = clk_ctr.value[3];   // this bit will fall when clk_ctr resets
    if (clk_edge.out)                 // if fall was detected
      mic_clk_reg.d = ~mic_clk_reg.q; // toggle the mic clock
 
    new_data.in = mic_clk_reg.q;      // detect rising edges = new data
 
    mic_clk = mic_clk_reg.q;          // output mic clock
 
    // data valid at rising edge of mic clock
    dfilter.s_axis_data_tvalid = 7x{new_data.out};
 
    // all decimators are identical so we can use any tvalid flag for new_sample
    new_sample = dfilter.m_axis_data_tvalid[0]; 
 
    // for each mic
    for (i = 0; i < 7; i++) {
      // convert 0 or 1 into -1 or 1
      dfilter.s_axis_data_tdata[i] = mic_data[i] ? 8d1 : -8d1;
      sample[i] = dfilter.m_axis_data_tdata[i][SAMPLE_LSB+:16];
      left_over = dfilter.m_axis_data_tdata[i][SAMPLE_MSB:SAMPLE_LSB+16];
 
      // check for overflow and saturate
      if (!left_over[left_over.WIDTH-1] && (|left_over))
        sample[i] = 16h7fff;
      else if (left_over[left_over.WIDTH-1] && !(&left_over))
        sample[i] = 16h8000;
    }
  }
}
```

#### FFT

Before we jump into the _sound_locator_ module, let's take a look at the two other cores we need from CoreGen: the FFT and CORDIC cores. Again, with the Sound Locator project open, fire up CoreGen from the Mojo IDE and take a look at the _xfft_v8_0_ core.

The first page of the FFT wizard, shown below, allows you to choose the number of channels (the number of FFTs you want to compute at once), the transform length (number of samples), the system clock, and the architecture. We will be using 512 samples per iteration, which seems to be a nice balance between latency and accuracy. The FFT architecture is set to Radix-2 Lite, Burst I/O, which will result in the smallest implementation at the cost of speed. We don't care that much about speed, but resources are at a premium. Even at the slowest architecture type, it will take only 5,671 cycles to compute the transform. With our 50 MHz clock, that is a small 113.4 μs (about 1/10,000th a second). The fastest architecture is about five times faster, but takes a lot more resources that we don't have. We could likely use the next size up for a modest speed improvement, but, again it won't make an appreciable difference for this use. It takes 100 times longer for us to capture the sample in the first place.

![fpga_1210.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1210.png)

On the second page, we specify more details about the internals of the FFT. We are using fixed-point data, so the data format is set to fixed point. The samples from the microphones are 16 bit, so that's what the input data width is set to. The phase-factor width is the size of some values stored in a ROM that are used when computing the FFT. Higher values will result in a slightly more accurate result. The accuracy for our purposes isn't too important, as 16 bits is more than enough.

Scaling is used to save resources. Without scaling, the values continue to grow in the different FFT steps that require a much wider data path. However, if you enable scaling, you need to provide a scaling schedule that tells the FFT core when to truncate data. This is set at runtime, and I found one that worked well for the microphone data using Xilinx's Matlab module that simulates the FFT.

The rounding mode option is another trade-off of accuracy and resources. Truncation is basically free, while convergent rounding has a small cost.

The control signals are fairly self-explanatory; you can enable a reset and a clock enable if you need them. We need only the reset.

An FFT will naturally produce values in bit-reversed order. For an FFT of eight samples, the output order would be 0, 4, 2, 6, 1, 5, 3, 7. In binary, this is 000, 100, 010, 110, 001, 101, 011, 111. If you reverse the bits around, this becomes 0, 1, 2, 3, 4, 5, 6, 7. If you can work with the output in this order, the core can load and unload data simultaneously. Otherwise, loading and unloading must take place in different stages. By enabling XK_INDEX in the Optional Output Fields section, we get the index of each output value, so the order doesn't really matter for us.

Finally, the throttle scheme is to specify whether whatever is receiving the output can stop the core from outputting data. In other words, will the hardware using the output ever not be able to accept data? If it can't for any reason, you need to use Non Real Time. This enables the _m_axis_data_tready_ flag to signal that data can be output. If you set this to Real Time, it will spit out data as soon as it is ready, no matter what. In our case, we are feeding the data into the CORDIC core, which can be busy, so this needs to be Non Real Time.

![fpga_1211.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1211.png)

The final page of the wizard, shown below, is all about hardware usage. The first section, Memory Options, allows you to choose whether you want to use block RAM or distributed RAM. We have plenty of block RAM left over in our design, so it only makes sense to take advantage of it.

In the Optimize Options section, choose to use the DSP multipliers. The FPGA on the Mojo has 16 of these, which should be used when you can. For the CIC filter, we set it not to use these because they would use two each, and we have seven filters, so it would take a total of 14 multipliers. That is too much (our design only has eight extra). In this case, the FFT will use only three, and we can spare them. You can see how many it will use under the Implementation Details tab on the left side of the wizard.

In general, if you have special resources available (block RAM and DSPs, in this case), use them. They will generally make your design faster and smaller, and if you don't take advantage of them, they will still be sitting in your FPGA.

![fpga_1212.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1212.png)

For more information on the FFT core, check out the [Xilinx LogiCORE documentation](https://www.xilinx.com/support/documentation/ip_documentation/ds808_xfft.pdf).

#### CORDIC

_Coordinate Rotation Digital Computer_ (CORDIC) is an algorithm for efficiently calculating hyperbolic and trigonometric functions. The algorithm is capable of rotating vectors that can be cleverly used to convert to/from Cartesian and polar (magnitude and angle) notations, compute sin and cos, compute sinh and cosh, compute arc tan, compute arc tanh, or even compute square roots. We will be using it to convert from Cartesian to polar coordinates.

Open the _mag_phase_calculator_ core in CoreGen.

On the first page of the wizard, as shown in the first image below, we have options to specify the mode of operation as well as accuracy, latency, and area trade-offs.

The Functional Selection option selects the mode of operation. In our case, Translate is selected for Cartesian-to-polar conversion.

The Architectural Configuration option gives an area versus latency trade-off. The Parallel option allows the core to spit out a new value every clock cycle by replicating a bunch of hardware. The _Word Serial_ option reuses hardware but can work on only one value at a time. Optimizing for area, the Word Serial mode was selected.

The Pipelining Mode is a performance (maximum clock speed) versus area and latency trade-off. The Optimal option will pipeline as much as possible without using extra LUTs. The Maximum option will pipeline after every stage.

The Phase Format option is important, as it dictates the output format. Either option will output a fixed-point value with the three MSBs being the integer portion. For example, 01100000 would be 3.0, and 00010000 would be 0.5. In the Radians case, this value is the angle in radians. For Scaled Radians, this value is the angle divided by pi. We are using radians for simplicity.

The Inout/Output Options section is pretty self-explanatory. We are using 16-bit inputs and outputs, and truncation for internal rounding as it is the cheapest option.

Under Advanced Configuration Parameters, leaving Iterations and Precision at 0 will cause the wizard to automatically set these based on the output width. The Coarse Rotation option allows us to use the full circle instead of just the first quadrant. Compensation Scaling is used to compensate for a side effect of the CORDIC algorithm. By enabling this, the core will output unscaled correct values at the expense of some resources. You can select the resources to use in the drop-down. In our case, we are using Embedded Multiplier, as we still have a few _DSP48A1s_ to use. We could have used the BRAM option as well, as we have plenty of that too.

On the second page of the wizard, as shown in the second image below, you can configure the input and output streams. The TLAST and TUSER options give you extra inputs to the module that will output the values seen when the corresponding inputs have been processed. It's a way to pass along data and keep it in sync. In our case, we will need the address of the values and where the last sample is, so both are enabled. The address size is 9 bits, so we set TUSER's width to 9.

The Flow Control option will enable buffers on the input when Blocking is specified. This is more useful when you have the CORDIC in a different mode when both input streams are used, as it will force them to be in sync. The NonBlocking option uses less resources, and there is no real benefit to Blocking for us.

Finally, we don't care about a reset, as the CORDIC will have flushed itself by the time the FSM ever reaches it upon a reset.

![fpga_1213.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1213.png)

![fpga_1214.png](https://cdn.alchitry.com/lucid_v1/mojo/fpga_1214.png)

 For more information on the CORDIC core, check out the [Xilinx LogiCORE documentation](https://www.xilinx.com/support/documentation/ip_documentation/cordic/v5_0/ds858_cordic.pdf).

Now that we have all the pieces, let's dig into the _sound_locator_ module itself. The module is too big to replicate here in its entirety, but we will dissect the states of the FSM. The FSM has four main stages: _CAPTURE_, _FFT_, _DIFFERENCE_, and _AGGREGATE_. The _CAPTURE_ state is responsible for storing the microphone samples into RAM. In _FFT_, these samples are converted into their frequency representation. The _DIFFERENCE_ state takes this information and calculates a direction for each frequency by using the difference in phase for each microphone. Finally, _AGGREGATE_ combines all the data together into the 16 directional bins and outputs the final result.

#### CAPTURE State

The _CAPTURE_ state is pretty straightforward. We simply wait for new samples to come in from the microphones and write them to RAM, incrementing our address counter until the RAM has been filled.

There is a little fancy notation for assigning the address value to all 14 RAM modules because they are in a 7 x 2 array. The first line in this state duplicates _addr.q_ (excluding the LSB) into the 7 x 2 x 8 array.

The LSB of _addr_ is used to select between even and odd RAMs. This little quirk is because we want the two RAMs separate for when we store magnitude and phase data in them later. We assign both even and odd RAMs the same data, but enable the write only on the corresponding one.

Finally, after the RAM is full, we perform some initialization for the next state and move on to the _FFT_:

```lucid
state.CAPTURE:
  // set each channel's write address to addr.q (minus the LSB)
  ram.waddr = 7x{{2x{{addr.q[addr.WIDTH-1:1]}}}};
 
  if (new_sample_in) {
    // write each sample to RAM
    for (i = 0; i < 7; i++) {
      ram.write_data[i] = 2x{{sample_in[i]}};
      // write alternating samples to the upper and lower channels
      ram.write_en[i][addr.q[0]] = 1;
    }
 
    addr.d = addr.q + 1;
    // if all samples captured move on to next stage
    if (addr.q == SAMPLES - 1) {
      addr.d = 0;
      load_ch_ctr.d = 0;
      unload_ch_ctr.d = 0;
      wait_ram.d = 1;
      state.d = state.FFT;
    }
  }
```

#### FFT State

In this stage of the calculation, we have two processes going on. The first is responsible for keeping the FFT feed, and the second is for writing the result from the CORDIC into RAM. The FFT feeds directly into the CORDIC.

The feeding process requires a little finesse, because reading from the RAM takes a clock cycle. The flag _wait_ram_ is used to ensure that the RAM is outputting the value for address 0 when we start. If at any point the FFT can't accept more data but we are feeding it data, we'll need to save the value that is coming out of the RAM because on the next cycle it will be gone. When resuming feeding data into the FFT, we then feed it the saved value before resuming reading from the RAM.

Before feeding the FFT, we also pass the data through a Hanning window. The Hann ROM has a single-cycle latency like the RAM, so we also need to save its value if the FFT can't accept values. The Hann value and microphone sample are multiplied together. The Hann value is a 1.15 fixed-point number (1 integer bit, 15 decimal bits), so the result of the multiplication is shifted 15 bits to the right before being passed to the FFT. The idea is the same as if you were multiplying two decimal numbers. For example, 2 x 1.3 can be looked at as (2 x 13) / 10. Note that the multiplication should be a signed multiplication, so both operands are wrapped by the _$signed_ function to ensure this.

Once we've filled the FFT, we increment the channel and wait for the FFT to be ready to accept more data. After all seven channels have been loaded, we wait for the state to change:

```lucid
state.FFT:
  // read from addr.q minus LSB
  ram.raddr = 7x{{2x{{addr.q[addr.WIDTH-1:1]}}}};
 
  // only load the seven channels
  if (load_ch_ctr.q < 7) {
    // if we have to wait for the RAM to catch up
    if (wait_ram.q) {
       wait_ram.d = 0;      // reset flag
      addr.d = addr.q + 1; // increment address
    } else {
      // if the fft was ready but now isn't we need to save the
      // output from the RAM for when the FFT is ready
      if (xfft_ready.q && !xfft.s_axis_data_tready) {
        last_value.d = ram.read_data[load_ch_ctr.q][addr.q[0]];
        last_hann.d = hann.value;
      }
 
      // if the FFT is ready to accept data
      if (xfft.s_axis_data_tready) {
        // if the FFT was ready last cycle use the RAM output directly,
        // otherwise use the saved value
        sample = xfft_ready.q ?
          ram.read_data[load_ch_ctr.q][addr.q[0]] : last_value.q;
        hann_value = xfft_ready.q ? hann.value : last_hann.q;
 
        // multiply each sample by the HANN window
        mult_temp = $signed(sample) * $signed(c{1b0,hann_value});
        hann_sample = mult_temp[15+:16];
        // imaginary part of FFT is 0
        xfft.s_axis_data_tdata = c{16b0, hann_sample};
        xfft.s_axis_data_tvalid = 1;
        addr.d = addr.q + 1;
 
        // addr.q will be 0 if the fft was stalled when waiting for the
        // last sample
 
        // if we've read all the samples
        if ((addr.q == SAMPLES - 1 && !xfft_ready.q) || addr.q == 0) {
          xfft.s_axis_data_tlast = 1;
          addr.d = 0;
          wait_ram.d = 1; // wait for RAM to read addr 0
          load_ch_ctr.d = load_ch_ctr.q + 1;
        }
      }
    }
  }
```

We need to connect the FFT output to the CORDIC to get the magnitude-angle representation. The CORDIC conveniently lets us pass the address and last flag through it so that it stays in sync with the other data. The _tready_ and _tvalid_ handshaking flags ensure that data is transferred only when there is data and the CORDIC can accept it:

```lucid
xfft.m_axis_data_tready = mag_phase.s_axis_cartesian_tready;
mag_phase.s_axis_cartesian_tdata = xfft.m_axis_data_tdata;
mag_phase.s_axis_cartesian_tvalid = xfft.m_axis_data_tvalid;
 
// pass the address info through the user channel so it is available
// when the mag_phase data has been processed
mag_phase.s_axis_cartesian_tuser = xfft.m_axis_data_tuser[addr.WIDTH-1:0];
mag_phase.s_axis_cartesian_tlast = xfft.m_axis_data_tlast;
```

Finally, we need to unload the CORDIC data into the RAM. We have the address to write from the _tuser_ field, and we keep track of the channel number by counting the _tlast_ flags.

After we have unloaded the last of the data from the last channel, we can change to the next state, _DIFFERENCE_:

```lucid
// recover the address from the user channel
ram.waddr = 
  7x{{2x{{mag_phase.m_axis_dout_tuser[addr.WIDTH-2:0]}}}};
ram.write_en[unload_ch_ctr.q] =
  2x{mag_phase.m_axis_dout_tvalid
  // write only first half of values
  & ~mag_phase.m_axis_dout_tuser[addr.WIDTH-1]};
ram.write_data[unload_ch_ctr.q] =
  // phase, mag
  {mag_phase.m_axis_dout_tdata[31:16], mag_phase.m_axis_dout_tdata[15:0]}; 
 
// if we have processed all the samples we need to
if (mag_phase.m_axis_dout_tvalid && mag_phase.m_axis_dout_tlast) {
  unload_ch_ctr.d = unload_ch_ctr.q + 1;   // move onto the next channel
  // if we have processed all 7 channels
  if (unload_ch_ctr.q == 6) {
    state.d = state.DIFFERENCE;            // move to the next stage
    addr_pipe.d = 2x{{addr.WIDTHx{1b0}}};
  }
}
```

#### DIFFERENCE State

In this stage, we subtract the phase of the center microphone from each of the six outer microphones. We then use this difference to scale the microphone's location vectors and then sum the vectors. The single resulting vector is fed through the CORDIC to get its angle, which is then written back to RAM.

The first operation that takes place is the subtraction of the phases. The only interesting part here is that we need to keep the resulting differences in the +/– pi range. This is done by checking for overflow and adding or subtracting 2pi. All the operations here are intended to be signed, so everything is wrapped in _$signed_ again to ensure this:

```lucid
state.DIFFERENCE:
  for (i = 0; i < 6; i++) {
    // we care about the difference in phase between the center microphone
    // and the outer microphones
    // as this is proportional to the delay of the sound (divided by the
    // frequency)
    temp_phase[i] =
      $signed(ram.read_data[i][1]) - $signed(ram.read_data[6][1]);
 
    // we need to keep the difference in the +/- pi range for the next
    // steps
 
    // 25736 = pi (4.13 fixed point)
    if ($signed(temp_phase[i]) > $signed(16d25736)) {
      // 51472 = 2*pi (4.13 fixed point)
        temp_phase[i] = $signed(temp_phase[i]) - $signed(17d51472);
      } else if ($signed(temp_phase[i]) < $signed(-16d25736)) {
        temp_phase[i] = $signed(temp_phase[i]) + $signed(17d51472);
      }
    }
```

Because of all the multiplications, the scaling of the vectors and summing them happens over two clock cycles. This adds a little bit of complexity: because the CORDIC can tell us it can't accept new data at any time, we need to be able to stall the pipeline.

To do this, we detect the specific case when pipeline data would be lost and revert to the dropped address. The only time this can happen is if the pipeline has been active for at least two cycles before being halted. This method can cause some values to be calculated more than once, depending on the halt/resume patterns, but this isn't a big deal as long as every value is calculated at least once and we continue to make progress. The worst-case pattern would be run, run, halt, run, run, halt, and so on. In this case, we would advance only one address per run, run, halt cycle. However, we would still make progress and cover all the values. The actual behavior of the CORDIC will have many more halts between a single run, and with this pattern we don't repeat any values.

Some of the scaling is really simple; for example, the first microphone is at (–1, 0), so the x value is just the negated phase difference, and the y component is always 0. However, some require multiplying by sqrt(3)/2. This is done using fixed-point multiplication and a bit shift.

With all the scaled phase values calculated, they are summed and then divided by 8, which is the closest power of 2 greater than 6 (the number of microphones). The division is used to keep the values in a 16-bit range:

```lucid,short
/* Sample coordinates
   0: (-1,    0)
   1: (-1/2,  sqrt(3)/2)
   2: ( 1/2,  sqrt(3)/2)
   3: ( 1     0)
   4: ( 1/2, -sqrt(3)/2)
   5: (-1/2, -sqrt(3)/2)
   6: ( 0,    0)
*/
 
addr_pipe.d[0] = addr.q; // output address of the ram
 
if (mag_phase.s_axis_cartesian_tready) {
  /*
     Here we are scaling each microphone's location vector by
     he delay (phase difference). This will give us a vector
     roportional to that microphone's contribution to the total
     direction.
  */
  scaled_phase.d[0][0] = -temp_phase[0];
  scaled_phase.d[0][1] = 0;
 
  mult_temp = -temp_phase[1];
  scaled_phase.d[1][0] = c{mult_temp[16],mult_temp[16:1]};
 
  mult_temp = $signed(temp_phase[1]) * $signed(17d56756);
  // phase * sqrt(3)/2
  scaled_phase.d[1][1] = mult_temp[mult_temp.WIDTH-2:16];
 
  scaled_phase.d[2][0] = c{temp_phase[2][16], temp_phase[2][16:1]};
 
  mult_temp = $signed(temp_phase[2]) * $signed(17d56756);
  scaled_phase.d[2][1] = mult_temp[mult_temp.WIDTH-2:16];
 
  scaled_phase.d[3][0] = temp_phase[3];
  scaled_phase.d[3][1] = 0;
 
  scaled_phase.d[4][0] = c{temp_phase[4][16], temp_phase[4][16:1]};
 
  mult_temp = $signed(temp_phase[4]) * $signed(-17d56756);
  scaled_phase.d[4][1] = mult_temp[mult_temp.WIDTH-2:16];
 
  mult_temp = -temp_phase[5];
  scaled_phase.d[5][0] = c{mult_temp[16], mult_temp[16:1]};
 
  mult_temp = $signed(temp_phase[5]) * $signed(-17d56756);
  scaled_phase.d[5][1] = mult_temp[mult_temp.WIDTH-2:16];
 
  addr_pipe.d[1] = addr_pipe.q[0]; // address of scaled vector values
 
  /*
     With all the scaled vectors, we simply need to sum them to get
     the overall direction of sound for this frequency.
  */
  summed_phase[0] = 0;
  summed_phase[1] = 0;
  for (i = 0; i < 6; i++) {
    summed_phase[0] = $signed(scaled_phase.q[i][0]) +
      $signed(summed_phase[0]);
    summed_phase[1] = $signed(scaled_phase.q[i][1]) +
      $signed(summed_phase[1]);
  }
 
  // if there are more samples to go, advance the addr
  if (addr.q != SAMPLES/2)
    addr.d = addr.q + 1;
 
  // use the summed vectors (divided by 8) to calculate the overall
  // direction of sound
  mag_phase.s_axis_cartesian_tdata =
    c{summed_phase[1][3+:16], summed_phase[0][3+:16]};
  // only valid for the first half of addr
  mag_phase.s_axis_cartesian_tvalid = ~addr_pipe.q[1][addr.WIDTH-1];
 
  // feed in the address for later use
  mag_phase.s_axis_cartesian_tuser = addr_pipe.q[1];
  mag_phase.s_axis_cartesian_tlast = addr_pipe.q[1] == SAMPLES/2 - 1;
 
} else if (&mag_phase_ready.q) {
  // if we were ready but now aren't we need to go back an address so
  // that we don't skip one
  addr.d = addr_pipe.q[0];
}
```

We now just need to feed the output of the CORDIC back into the RAM. This is basically the same as the last part of the _FFT_ state:

```lucid
// write the phase data into the RAM channel 0
ram.waddr = 7x{{2x{{mag_phase.m_axis_dout_tuser[addr.WIDTH-2:0]}}}};
ram.write_data[0] =
  {mag_phase.m_axis_dout_tdata[31:16], mag_phase.m_axis_dout_tdata[15:0]};
ram.write_en[0] = 2x{mag_phase.m_axis_dout_tvalid};
 
// if we are on the last sample move onto the next stage
if (mag_phase.m_axis_dout_tlast && mag_phase.m_axis_dout_tvalid) {
  addr.d = CROP_MIN;
  state.d = state.AGGREGATE_WAIT;
}
```

#### AGGREGATE State

In this stage, we will run through the calculated directions and sum their corresponding magnitudes into 16 directional bins.

Even though we have 256 frequencies to work with, we will be summing only the ones between 9 and 199. The lowest frequencies aren't too useful, and the highest ones get out of hearing range. These values are set by _CROP_MIN_ and _CROP_MAX_.

The bin selection is performed with a series of _if_ statements that check whether the angle lies in a particular bin's range. Only the 8 MSBs are used to save on the size of the comparisons. It doesn't make a difference if the bin boundaries aren't perfectly precise. These comparisons are all signed, so the constants are wrapped in _\$signed_. The signal _angle_ is declared as _signed_, so the _\$signed_ function isn't required:

```lucid,short
state.AGGREGATE:
  addr.d = addr.q + 1;
  angle = ram.read_data[0][1][15:8]; // angle calculated in the last step
  magnitude = ram.read_data[6][0];   // use the magnitude from the center mic
 
  /*
     We now need to go through each frequency and bin them into one of 16 groups.
     This makes it easier to get an idea of where the sound is coming from as
     many frequencies will point in the same direction of a single source. If
     we have multiple sources then multiple bins will receive a lot of values.
     A more advanced grouping method could be done in software off chip such as
     K-means to get a more accurate picture, but this method works relatively well
     and is simple to implement in hardware.
  */
  if (angle >= $signed(ANGLE_BOUNDS[7]) || angle < $signed(-ANGLE_BOUNDS[7])) {
    sums.d[0] = sums.q[0] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[6]) && angle < $signed(ANGLE_BOUNDS[7])) {
    sums.d[1] = sums.q[1] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[5]) && angle < $signed(ANGLE_BOUNDS[6])) {
    sums.d[2] = sums.q[2] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[4]) && angle < $signed(ANGLE_BOUNDS[5])) {
    sums.d[3] = sums.q[3] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[3]) && angle < $signed(ANGLE_BOUNDS[4])) {
    sums.d[4] = sums.q[4] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[2]) && angle < $signed(ANGLE_BOUNDS[3])) {
    sums.d[5] = sums.q[5] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[1]) && angle < $signed(ANGLE_BOUNDS[2])) {
    sums.d[6] = sums.q[6] + magnitude;
  } else if (angle >= $signed(ANGLE_BOUNDS[0]) && angle < $signed(ANGLE_BOUNDS[1])) {
    sums.d[7] = sums.q[7] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[0]) && angle < $signed(ANGLE_BOUNDS[0])) {
    sums.d[8] = sums.q[8] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[1]) && angle < $signed(-ANGLE_BOUNDS[0])) {
    sums.d[9] = sums.q[9] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[2]) && angle < $signed(-ANGLE_BOUNDS[1])) {
    sums.d[10] = sums.q[10] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[3]) && angle < $signed(-ANGLE_BOUNDS[2])) {
    sums.d[11] = sums.q[11] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[4]) && angle < $signed(-ANGLE_BOUNDS[3])) {
    sums.d[12] = sums.q[12] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[5]) && angle < $signed(-ANGLE_BOUNDS[4])) {
    sums.d[13] = sums.q[13] + magnitude;
  } else if (angle >= $signed(-ANGLE_BOUNDS[6]) && angle < $signed(-ANGLE_BOUNDS[5])) {
    sums.d[14] = sums.q[14] + magnitude;
  } else {
    sums.d[15] = sums.q[15] + magnitude;
  }
 
  // stop once we reach the highest frequency to count (we only care about audible ones)
  if (addr.q == CROP_MAX)
    state.d = state.OUTPUT;
```

Finally, with the different bins full, we can output the values. We first check for overflow and saturate the bin if it did.

Upon completion, we return to idle and wait for the command to start the process all over again:

```lucid
state.OUTPUT:
  for (i = 0; i < 16; i++) {
    sum = sums.q[i][sums.q.WIDTH[1]-1:0];
    if (sum > 65535) // if it overflowed, saturate it
      sum = 65535;
 
    result[i] = sum[15:0]; // use the 16 LSBs for decent sensitivity
  }
  result_valid = 1;
 
  state.d = state.IDLE;
```

This project is a fairly complicated example, but hopefully it gives you an idea of some of the interesting things you can do with an FPGA.