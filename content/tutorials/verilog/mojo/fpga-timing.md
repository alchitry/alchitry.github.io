+++
title = "FPGA Timing"
weight = 8
+++

**Timing** is a term used in digital circuits to refer to the time it takes a signal to propagate from one flip-flop, through some combinational logic, to the next flip-flop.

Take a look at the following diagram.

![](https://cdn.alchitry.com/verilog/mojo/timing_circuit.png)

It is very important to understand that combinational logic is not instantaneous. It takes time for the signal to propagate. The reason for this is that digital circuits actually look like a bunch of [RC circuits](http://en.wikipedia.org/wiki/RC_circuit). MOSFETs, a type of transistor, are the transistors of choice for digital circuits. The gate (switch part) of a MOSFET acts much like a capacitor and takes a small amount of time to charge and discharge (turn on and off the transistor). The more transistors you need to turn on and off, the longer it takes.

For the scope of this tutorial, it's not important to understand exactly why it takes a certain amount of time for a signal to propagate through combination logic, just that it does and the more logic you have the longer it will take.

Since each flip-flop will copy the value of **D** to **Q** at the rising edge of each clock, that means that we have a single clock cycle for the output of the first flip-flop to propagate through our combinational logic and make it to the input of the second flip-flop.

![setup_hold.png](https://cdn.alchitry.com/verilog/mojo/setup_hold.png)

If you recall from the [metastability and debouncing tutorial](@/tutorials/verilog/mojo/metastability-and-debouncing.md), flip-flops require their inputs to be stable for a certain amount of time before and after the rising edge of the clock. These times are known as the **setup** and **hold** times respectively. These parameters constrain our circuit even more because now we have to ensure that the delay of our combinational logic is short enough that the signal will get there in a clock period minus the setup time. However, it can't be too fast that it violates the hold time!

The last flip-flop parameter we'll be concerned about here is the **clock-to-Q propagation delay**.

![clock-to-q.png](https://cdn.alchitry.com/verilog/mojo/clock-to-q.png)

In past tutorials, we have assumed that the moment the rising edge of the clock happens, the value of **D** showed up at **Q**. However, like all things, there is a slight delay. The **clock-to-Q propagation delay** specifies the amount of time after the rising edge of the clock that **Q** outputs the new value. This delay cuts into the time we have for the combinational logic since the input to the combinational logic is delayed!

To summarize, the time it take for the signal to propagate through the combinational logic must be shorter than the clock period minus the clock-to-Q propagation delay minus the setup time. The combinational logic delay must also be greater than the hold time minus the clock-to-Q propagation delay.

If we let the combinational logic delay = **CLD**, clock period = **CLK**, setup time = **ST**, hold time = **HT**, clock-to-Q propagation delay = **CQ**, then the following formula shows our constraints.

**HT - CQ < CLD < CLK - CQ - ST**

### Contamination and Propagation Delays

There is another invalid assumption we need to correct. We assumed that the output of our combinational logic was constant until the correct value showed up. This is not true. While the correct value is propagating, the output of the combinational logic can change multiple times before settling on the correct value. There are two important parameters that capture this behavior. The first, **contamination delay**, is the amount of time the output of the combinational logic will stay constant after it's inputs are changed. After that delay the outputs are _contaminated_. The second, **combinational logic propagation delay**, is the time that it takes for the output to be valid after the input changes.

That means for the time between the **contamination delay** and **propagation delay** of our combinational logic, its output is unpredictable and possibly invalid.

We now have to make sure that the **contamination delay** does not violate the hold time, and that the **combinational logic propogation delay** does not violate the setup time.

If we let the combinational logic propagation delay **= CLPD** and the contamination delay = **CD** the the following new formulas capture our constraints.

**CD > HT - CQ**

**CLPD < CLK - CQ - ST**

### **Clock Skew**

This is the last invalid assumption we need to correct. We assumed that the clock reached all the flip-flops in the circuit at the same exact time. Since the clock needs to travel through the chip, this can't possibly be the case. The difference in time it takes to reach two flip-flops is known as the **clock skew**.

In some cases clock skew can actually be helpful, but in many cases it takes away time from us.

If we let clock skew = **CS** then the following formulas are updated versions of the previous ones.

**CD > HT - CQ +/- CS**

**CLPD < CLK - CQ - ST +/- CS**

Note that the clock skew can have either sign. This is since the clock could arrive earlier to the first flip-flop, or later. It really just depends on how the circuit is laid out on the chip. Notice that if the first flip-flop gets the clock earlier (positive clock skew in our convention), then the constraint on the **contamination delay** becomes stricter and the constraint on the **combinational logic propagation delay** becomes looser. If the clock arrives at the second flip-flop first, the opposite is true.

In general clock skew is bad. This is why FPGAs have special resources dedicated to routing clock signals. These are designed to deliver the clock to the entire FPGA (or sub-sections for local clocks) with minimal clock skew.

### The full picture

Enough of all these equations. Let's take a look at the following diagram which shows it all.

In past tutorials, we have assumed that the moment the rising edge of the clock happens, the value of **D** showed up at **Q**. However, like all things, there is a slight delay. The **clock-to-Q propagation delay** specifies the amount of time after the rising edge of the clock that **Q** outputs the new value. This delay cuts into the time we have for the combinational logic since the input to the combinational logic is delayed!

To summarize, the time it take for the signal to propagate through the combinational logic must be shorter than the clock period minus the clock-to-Q propagation delay minus the setup time. The combinational logic delay must also be greater than the hold time minus the clock-to-Q propagation delay.

If we let the combinational logic delay = **CLD**, clock period = **CLK**, setup time = **ST**, hold time = **HT**, clock-to-Q propagation delay = **CQ**, then the following formula shows our constraints.

**HT - CQ < CLD < CLK - CQ - ST**

### Contamination and Propagation Delays

There is another invalid assumption we need to correct. We assumed that the output of our combinational logic was constant until the correct value showed up. This is not true. While the correct value is propagating, the output of the combinational logic can change multiple times before settling on the correct value. There are two important parameters that capture this behavior. The first, **contamination delay**, is the amount of time the output of the combinational logic will stay constant after it's inputs are changed. After that delay the outputs are _contaminated_. The second, **combinational logic propagation delay**, is the time that it takes for the output to be valid after the input changes.

That means for the time between the **contamination delay** and **propagation delay** of our combinational logic, its output is unpredictable and possibly invalid.

We now have to make sure that the **contamination delay** does not violate the hold time, and that the **combinational logic propogation delay** does not violate the setup time.

If we let the combinational logic propagation delay **= CLPD** and the contamination delay = **CD** the the following new formulas capture our constraints.

**CD > HT - CQ**

**CLPD < CLK - CQ - ST**

### **Clock Skew**

This is the last invalid assumption we need to correct. We assumed that the clock reached all the flip-flops in the circuit at the same exact time. Since the clock needs to travel through the chip, this can't possibly be the case. The difference in time it takes to reach two flip-flops is known as the **clock skew**.

In some cases clock skew can actually be helpful, but in many cases it takes away time from us.

If we let clock skew = **CS** then the following formulas are updated versions of the previous ones.

**CD > HT - CQ +/- CS**

**CLPD < CLK - CQ - ST +/- CS**

Note that the clock skew can have either sign. This is since the clock could arrive earlier to the first flip-flop, or later. It really just depends on how the circuit is laid out on the chip. Notice that if the first flip-flop gets the clock earlier (positive clock skew in our convention), then the constraint on the **contamination delay** becomes stricter and the constraint on the **combinational logic propagation delay** becomes looser. If the clock arrives at the second flip-flop first, the opposite is true.

In general clock skew is bad. This is why FPGAs have special resources dedicated to routing clock signals. These are designed to deliver the clock to the entire FPGA (or sub-sections for local clocks) with minimal clock skew.

### The full picture

Enough of all these equations. Let's take a look at the following diagram which shows it all.

![](https://cdn.alchitry.com/verilog/mojo/timing_complete.png)

For this diagram, the combinational logic just inverts the signal. The signals with a suffix of 1 are the left flip-flop in the first diagram, while the ones with a suffix of 2 are the right flip-flop. The grey shaded part of the signal is to show how that pulse propagates through the circuit.

If you look at **Q1** and **Q2** then you will notice how **Q2** is an inverted version of **Q1** delayed by a clock cycle (since it goes through a flip-flop).

Also notice in this example, timing is met. The setup and hold times of the flip-flops are never violated.

### What you can control

When you are using an FPGA, you have control over very few of the parameters previously mentioned. This is because they are largely determined by the physical properties of the FPGA circuitry, but also because synthesis tools do a lot of the work for you.

The two largest factors you have direct control over are the **clock** **period** and the **combinational logic propagation delay**. The delay can be shortened by removing some of the combinational logic between two flip-flops. How you remove this logic is up to you. Besides optimization of your design, you can pipeline your design. We'll cover that in a little bit. First, let's take a look at a case when timing is not being met.

### Broken timing

[Download this project](http://cdn.embeddedmicro.com/Timing/Mojo-Timing.zip) and open it in ISE.

The **timing.v** file is the one we are interested. Its contents are shown below.

```verilog,linenos
module timing (
    input clk,
    input [7:0] a,
    input [7:0] b,
    output [31:0] c
  );
 
  reg [7:0] a_d, a_q, b_d, b_q;
  reg [31:0] c_d, c_q;
 
  assign c = c_q;
 
  always @(*) begin
    a_d = a;
    b_d = b;
    c_d = (a_q * a_q) * (a_q * a_q) * (b_q * b_q) * (b_q * b_q);
  end
 
  always @(posedge clk) begin
    a_q <= a_d;
    b_q <= b_d;
    c_q <= c_d;
  end
 
endmodule
```

Notice line 16. This line contains a ton of multiplication. All of these multiplications will be instantiated as a bunch of combinational logic between the flip-flops used at the input and output of the module.

After you open it, build the programming file. Once that done it should look like the following screen shot.

![ise-timing.resized.png](https://cdn.alchitry.com/verilog/mojo/ise-timing.resized.png)

Notice the spot that is highlighted. Even though the project built successfully, it failed to meet timing. That means that our design won't work properly at the clock we specified. There is simply too much combinational logic to put between two flip flops in this design.

You can click on **(Timing Report)** to get more details on where timing could not be meet.

![ise-timing-report.resized.png](https://cdn.alchitry.com/verilog/mojo/ise-timing-report.resized.png)

While there are many paths that failed to meet timing, it's usually most helpful to just look at the worst ones and see where the problem is. Conveniently, those show up at the top of the list.

Take a look at the **Source** and **Destination** fields. Even though what they say is a bit cryptic, you can usually glean enough information to tell where the problem is. In our case you can tell that the source is in our slow_multiply module and has to do with the signal **a_q**. This is exactly what we expect with all those multiplies.

One important thing to notice in the report is where it specifies the **minimum period**. In our case it says the minimum period is 25.334ns. That means the fastest our clock can be is 39.47 MHz (1 / 25.334ns). If we didn't care about maintaining the 50MHz clock, we could scale it down to say a 35MHz clock and our circuit would perform as expected.

Another important thing to notice is that there are no timing errors for the **hold paths**. This is because ISE tries really hard to satisfy the hold time even if that means making some of the setup times be violated. The reason for this is as long as all the hold times are satisfied, you can always scale back your clock speed to get your circuit to work. If there were hold time violations, the circuit could never work regardless of the clock frequency.

### Pipelining

So assuming we want to keep our 50MHz clock, how do we fix the timing issue? The simple answer is to use a technique called **pipelining**. All that pipelining is, is adding flip-flops in the middle of big combinational logic blocks. In this case, since the timing problem isn't too bad, we are going to just place a set of flip-flops before the final largest (and slowest) multiplication.

Open up **timing.v** and replace it with the following.

```verilog
module timing (
    input clk,
    input [7:0] a,
    input [7:0] b,
    output [31:0] c
  );
 
  reg [7:0] a_d, a_q, b_d, b_q;
  reg [31:0] c_d, c_q;
 
  reg [15:0] temp1_d, temp1_q;
  reg [15:0] temp2_d, temp2_q;
 
  assign c = c_q;
 
  always @(*) begin
    a_d = a;
    b_d = b;
    temp1_d = (a_q * a_q) * (a_q * a_q);
    temp2_d = (b_q * b_q) * (b_q * b_q);
    c_d =  temp1_q * temp2_q;
  end
 
  always @(posedge clk) begin
    a_q <= a_d;
    b_q <= b_d;
    c_q <= c_d;
    temp1_q <= temp1_d;
    temp2_q <= temp2_d;
  end
 
endmodule
```

Now, the fourth power of **a** and **b** are computed in one clock cycle and in the next clock cycle those results are then multiplied to create the final result.

If you save the file and rebuild the project, you will notice that timing is now satisfied.

![ise-timing-met.resized.png](https://cdn.alchitry.com/verilog/mojo/ise-timing-met.resized.png)

One important note with pipelining is that we only increase the latency of our result. We are not decreasing the throughput. That means that we can feed in a new set of numbers to be multiplied every clock cycle, but that their results won't show up at **c** until two clock cycles later. If we just decreased the clock speed to meet timing, we would be increasing latency and decreasing throughput.

### Conclusion

It is very important to be thinking of what clock speed you will want your design to run at when you are writing your code. You will get a feel for when something will take too long to complete in one clock cycle with experience. One of the reasons the Mojo has a 50MHz clock is because 50MHz is fairly slow. That means that unless you decided to do a ton of multiplication or some other complex logic, you probably won't run into timing issues. However, you can synthesize faster clocks inside the FPGA and if you start clocking the Mojo at, say 150MHz, timing can become a real concern.