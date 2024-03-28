+++
title = "Analog Inputs"
weight = 12
+++

The Mojo has eight analog inputs that you can use to read voltages from 0-3.3V. In this tutorial we will make the Mojo read the voltage on input A0 and adjust the brightness of the LEDs depending on the value.

This tutorial uses the **PWM module** from the [pulse-width modulation tutorial](@/tutorials/verilog/mojo/pulse-width-modulation.md), so make sure you understand how that works before getting started. Also like the other tutorials, you will need a fresh copy of the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip).

### AVR Interface

Just like in the Hello World! tutorial we are going to use the **AVR Interface** module that is included in the base project. If you open up **avr_interface.v** you can check out its inputs and outputs. For reading the analog inputs, there are four relevant signals.

```verilog
input [3:0] channel,
output new_sample,
output [9:0] sample,
output [3:0] sample_channel,
```

You only need to specify one parameter, **channel**. **Channel** is used to specify the analog input you want to sample. Valid values are 0,1,4,5,6,7,8,9. Those correspond to the Ax labels on the Mojo board, where x is the channel number. If you specify an invalid channel number the ADC will be disabled. This is useful when you don't need to use the ADC and would like to have lower latency and higher throughput on the serial port.

For this tutorial, we are going to just set **channel** to 0 as we will only be sampling the one channel.

The values on **sample** and **sample_channel** are only valid when **new_sample** is high. Each sample from the ADC is 10bits wide and is available at the **sample** output. When you receive a new sample you need to check **sample_channel** to find what channel the sample belongs to. When you change the **channel**, you can't assume the next sample will be from the new channel. This is because the ADC values are buffered in a FIFO before being sent to the FPGA. There may still be some old values that need to get sent out before the new samples come in. If you are just reading one channel, like we are in this case, you should be safe to ignore **sample_channel**, but it's good practice not to.

### Sample Capture

Since the samples come in sporadically, we need a module that will capture the valid values and feed them into a PWM module to light up the LEDs.

```verilog
module input_capture(
    input clk,
    input rst,
    output [3:0] channel,
    input new_sample,
    input [9:0] sample,
    input [3:0] sample_channel,
    output [7:0] led
  );
 
  assign channel = 4'd0; // only read A0
 
  reg [9:0] sample_d, sample_q;
  wire pwm;
 
  pwm #(.CTR_LEN(10)) led_pwm ( // 10bit PWM
    .clk(clk),
    .rst(rst),
    .compare(sample_q),
    .pwm(pwm)
  );
 
  assign led = {8{pwm}}; // duplicate the PWM signal to each LED
 
  always @(*) begin
    sample_d = sample_q;
 
    if (new_sample && sample_channel == 4'd0) // valid sample
      sample_d = sample;
  end
 
  always @(posedge clk) begin
    if (rst) begin
      sample_q <= 10'd0;
    end else begin
      sample_q <= sample_d;
    end
  end
 
endmodule
```

This module just waits for a new valid sample and updates the register **sample_d/_q** with the new value. That value is fed directly into the PWM module. The output of the PWM module is fed to the **led** output. The **pwm** signal is duplicated eight times so all the LEDs will light up together.

### Top Level

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
 
  wire [3:0] channel;
  wire new_sample;
  wire [9:0] sample;
  wire [3:0] sample_channel;
 
  avr_interface avr_interface (
    .clk(clk),
    .rst(rst),
    .cclk(cclk),
    .spi_miso(spi_miso),
    .spi_mosi(spi_mosi),
    .spi_sck(spi_sck),
    .spi_ss(spi_ss),
    .spi_channel(spi_channel),
    .tx(avr_rx),
    .rx(avr_tx),
    .channel(channel),
    .new_sample(new_sample),
    .sample(sample),
    .sample_channel(sample_channel),
    .tx_data(8'h00),
    .new_tx_data(1'b0),
    .tx_busy(),
    .tx_block(avr_rx_busy),
    .rx_data(),
    .new_rx_data()
  );
 
  input_capture input_capture (
    .clk(clk),
    .rst(rst),
    .channel(channel),
    .new_sample(new_sample),
    .sample(sample),
    .sample_channel(sample_channel),
    .led(led)
  );
 
endmodule
```

Here is the top level module, **mojo_top.v**. The only modifications were made to instantiate the **avr_interface** module and our **input_capture** module.

Don't forget to also add the PWM module from the PWM tutorial to your project.

### Try it out!

You should now be able to synthesize your project. Connect something like a potentiometer to A0 and watch the LEDs as you vary the voltage. When you apply 0V to A0 they should be off and when you apply 3.3V they should be fully on. Be careful not to connect your potentiometer to the **RAW** power supply as you can damage the AVR by feeding too high of a voltage to the analog pins.