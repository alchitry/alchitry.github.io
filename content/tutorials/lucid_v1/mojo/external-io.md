+++
title = "External IO"
weight = 6
+++

This tutorial will cover how to connect your design to the IO pins on the Mojo as well as some of the dangers that can arise when interfacing your digital design with the external world.

# The Button Counter

To demonstrate these principles, we will hook up an external button to the FPGA. Each time the button is pressed we will increment a counter. The counter can then be displayed on the LEDs so we can see each time a button press is registered.

# Hooking up a Button

First we need a button to connect! Above is a picture of the button I am going to use. Pretty much any momentary switch will work.

![Button](https://cdn.alchitry.com/lucid_v1/mojo/button.jpg)

We now need to connect it to the Mojo. We simply need to connect one side of the button to ground and the other to any pin on the Mojo. The FPGA has configurable internal pull-up and pull-down resistors so we don't need an external pull-up. I like this particular button because it fits nicely in the header. I put one pin into ground and the other to P51. Like I said before, you don't need to use P51, you just need to make note of which pin you choose.

# Adding the Button to the Top Level

Make a new project based on the Base Project. We now need to add our new button input to mojo_top. Remember, the inputs and outputs of this module are the inputs and outputs of the FPGA.

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
    input button            // Super cool button!
  ) {
```

Note that I had to add a comma after avr_rx_busy.

# The User Constraints File

OK so now we have the button signal in our design, but how do the tools know what pin to connect button to? This is where the User Constraints File, or UCF, comes into play.

Under the Constraints heading in the left panel of the Mojo IDE, open the mojo.ucf file.

```ucf
NET "clk" TNM_NET = clk;
TIMESPEC TS_clk = PERIOD "clk" 50 MHz HIGH 50%;
 
NET "clk" LOC = P56 | IOSTANDARD = LVTTL;
NET "rst_n" LOC = P38 | IOSTANDARD = LVTTL;
 
NET "cclk" LOC = P70 | IOSTANDARD = LVTTL;
 
NET "led<0>" LOC = P134 | IOSTANDARD = LVTTL;
NET "led<1>" LOC = P133 | IOSTANDARD = LVTTL;
NET "led<2>" LOC = P132 | IOSTANDARD = LVTTL;
NET "led<3>" LOC = P131 | IOSTANDARD = LVTTL;
NET "led<4>" LOC = P127 | IOSTANDARD = LVTTL;
NET "led<5>" LOC = P126 | IOSTANDARD = LVTTL;
NET "led<6>" LOC = P124 | IOSTANDARD = LVTTL;
NET "led<7>" LOC = P123 | IOSTANDARD = LVTTL;
 
NET "spi_mosi" LOC = P44 | IOSTANDARD = LVTTL;
NET "spi_miso" LOC = P45 | IOSTANDARD = LVTTL;
NET "spi_ss" LOC = P48 | IOSTANDARD = LVTTL;
NET "spi_sck" LOC = P43 | IOSTANDARD = LVTTL;
NET "spi_channel<0>" LOC = P46 | IOSTANDARD = LVTTL;
NET "spi_channel<1>" LOC = P61 | IOSTANDARD = LVTTL;
NET "spi_channel<2>" LOC = P62 | IOSTANDARD = LVTTL;
NET "spi_channel<3>" LOC = P65 | IOSTANDARD = LVTTL;
 
NET "avr_tx" LOC = P55 | IOSTANDARD = LVTTL;
NET "avr_rx" LOC = P59 | IOSTANDARD = LVTTL;
NET "avr_rx_busy" LOC = P39 | IOSTANDARD = LVTTL;
```

Here are all the definitions of all the predefined pins! Also note the first two lines define the parameters for the clock so the tools know what your design needs to handle.

The IOSTANDARD specifies what standard the pin will operate at. Since all the IO pins on the Mojo are powered with 3.3V, LVTTL and CMOS33 are the only valid options for singled ended signals. These standards define what should be considered a 1 and what should be a 0. These two are more or less the same, with a 1 being 3.3v and 0 being 0v (or roughly these levels), but you can only use one type per IO bank, so stick with LVTTL. If you are really curious about the different standards check out this document from Xilinx (IO standards start at page 24), but be warned, it's pretty thick.

The mojo.ucf file is part of the component library so it can't be edited. To add our own pin definitions, we need to add a new constraints file. Click the new file icon (left-most icon in the toolbar) and create a new User Constraints file called custom.ucf.

Now we need to add the following line to the the file for the button.

```ucf
NET "button" LOC = P51 | IOSTANDARD = LVTTL | PULLUP;
```

The NET name, "button", must match the name of the signal of the top level module. Here I set the location (LOC) to P51 which is the pin I chose to connect the button to. If you chose a different pin, use that instead.

Notice at the end there is the extra PULLUP parameter. This tells the tools we want the internal pull-up resistor to be used on the pin. You can also specify PULLDOWN to use a pull-down resistor.

That's all there is to adding a new signal! Just to make sure it's all working properly let's modify mojo_top.luc and connect the button the LEDs.

```lucid
led = 8x{button};       // connect the button
```

Build and load your project to your Mojo. When you aren't pushing the button the LEDs should be on. When it's pressed the LEDs should turn off.

# The Counter

We can now write out module that takes the button input and counts how many times it has been pressed.

```lucid
module counter (
    input clk,       // clock
    input rst,       // reset
    input button,    // button input
    output count[8]  // press counter
  ) {
 
  .clk(clk) {
    edge_detector edge_detector(#RISE(1), #FALL(0)); // detect rising edges
 
    .rst(rst) {
       dff ctr[8]; // our lovely counter
    }
  }
 
  always {
    edge_detector.in = button; // input to the edge_detector
    count = ctr.q;             // output the counter
 
    if (edge_detector.out)     // if edge detected
      ctr.d = ctr.q + 1;       // add one to the counter
  }
}
```

This module is making use of the edge_detector component so make sure you add that to your project (it's under Miscellaneous). The edge_detector is pretty simple and you should take a look at the source. To use it, we need to specify what types of edges we are interested in. In our case, we only care about the rising edge so we set RISE to 1 and FALL to 0. This means that every time there is a rising edge on edge_detector.in, edge_detector.out will be 1 for a single clock cycle.

With the edge detector, we only then need to increment our counter each time an edge is detected.

Finally, add this to mojo_top and connect the output to the LEDs.

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
    input button            // Super cool button!
  ) {
 
  sig rst;                  // reset signal
 
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst){
      counter counter;
    }
  }
 
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
 
    spi_miso = bz;          // not using SPI
    spi_channel = bzzzz;    // not using flags
    avr_rx = bz;            // not using serial port
 
    counter.button = ~button; // make button active high
    led = counter.count;
  }
}
```

Build and load it onto your Mojo. Try pressing the button and observing what happens. Is it counting exactly once per press? Chances are many presses will register as multiple presses. In my case it wasn't uncommon for a single press to be counted as high as eight times!

This happens because the button bounces and each bounce will be counted as a press. But before we get to fixing that, we run into another problem.

# Metastability

To understand metastability, you first need a little background on the timing requirements of the flip-flop. As we discussed before, a flip-flop will copy the value at the D side to the Q side at the positive edge of the clock and hold the value steady until the next positive edge. What we didn't cover was what is known as the setup and hold timing constraints.

This tutorial will not go into too much detail on what causes these constraints and what their actual values are. All that is important right now is to know that the setup constraint tells you how long before the positive edge must the value on the D side be stable. The hold time tells you how long after the positive edge the D side must continue to be stable.

Here is a diagram illustrating this.

![Setup and hold diagram](https://cdn.alchitry.com/lucid_v1/mojo/metastability.png)

The areas that D needs to be constant are shaded in gray on the clock. As you can see the setup time specifies the time before the rising edge and the hold time is the time after the rising edge.

The D and the Q signals under the clock are an example of what could happen. The first two rising edges are valid since during the setup and hold time D is constant. For the last edge D changes when it shouldn't so the value of Q becomes unknown.

Q may take a random value of 0 or 1, however, that is the best case. There is also a possibility that Q will get stuck somewhere between 0 and 1 (0.5?!?), or worse yet it may oscillate, flipping between 0 and 1 very rapidly.

As you may have guessed you don't want any of that to happen. Bad things will happen and your circuit will do unexpected things.

There are two solutions to this problem.

First, you can just design your circuit so this never happens! This is exactly what the tools do for you when you build your design. If it can't meet timing for some reason you'll get timing errors. If you are just running the Mojo at 50MHz, you probably won't encounter these unless you do multiple multiplications between flip flops or some other complicated computational logic. This will be covered more in later tutorials.

As you may have realized, sometimes you can't control when a signal will change. For this tutorial we are using a button. It's impossible for us to guarantee that the button won't be pressed and violate the setup and hold constraints.

The second solution is to then to use not one but two flip-flops!

![Flip-flop chain](https://cdn.alchitry.com/lucid_v1/mojo/metastability-dualff.png)

This will add a small amount of latency to your input signal, but it significantly reduces the chance that you will encounter metastability problems. This is the solution we will use to read the button reliably.

It is important to note that this does not solve the metastability problem and there is still a small chance you could have problems. However, using two flip-flops drastically reduces that chance. If you are really worried about a certain input, you can chain more flip-flops together for a smaller chance of stability issues. However, there are diminishing returns and two will be plenty for most cases.

# Debouncing

When you press a button, there is a chance that the button will not simply go from open to closed. Since a button is a mechanical device the contacts can bounce. When a button bounces the value it produces looks something like this.

![Button bounce](https://cdn.alchitry.com/lucid_v1/mojo/bouncing.png)

For a short period after the button is pressed the value you read from an IO pin may toggle between 0 and 1 a few times before settling on the actual value. This is where debouncing comes into play.

To debounce a button, you just need to require that for a button to register as being pressed, it must look like it's being pressed for a set amount of time. In this case, being pressed is when the value of the button is 0. If you read enough 0's in a row it is safe to assume that the button has stopped bouncing and you can register one button press.

If you fail to do this and you are using the button to increment a counter, then the counter may increase by more than 1 per button press since it will appear that each bounce was a separate press. Just as we saw before.

Conveniently, there is a component under Miscellaneous called Button Conditioner that we can use to fix these problems.

```lucid
module button_conditioner #(
    CLK_FREQ = 50000000 : CLK_FREQ > 0, // clock frequency
    MIN_DELAY = 20 : MIN_DELAY > 0,     // minimum delay in ms
    NUM_SYNC = 2 : NUM_SYNC > 1         // number of sync flip flops
  )(
    input clk, // clock
    input in,  // button in (active high)
    output out // output
  ) {
 
  .clk(clk) {
    pipeline sync(#DEPTH(NUM_SYNC)); // synchronizing chain
 
    // CLK_FREQ * MIN_DELAY / 1000 = clock cycles for MIN_DELAY milliseconds
    dff ctr[$clog2(CLK_FREQ * MIN_DELAY / 1000)];
  }
 
  always {
    sync.in = in;
    out = &ctr.q;        // output 1 when ctr is full
 
    if (!&ctr.q)         // if counter isn't full
      ctr.d = ctr.q + 1; // increment it
 
    if (!sync.out)       // if button is low
      ctr.d = 0;         // reset the counter
  }
}
```

This component works by taking a button press and passing it through two (or more) flip-flops to prevent stability issues. This happens in the pipeline component which is just a string of connected flip-flops of length DEPTH. With the synchronized signal, a counter is incremented when the button is pressed and reset when it isn't. The counter will saturate at it's max value. Once it hit's the max value it is safe to say the the button has been pressed and the output changes to 1.

By using the button_conditioner module you can be sure that you will be able to reliably read button presses.

# Putting It All Together

We now have all the parts we need to reliably count the number of times the button is pressed.

The only change we need to make is to add the button conditioner to counter.

```lucid
module counter (
    input clk,       // clock
    input rst,       // reset
    input button,    // button input
    output count[8]  // press counter
  ) {
 
  .clk(clk) {
    edge_detector edge_detector(#RISE(1), #FALL(0)); // detect rising edges
 
    button_conditioner button_cond;     // button input conditioner
 
    .rst(rst) {
       dff ctr[8]; // our lovely counter
    }
  }
 
  always {
    button_cond.in = button;            // raw button input
    edge_detector.in = button_cond.out; // input to the edge_detector
    count = ctr.q;                      // output the counter
 
    if (edge_detector.out)              // if edge detected
      ctr.d = ctr.q + 1;                // add one to the counter
  }
}
```

Build and load your project for the last time. When you push the button now, the counter should only increase by one each time!

If you have other external inputs that aren't synchronized to the Mojo's clock, you can use the pipeline component to synchronize them. This component will create a chain of flip-flops for you and the length of the chain is parameterizable.

That's it for this tutorial. You should now be able to connect your Mojo to whatever you want!