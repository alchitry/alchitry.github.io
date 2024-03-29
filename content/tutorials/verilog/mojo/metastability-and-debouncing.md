+++
title = "Metastability and Debouncing"
weight = 7
+++

In this tutorial we will cover some of the pit falls that can happen when having asynchronous inputs to the Mojo. The more general case is **metastability**, but we will also cover **debouncing** of buttons. These are both important if you want to reliably detect when a button is being pressed or interface with anything that is not synchronized to the Mojo's clock.

## Metastability

To understand metastability, you first need a little background on the timing requirements of the [flip-flop](@/tutorials/verilog/mojo/synchronous-logic.md). As we discussed before, a flip-flop will copy the value at the **D** side to the **Q** side at the positive edge of the clock and hold the value steady until the next positive edge. What we didn't  cover was what is known as the **setup** and **hold** timing constraints.

This tutorial will not go into too much detail on what causes these constraints and what their actual values are. All that is important right now, is to know that the **setup** constraint tells you how long before the positive edge of the clock the value on the **D** side must be stable. The **hold** time tells you how long after the positive edge of the clock the **D** side must continue to be stable. 

Here is a diagram illustrating this.

![metastability.png](https://cdn.alchitry.com/verilog/mojo/metastability.png)

The areas that **D** needs to be constant are shaded in grey on the clock. As you can see the **setup** time specifies the time before the rising edge and the **hold** time is the time after the rising edge.

The **D** and the **Q** signals under the clock are an example of what could happen. The first two rising edges are valid since during the setup and hold time **D** is constant. For the last edge **D** changes when it shouldn't so the value of **Q** becomes unknown.

**Q** may take a random value of 0 or 1, however, that is the _best_ case. There is also a possibility that **Q** will get stuck somewhere between 0 and 1 (0.5?!?), or worse yet it may oscillate, flipping between 0 and 1 very rapidly. 

As you may have guessed you don't want any of that to happen. Bad things will happen and your circuit will do unexpected things. 

There are two solutions to this problem.

First, you can just design your circuit so this never happens! This is exactly what the tools (ISE) does for you when you map your design. If it can't meet timing for some reason you'll get **timing errors**. If you are just running the Mojo at 50MHz, you probably won't encounter these unless you do multiple multiplications between flip flops or some other complicated computational logic. This will be covered more in later tutorials.

As you may have realized, sometimes you can't control when a signal will change. For this tutorial we are using a button. It's impossible for us to guarantee that the button won't be pressed and violate the setup and hold constraints. 

The second solution is to then use not one but two flip-flops! 

![metastability-dualff.png](https://cdn.alchitry.com/verilog/mojo/metastability-dualff.png)

This will add a small amount of latency to your input signal, but it significantly reduces the chance that you will encounter metastability problems. This is the solution we will use to read the button reliably.

It is important to note that this does not _solve_ the metastability problem and there is still a small chance you could have problems. However, using two flip-flops drastically reduces that chance. If you are really worried about a certain input, you can chain more flip-flops together for a smaller chance of stability issues. However, there are diminishing returns and two will be plenty for most cases.

## Debouncing

When you press a button, there is a chance that the button will not simply go from open to closed. Since a button is a mechanical device the contacts can **bounce**. When a button bounces the value it produces looks something like this.

![bouncing.png](https://cdn.alchitry.com/verilog/mojo/bouncing.png)

For a short period after the button is pressed the value you read from an IO pin may toggle between 0 and 1 a few times before settling on the actual value. This is where **debouncing** comes into play.

To debounce a button, you just need to require that for a button to register as being pressed, it must _look_ like it's being pressed for a set amount of time. In this case, being _pressed_ is when the value of the button is 1. If you read enough 1's in a row it is safe to assume that the button has stopped bouncing and you can register one button press.

If you fail to do this and you are using the button to increment a counter, then the counter may increase by more than 1 per button press since it will appear that each bounce was a separate press.

```verilog
module button_conditioner (
    input clk,
    input btn,
    output out
  );
 
  reg [19:0] ctr_d, ctr_q;
  reg [1:0] sync_d, sync_q;
 
  assign out = ctr_q == {20{1'b1}};
 
  always @(*) begin
    sync_d[0] = btn;
    sync_d[1] = sync_q[0];
    ctr_d = ctr_q + 1'b1;
 
    if (ctr_q == {20{1'b1}}) begin
      ctr_d = ctr_q;
    end
 
    if (!sync_q[1])
      ctr_d = 20'd0;
  end
 
  always @(posedge clk) begin
    ctr_q <= ctr_d;
    sync_q <= sync_d;
  end
 
endmodule
```

Here is a simple module that takes a button press and passes it through two flip-flops to prevent stability issues. With the synchronized signal, a counter is incremented when the button is pressed and reset when it is 0. The counter will saturate at it's max value. Once it hit's the max value it is safe to say the the button has been pressed and the output is set to 1.

By using the **button_conditioner** module you can be sure that you will be able to reliably read button presses.