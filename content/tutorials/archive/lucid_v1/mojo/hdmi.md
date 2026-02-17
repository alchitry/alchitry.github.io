+++
title = "HDMI"
weight = 13
aliases = ["tutorials/lucid_v1/mojo/hdmi.md"]
+++

This tutorial covers the basis of using the HDMI Shield. There are a few components bundled in the Mojo IDE that make encoding and decoding HDMI streams easier. This tutorial gives a basic example for each one.

### The HDMI Shield

![dsc_4259-edit_large.jpg](https://cdn.alchitry.com/lucid_v1/mojo/dsc_4259-edit_large.jpg)

This tutorial assumes you are using the HDMI Shield in its default configuration. Out of the box, the HDMI Shield is setup so that the port labeled _HDMI 1_ is a _source_ (output) and _HDMI 2_ is a _sink_ (input). It is possible to change these via solder jumpers.

### TMDS

_TMDS,_ or **T**ransition **M**inimized **D**ifferential **S**ignaling, is a type of differential signaling that encodes each byte sent into 10 bits so that the number of edges (transitions from 0->1 or 1->0) are minimized to reduce noise and increase signal integrity.

The details of TMDS aren't really important for this tutorial. However, if you are curious, [Wikipedia](https://en.wikipedia.org/wiki/Transition-minimized_differential_signaling) does a good job at outlining the details.

### HDMI Encoding

Any projects that incorporate HDMI are going to have slightly complicated clocking. Even in the simplest case of just encoding HDMI data three different clock frequencies are required. These frequencies are synthesized for you in the HDMI components.

The _HDMI Encoder_ component requires an input clock to synthesize three new clocks. The _pixel clock_ is the frequency of the input clock divided between 1 and 12. The other two clocks are 10x and 2x the pixel clock frequency. These are used to clock out the actual bits. The data for each pixel is 24 bits split across three channels (red, green, blue). The eight bits for each color are converted to 10 bits of TMDS data. These bits are clocked out at 10x the pixel clock. The 2x clock is used by the FPGA's special IO resources to clock data out this fast.

The Spartan 6 on the Mojo is capable of IO signals up to 945MHz which means a pixel clock of up to 94.5MHz. This is fast enough for 1080p@30Hz or 720p@60Hz.

Due to the way the FPGA is designed, the clock that is fed into the HDMI encoder can't be used for anything else. Instead you need to use the _pclk_ output of the component to clock the rest of your design. This is the clock that the HDMI data needs to be aligned with.

#### Choosing a Pixel Clock

Your pixel clock rate will depend on two things, the video resolution and framerate. The minimum pixel clock is simply _width x height x frames per second_. For example, 720p@60Hz is _1280 x 720 x 60 = 55296000 => ~55.3MHz_. However, this isn't the full story. The width and height of each frame needs padding for the vertical and horizontal sync signals. For for 720p@60Hz, the actual image size is something more _1667 x 750_ which makes for a pixel clock of 75MHz. The padding required is dependent on the device receiving the stream, however in my testing adding at least 15 to the height and 30 to the width seems to work with most devices.

You can play with the padding to get the pixel clock to be an easy to synthesize value (like the 75Mhz example).

As you are probably aware, the Mojo has a 50MHz clock input. To get a pixel clock suitable for your design you will likely need to synthesize it. Check out the [_Generating the Clock_](@/tutorials/archive/lucid_v1/mojo/sdram.md#generating-the-clock) section from the _SDRAM Tutorial_ for how to do this.

#### Generating a Stream

Now that clocking is out of the way, let's create a simple project that generates a simple test pattern.

Create a new project based on the _Base Project_.

Open the _Components Library_ and under _Video_ select the _HDMI Encoder_. We also need to add the UCF file for the HDMI Shield. Under _Constraints_ select _HDMI Shield_ and click _Add_.

Take a look at the module declaration.

```lucid
module hdmi_encoder #(
    PCLK_DIV = 1 : PCLK_DIV >= 1 && PCLK_DIV < 12,
    Y_RES = 720 : Y_RES > 0,
    X_RES = 1280 : X_RES > 0,
    Y_FRAME = 750 : Y_FRAME >= Y_RES + 15,
    X_FRAME = 1667 : X_FRAME >= X_RES + 30
  )(
    input clk,  // clock
    input rst,  // reset
    output pclk,
    output tmds[4],
    output tmdsb[4],
    output active,
    output x[11],
    output y[10],
    input red[8],
    input green[8],
    input blue[8]
  ) {
```

The interface to this module is pretty simple. The parameter _PCLK_DIV_ is used to divide the pixel clock by a value between 1 and 12. This is required when you need a pixel clock less than 19MHz. This minimum input frequency restriction is from the _PLL_BASE_ primitive that is used to synthesize the other clocks. For more information see page 98-116 (specifically page 101) of the Xilinx document [UG382](https://www.xilinx.com/support/documentation/user_guides/ug382.pdf) and page 57 of [DS162](https://www.xilinx.com/support/documentation/data_sheets/ds162.pdf).

The other parameters are used to define the stream's resolution. The _X/Y_FRAME_ parameters define the size of each frame while _X/Y_RES_ define the active image resolution.

The outputs _tmds_ and _tmdsb_ need to be connected directly to the HDMI output pins of the FPGA at the top level. These are the TMDS data streams and are four bits wide for the four channels, red, green, blue, and the clock.

The module supplies you with a few signals to help you supply the proper colors. The output _active_ tells you that it needs color data and the frame is in an active area. The outputs _x_ and _y_ tell you the pixel coordinate that is about to be sent out and being requested.

Your job is to simply take these three signals and generate the corresponding _red_, _green_, and _blue_ signals.

To start we will make a static frame where each pixel's color is a function of its location.

We will make a 720p@60Hz stream which means we need to generate a 75MHz clock.

Launch _CoreGen_ and the _Clocking Wizard_.

I unchecked _Phase alignment_ as it doesn't matter for our design.

Also change the _primary_ input clock frequency to 50MHz to match the Mojo's clock.

![Screenshot_from_2018-03-19_13-15-36.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2018-03-19_13-15-36.png)

On the next page, change the output frequency to 75MHz and click _Next_.

On page 3, uncheck _RESET_ and _LOCKED_ as we won't be using them.

You can now click _Generate_.

Once the core is generated it should show up in the Mojo IDE under the _Cores_ section in the project tree. You can close _Core Generator_ now.

We now have all the components ready. We need to instantiate the clock wizard and HDMI encoder, add the HDMI TMDS outputs, and wire everything up in _mojo_top_.

Adding the HDMI TMDS outputs is pretty straightforward. If you look in the _hdmi.ucf_ file we added before you will find the names of the defined signals we can add to _mojo_top_. For this project we are only using the _hdmi1_tmds_ and _hdmi1_tmdsb_ signals.

We simply add these two signals as four bit output arrays to the port list in _mojo_top_.

To instantiate the _clk_wiz_v3_6_ we simply need to hook up _clk_ to its _CLK_IN1_ input. The output _CLK_OUT1_ will be used to feed the clock of _hdmi_encoder_.

For _hdmi_encoder,_ we can connect _clk_wiz.CLK_OUT1_ to the _clk_ input and _0_ for the _rst_ input (we don't need a reset).

The output _hdmi.pclk_ is the clock we will use for the rest of the design. Change the port connection of _.clk(clk)_ to _.clk(hdmi.pclk)_.

Finally, we just need to connect values to the _red_, _green_, and _blue_ inputs of _hdmi_ and its _TMDS_ outputs to the corresponding ports.

For this demo I just used a function of the _x_ and _y_ outputs of _hdmi_ to make a static pattern.

Take a look at the full _mojo_top_.

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
    output hdmi1_tmds [4],  // HDMI 1 TMDS
    output hdmi1_tmdsb [4]  // HDMI 1 TMDSB
  ) {
 
  sig rst;                  // reset signal
 
  clk_wiz_v3_6 clk_wiz (.CLK_IN1(clk));
  hdmi_encoder hdmi (.clk(clk_wiz.CLK_OUT1), .rst(0));
 
  .clk(hdmi.pclk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    led = 8h00;             // turn LEDs off
    spi_miso = bz;          // not using SPI
    spi_channel = bzzzz;    // not using flags
    avr_rx = bz;            // not using serial port
 
    hdmi1_tmds = hdmi.tmds;   // connect the outputs
    hdmi1_tmdsb = hdmi.tmdsb;
 
    hdmi.red = hdmi.x[7:0];
    hdmi.green = hdmi.y[7:0];
    hdmi.blue = hdmi.x[7:0] ^ hdmi.y[7:0];
  }
}
```

You should now be able to build and load this design onto your Mojo. If you plug a monitor into _HDMI 1_ you should see the test pattern shown below.

![MVIMG_20180319_134603_large.jpg](https://cdn.alchitry.com/lucid_v1/mojo/MVIMG_20180319_134603_large.jpg)

If you don't see the pattern, You may need to use a different monitor/TV that supports 720p@60Hz or a different HDMI cable. In our testing, various cables didn't work all that reliably.

We can now modify the design a bit to make the pattern dynamic.

To do this we need some concept of time. A frame counter is probably the easiest way.

To check for the end of the frame, we just need to look for the max X and Y values. At 720p these are 1279 and 719. Also note that the coordinate outputs of the HDMI encoder are only valid when the _active_ signal is high so we also need to check for that.

The modified _mojo_top_ looks like this.

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
    output hdmi1_tmds [4],  // HDMI 1 TMDS
    output hdmi1_tmdsb [4]  // HDMI 1 TMDSB
  ) {
 
  sig rst;                  // reset signal
 
  clk_wiz_v3_6 clk_wiz (.CLK_IN1(clk));
  hdmi_encoder hdmi (.clk(clk_wiz.CLK_OUT1), .rst(0));
 
  .clk(hdmi.pclk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    dff frame[8];
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    led = 8h00;             // turn LEDs off
    spi_miso = bz;          // not using SPI
    spi_channel = bzzzz;    // not using flags
    avr_rx = bz;            // not using serial port
 
    hdmi1_tmds = hdmi.tmds;   // connect the outputs
    hdmi1_tmdsb = hdmi.tmdsb;
 
    hdmi.red = hdmi.x[7:0] + frame.q;
    hdmi.green = hdmi.y[7:0] + (frame.q << 1);
    hdmi.blue = hdmi.x[7:0] ^ hdmi.y[7:0];
 
    if (hdmi.x == 1279 && hdmi.y == 719 && hdmi.active) {
      frame.d = frame.q + 1;
    }
  }
}
```

Again you could use _frame.q_ in a different way to change the animation. Here is what this looks like.

![animation_b87f2f67-f787-446a-b35e-6c63ea53a57c.gif](https://cdn.alchitry.com/lucid_v1/mojo/animation_b87f2f67-f787-446a-b35e-6c63ea53a57c.gif)

### HDMI Decoding

HDMI decoding is pretty simple with the _HDMI Decoder_ component. With this component you simply connect the _tmds_ and _tmdsb_ inputs from the HDMI port and it will output the pixel data and a pixel clock. 

The one tricky part with receiving HDMI data is providing something known as the _EDID_ _ROM_. This is a ROM that contains data detailing about your design's capabilities. When you plug something into an HDMI port it will often read the ROM to make sure the HDMI stream it wants to send is supported. 

The details of the ROM format are outside the scope of this tutorial, but Wikipedia has a decent outline of it [here](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data).

There is a component in the Component Library that will make the Mojo show up as a 720p@60Hz monitor.

I don't have a good example project using just HDMI decoding but the next section will cover how to use the decoder and EDID ROM.

### HDMI Passthru

In this section we will use both ports on the HDMI Shield. _HDMI 2_ will act as an input and we will modify the stream then output it on _HDMI 1_. 

To get started, make a new project based on the _Base Project_.

Open the Components Library and add _HDMI Passthru_ and _EDID ROM_ from the _Video_ section. In the _Constraints_ section add the _HDMI Shield_ constraints.

We now need to create another constraint file to specify the max pixel clock we expect to see. Click the _New File_ icon and enter _hdmi_clock.ucf_ as the file name, select _User Constraints_ as the type, and click _Create File_.

Open this file and add the following line.

```ucf
NET "hdmi2_tmds(3)" PERIOD = 80 MHz HIGH 50%;
```

The fourth TMDS pair is the clock. When specifying a clock frequency for a differential pair, you only need to specify it for the positive side of the pair. In our case this is the signal _hdmi2_tmds(3)_. 

If we didn't add this constraint the tools wouldn't have any idea what timing specs to try and meet.

In _mojo_top_ we need to add the relevant HDMI signals to our port declaration. These consist of the two sets of TMDS pairs and the I2C signals for the EDID ROM.

We need to also instantiate the EDID ROM and HDMI Passthru components. The EDID ROM operates independently and we connect it to the main clock input on the Mojo. This is because we know this clock is always running but the pixel clock will only be running when there is a valid HDMI signal. When you plug in the HDMI port, the EDID ROM will be read before HDMI data is sent. If we tried to use the pixel clock, the ROM wouldn't be readable and the stream would never start.

We then need to connect the TMDS inputs and outputs from the _HDMI Passthru_ component to the top level ports. The only thing left is to connect up the pixel colors.

The _hdmi_passthru_ module outputs a pixel stream accompanied by the pixel's location and if it is active (valid). The module then accepts color data for pixels at a location delayed by the parameter _LATENCY_. By default this is set to 1. That means that you get one clock cycle to modify and supply the pixel color data.

In this first example we are simply going to mirror the stream. This means we need some _DFFs_ to store the color data for this single cycle.

Putting this all together we get a ﻿_mojo_top_﻿ module that looks like this.

```lucid,short
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
    output hdmi1_tmds [4],  // HDMI Out
    output hdmi1_tmdsb [4],
    input hdmi2_tmds [4],   // HDMI In
    input hdmi2_tmdsb [4],
    inout hdmi2_sda,        // EDID Interface
    input hdmi2_scl
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    // connect up the edid rom using a clock we know will alway be running
    edid_rom edid (.rst(rst), .sda(hdmi2_sda), .scl(hdmi2_scl));
  }
 
  hdmi_passthru hdmi (.rst(0)); // we don't care about the reset
 
  // use the pixel clock for the color data
  .clk(hdmi.pclk) {
    dff red[8];
    dff green[8];
    dff blue[8]; 
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    led = 8h00;             // turn LEDs off
    spi_miso = bz;          // not using SPI
    spi_channel = bzzzz;    // not using flags
    avr_rx = bz;            // not using serial port
 
    // connect HDMI input
    hdmi.tmds_in = hdmi2_tmds;
    hdmi.tmdsb_in = hdmi2_tmdsb;
 
    // connect HDMI output
    hdmi1_tmds = hdmi.tmds_out;
    hdmi1_tmdsb = hdmi.tmdsb_out;
 
    // save colors
    red.d = hdmi.red_out;
    green.d = hdmi.green_out;
    blue.d = hdmi.blue_out;
 
    // output colors
    hdmi.red_in = red.q;
    hdmi.green_in = green.q;
    hdmi.blue_in = blue.q;
  }
}
```

If you build and load the project now you should be able to plug _HDMI 2_ into an HDMI port on your computer.

![Screenshot_from_2018-03-21_13-21-30.png](https://cdn.alchitry.com/lucid_v1/mojo/Screenshot_from_2018-03-21_13-21-30.png)

In the previous image you can see the Mojo showing up on my computer as a 720p monitor.

If you plug a monitor into _HDMI 1_ then you should be able to use it as a 720p monitor.

We can have a little more fun than just mirroring the setup. Try swapping the color assignments around when outputting the stream.

```lucid
// output colors
hdmi.red_in = blue.q;
hdmi.green_in = red.q;
hdmi.blue_in = green.q;
```

If you build and load the design again the colors from whatever you put on the monitor will now be swapped.

![MVIMG_20180321_132846_large.jpg](https://cdn.alchitry.com/lucid_v1/mojo/MVIMG_20180321_132846_large.jpg)

Hey look Facebook is now red!

You can get more creative with how you modify the stream. Remember if you need more cycles to make your edits you can change the _LATENCY_ parameter.