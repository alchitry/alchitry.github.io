+++
title = "Pulse Width Modulation"
weight = 4
inline_language = "verilog"
+++

**P**ulse-**W**idth **M**odulation, or **PWM** is a very common technique that varies the width of the pulses in a pulse-train. PWM has a few applications, the main ones are for controlling things like servos and speed controllers and limiting the effective power for things like motors and LEDs. This tutorial will cover how to use PWM to change the brightness of an LED. 

### Pulse-Trains

A **pulse-train** is just the name given to a series of pulses that come after one another. A simple pulse train could look like this one.

![pulse_train.png](https://cdn.alchitry.com/verilog/mojo/pulse_train.png)

As time goes by the signal alternates between high (1) and low (0). Each pulse comes one after another in a very ordered fashion. In this example the pulse is high for 1/3 of the time. That means that the signal has a **duty cycle** of 33%. If the signal had a duty cycle of 50% then the signal would be high and low for equal amounts of time.

### Creating a Pulse-Train

In the [synchronous logic tutorial](@/tutorials/verilog/mojo/synchronous-logic.md) we created a circuit that could blinked an LED. What we really created was a circuit that created a pulse-train with a 50% duty cycle!  Because we used such a large counter the period (the time between the beginning of two pulses) was very long we could easily see the LED turn on and off.

What would happen if instead of using a 25 bit counter we used an 8 bit counter? The LED would blink at 50MHz / 2^8 = 195,313 Hz or 195,313 times per second. There is no way our eyes are fast enough to see it blink that fast. Since we can't see it blink what would it look like? It would not look like a whole lot, it would just appear to always be on! However, the interesting part is that since it is only on for half of the time our eye averages the light and the LED appears to be dimmer than if it was on the entire time!

I recommend you try modifying the code form that tutorial to have one LED blinking from an 8 bit counter and another LED always on so you can see the difference.

How does PWM play into all of this? As you may have guessed, by varying the duty cycle of the signal we can effectively control the brightness of the LED! With a 0% duty cycle the LED is off, with a 100% duty cycle the LED is full brightness, and by controlling the duty cycles we can reach any point in between.

When we were blinking the LED we used a simplification because we always wanted a 50% duty cycle. Instead of saying the LED should be on when the counter is greater than half its max value, we simply used the most significant bit. However, in the case where we want to create a signal with an arbitrary duty cycle we need to be able to control the value we are comparing the counter to.

Here is an example where we want to create the same 33% duty cycle signal shown before.

![](https://cdn.alchitry.com/verilog/mojo/pwm_33.png)

The graph on the bottom is the value of our counter over time. You can see the **Compare** value is set to 1/3 of the **Max** value. If we output a 1 whenever the value of the counter is less than **Compare** and a 0 otherwise you can see we create a pulse-train with a 33% duty cycle!

Now if we want to change the duty cycle of our signal all we need to do is vary the value of **Compare** and everything will take care of itself. Here's another example, but now with a 66% duty cycle.

![pwm_66.png](https://cdn.alchitry.com/verilog/mojo/pwm_66.png)

You can see that by simply raising the value of **Compare** to 2/3 of **Max** our duty cycle became 66%!

To implement this in Verilog is pretty simple and only requires a few modifications to the blinker code.

```verilog
module pwm #(parameter CTR_LEN = 8) (
    input clk,
    input rst,
    input [CTR_LEN - 1 : 0] compare,
    output pwm
  );
 
  reg pwm_d, pwm_q;
  reg [CTR_LEN - 1: 0] ctr_d, ctr_q;
 
  assign pwm = pwm_q;
 
  always @(*) begin
    ctr_d = ctr_q + 1'b1;
 
    if (compare > ctr_q)
      pwm_d = 1'b1;
    else
      pwm_d = 1'b0;
  end
 
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
    end
 
    pwm_q <= pwm_d;
  end
 
endmodule
```

Let's put this all together in a project. Make sure you've downloaded the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip) to work from. Create a new source file called PWM.v and add the contents of the code above.

### Parameters

This code has something new, the **parameter**. Parameters are constants that are used to configure the behavior of a module when your code is synthesized. These are useful for making generic modules that can be reused.

Parameters are declared before the IO ports by using the #( ... ) syntax. You can list as many parameters as you like by separating them with commas. If you assign a parameter a value, like we did in this example, then that is the default value and will be used if a value isn't specified when the module is instantiated. 

### Instantiating the module

Just like before, since we added a new module, we need to instantiate it in the **mojo_top.v** file. 

For this example we are going to instantiate 8 PWM modules and give each one a different constant compare value. That way we should get each of the LEDs on the Mojo to be at a different brightness.

```verilog,short
module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  pwm #(.CTR_LEN(3)) pwm_1 (
    .rst(rst),
    .clk(clk),
    .compare(3'd0),
    .pwm(led[0])
  );
 
  pwm #(.CTR_LEN(3)) pwm_2 (
    .rst(rst),
    .clk(clk),
    .compare(3'd1),
    .pwm(led[1])
  );
 
  pwm #(.CTR_LEN(3)) pwm_3 (
    .rst(rst),
    .clk(clk),
    .compare(3'd2),
    .pwm(led[2])
  );
 
  pwm #(.CTR_LEN(3)) pwm_4 (
    .rst(rst),
    .clk(clk),
    .compare(3'd3),
    .pwm(led[3])
  );
 
  pwm #(.CTR_LEN(3)) pwm_5 (
    .rst(rst),
    .clk(clk),
    .compare(3'd4),
    .pwm(led[4])
  );
 
  pwm #(.CTR_LEN(3)) pwm_6 (
    .rst(rst),
    .clk(clk),
    .compare(3'd5),
    .pwm(led[5])
  );
 
  pwm #(.CTR_LEN(3)) pwm_7 (
    .rst(rst),
    .clk(clk),
    .compare(3'd6),
    .pwm(led[6])
  );
 
  pwm #(.CTR_LEN(3)) pwm_8 (
    .rst(rst),
    .clk(clk),
    .compare(3'd7),
    .pwm(led[7])
  );
 
endmodule
```

For this example we set **CTR_LEN** to be 3 because we only need 8 different brightness values. For whatever reason, when you instantiate the module the parameters come _before_ the name of the instance. 

Go ahead and synthesize the code in ISE and load it onto your Mojo. You should see the top LED is max brightness and each one under it is slightly dimmer. 

### For Generate Loops

Sometimes when you want to instantiate a bunch of the same thing it is much easier to use a special type of for loop, called the **for generate** loop. If we rewrite our code above using a for generate loop it will look like this.

```verilog
module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  genvar i;
  generate
    for (i = 0; i < 8; i=i+1) begin: pwm_gen_loop
    pwm #(.CTR_LEN(3)) pwm (
      .rst(rst),
      .clk(clk),
      .compare(i),
      .pwm(led[i])
    );
    end
  endgenerate
 
endmodule
```

This is so much cleaner!

It is important to remember that all the numbers used for the for loop must be constants since the synthesizer needs to be able to figure out exactly how many times to duplicate the PWM module in hardware! In this case we get 8 copies of the same circuit in our design.

The tag **pwm_gen_loop** is the name of the for loop. When working with generate statements you need to give the loop a name. It uses that name and the value of **i** to assign a unique name to each of the instances of the PWM module. This is important when simulating.

### Creating Animations

This code is great and all, but the LEDs are just static. In this example we are going to make an LED fade in and out.

First we need to figure out what do we have to do to make it fade in and out? We know that the value of **compare** sets the brightness of the LED so we just need to vary **compare** up and down. At first this seems like it could be done using a simple counter, but there's a problem with that. Once a counter gets to its max value it resets to 0 just like this.

![basic.png](https://cdn.alchitry.com/verilog/mojo/basic.png)

In this picture the grayed out areas are where the MSB of the counter is 1. If instead of looking at the value of the whole counter, we look at the value without the MSB the counter will look like this.

![basic_counter_wo_msb.png](https://cdn.alchitry.com/verilog/mojo/basic_counter_wo_msb.png)

The max value of the counter become half of what it used to be, but the frequency is doubled. However, we now have a way to make the counter behave like we want it to. If we simply invert the value of the counter when the MSB is 1, we end up with this.

![basic_counter_inversion.png](https://cdn.alchitry.com/verilog/mojo/basic_counter_inversion.png)

That looks much better! If we feed that signal into the compare signal of the PWM module the LED will fade in and out just like we want.

This is great but how do we actually invert the value of the counter? One way to do it is to take **Max/2** and subtract the counter value. However, there is a better way to do this. If we simply invert all the bits we get the same effect! For example if we are counting from 0-7 the first three numbers are 000, 001, and 010. If we invert the bits that becomes 111, 110, 101, or 7, 6, 5. Simply by inverting each bit we can change the counter from counting up to counting down.

Let's add this counter to the project. Create a new file called counter.v and add the following to it.

```verilog
module counter (
    input clk,
    input rst,
    output reg [7:0] value
  );
 
  reg[24:0] ctr_d, ctr_q;
 
  always @(ctr_q) begin
    ctr_d = ctr_q + 1'b1;
 
    if (ctr_q[24])
      value = ~ctr_q[23:16];
    else
      value = ctr_q[23:16];
 
  end
 
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
    end
  end
 
endmodule
```

This is just a basic counter with the inversion method to make the value count up then down. Note that we are using a large 25 bit counter, but we are only using the top few bits. This is because we need the counter to be slow enough for us to see the LED fade in and out!

Also note that the output **value** is declared as a **reg**. That allows us to assign a value to it directly in the always block.

We now need to wire this up to our PWM module in **mojo_top.v**.

```verilog,linenos
module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  assign led = {8{pwm}};
 
  wire [7:0] compare;
  wire pwm;
 
  counter fancyCounter (
  .rst(rst),
  .clk(clk),
  .value(compare)
  );
 
  pwm #(.CTR_LEN(8)) fancyPWM (
    .rst(rst),
    .clk(clk),
    .compare(compare),
    .pwm(pwm)
  );
 
endmodule
```

This code is fairly straight forward, but it uses a new feature of Verilog. Take a look at the line below.

```verilog,linenos,linenostart=30
assign led = {8{pwm}};
```

The `{{}}` syntax allows you to duplicate a signal a set number of times. In this case we are duplicating the one wire wide signal **pwm** into an eight wire wide signal with identical values. This is just to make all the LEDs do the same thing without having to assign each one **pwm** individually.

You can now synthesize your project and check it out on the Mojo. All the LEDs should fade in and out.

### Putting it all together

The code above is actually a bit inefficient. This is because we have but of redundancy. The counter in our PWM module will have the exact same value as the eight LSBs in our counter module! It turns out that ISE is actually smart enough to figure this out and it will optimize one of them away and just use one. If you look in the warning when you synthesize the project you will see something like the following for each of the eight signals.

> Xst:2261 - The FF/Latchin Unitis equivalent to the following FF/Latch, which will be removed :

Another thing to consider is that if you want to have multiple PWM units you really don't need multiple counters because they will all be the same. 

The Mojo ships with an example project that fades the LEDs in a fancy wave pattern. Here is the module responsible for that.

```verilog
module led_wave #(
    parameter CTR_LEN = 25
  )(
    input wire clk,
    input wire rst,
    output reg[7:0] led
  );
 
  reg[CTR_LEN-1:0] ctr_d, ctr_q = {CTR_LEN{1'b0}};
  reg[3:0] i;
  reg[7:0] acmp;
  reg[8:0] result;
 
  always @(ctr_q) begin
    ctr_d = ctr_q + 1'b1;
 
    for (i = 0; i < 8; i = i + 1) begin
      result = ctr_q[CTR_LEN-1:CTR_LEN-9] + i * 8'd64;
 
      if (result[8])
        acmp = ~result[7:0];
      else
        acmp = result[7:0];
 
      led[i] = acmp > ctr_q[7:0];
    end
  end
 
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= {CTR_LEN{1'b0}};
    end else begin
      ctr_q <= ctr_d;
    end
  end
 
endmodule
```

This module has a few fancy tricks, like the one with the inverted counter, to make it very compact. It also gets away with using only one counter to control all eight LEDs even though each has a different duty cycle!

This code uses a different type of for loop, but it accomplishes the same thing and should be fairly easy to understand. Just like with **for generate** loops the number of loop iterations needs to be constant. When designing hardware it is important to think of for loops as simply a compact way to write something.

The counter value is offset by a different amount for each LED which creates the wave effect. 

I'll leave it up to you to instantiate this module and connect its output to the LEDs in **mojo_top.v**. This is similar to the previous **mojo_top.v** file except instead of using the same signal (**pwm**) for all eight LEDs, you can directly connect the LED signal to the output of the module.