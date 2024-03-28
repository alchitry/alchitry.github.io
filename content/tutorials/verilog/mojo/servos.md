+++
title = "Servos"
weight = 11
inline_language = "verilog"
+++

Servos come in handy in all sorts of projects from robots to electronic locks. This tutorial will cover how to control servos with the Mojo.

Servos are controlled by PWM. However, the PWM signal they use is not quite like the one we were using to dim the LEDs in the [pulse-width modulation tutorial](@/tutorials/verilog/mojo/pulse-width-modulation.md). This form of PWM has a fairly long period, and the duty cycle only varies slightly. The position of a servo is determined by the width of a pulse sent to it about once every 20ms. The pulse width varies from about 1ms (full one direction) to 2ms (full the opposite way), with 1.5ms being the neutral position. The max and min width can vary a bit for each servo but they all have a neutral of 1.5ms. 

### Increasing the Period

When we did PWM last time we just used the smallest counter possible because we didn't care about the frequency as long as it was faster than our eyes could see. In this case we do care about the frequency. We want the frequency to be roughly 50Hz, or a 20ms period. Since we know the Mojo runs at 50MHz, we need to divide that down by 1,000,000. Log2(1,000,000) = ~19.9, that's pretty close to 20 so we're going to use a 20 bit counter. 

Servos aren't particularly sensitive to the exact period of your signal as long as it's in the ball park. If we wanted to get an exact period of 20ms we could use a 20 bit counter and check to see when it reaches 1,000,000. When it reached the top you can just reset it to 0. However, unless you have a good reason to do this, it's better to just use a power of two because it makes things simpler and uses less hardware.

### Fixing the Width

For our servo controller we need a pulse width of 1ms-2ms. That means it needs to have a compare value from 50,000 - 100,000. The most important part here is that we our neutral is at 75,000. 

This servo controller will be an 8 bit controller. That means we want to have 256 positions for the servo, specified by an input to our module. We need to figure out a way to easily make a value from 0-255 range from about 50,000-100,000.

First we need to scale our value. We need 255 to be 50,000, so 50,000/255 = ~196. That is pretty close to 256, so we can just shift our value by 8 bits to the left.

Now we need an offset to make sure our center value is close to 75,000. To find this we do (75,000 - (128 * 2^8)) / 2^8 = ~165. That means we need to just add 165 to our input value and then scale that by 256, by shifting to the left 8 bits.

Lets put this together in a module.

```verilog
module servo (
    input clk,
    input rst,
    input [7:0] position,
    output servo
  );
 
  reg pwm_d, pwm_q;
  reg [19:0] ctr_d, ctr_q;
 
  assign servo = pwm_q;
 
  always @(*) begin
    ctr_d = ctr_q + 1'b1;
 
    if (position + 9'd165 > ctr_q[19:8])
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

Notice I used `9'd165` instead of `8'd165` that is because I wanted to ensure that the result would be a 9 bit number because 165 + 255 would overflow.

Also instead of shifting out value over 8 bits to the left, I just dropped the 8 LSBs of ctr_q. 

To test this module out I modified the counter code from the PWM tutorial to be generic.

```verilog
module counter #(parameter CTR_LEN = 27)(
    input clk,
    input rst,
    output reg [7:0] value
  );
 
  reg[CTR_LEN-1:0] ctr_d, ctr_q;
 
  always @(ctr_q) begin
    ctr_d = ctr_q + 1'b1;
 
    if (ctr_q[CTR_LEN-1])
      value = ~ctr_q[CTR_LEN-2:CTR_LEN-9];
    else
      value = ctr_q[CTR_LEN-2:CTR_LEN-9];
 
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

and finally I instantiated it all in **mojo_top.v**

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
    input avr_rx_busy, // AVR Rx buffer full
 
    output servo
  );
 
  wire rst = ~rst_n; // make reset active high
 
  // these signals should be high-z when not used
  assign spi_miso = 1'bz;
  assign avr_rx = 1'bz;
  assign spi_channel = 4'bzzzz;
 
  assign led = 8'b0;
 
  wire [7:0] servo_position;
 
  counter #(.CTR_LEN(28)) servoCounter (
    .clk(clk),
    .rst(rst),
    .value(servo_position)
  );
 
  servo myServoController (
    .clk(clk),
    .rst(rst),
    .position(servo_position),
    .servo(servo)
  );
 
endmodule
```

Don't forget to add an entry in the UCF file for the servo output. I used pin 50 so I added the line

```ucf
NET "servo" LOC = P50;
```

### 5V Servos

There's one more thing to be aware of, most servos run at 5V. However, most servos will register a 3.3V signal without any problems. To hook up your servo, simply power the Mojo with 5V (through USB or the barrel jack) and hook the servo's power pin to the RAW pin on the Mojo. 

You should have a servo moving back and forth!