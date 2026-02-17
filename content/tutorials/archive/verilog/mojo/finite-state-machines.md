+++
title = "Finite State Machines"
weight = 9
aliases = ["tutorials/verilog/mojo/finite-state-machines.md"]
+++

**F**inite **S**tate **M**achines, or **FSM**s, are an incredibly powerful tool when designing digital circuits. This tutorial will teach what an FSM is through example. We will use a basic FSM to control a very simple robot.

![robot.jpg](https://cdn.alchitry.com/verilog/mojo/robot.jpg)

Before we get into the nitty gritty of how to actually implement this, it's important to understand what an FSM actually is.

### What's an FSM?

An FSM, in its most general form, is a set of flipflops that hold only the current state, and a block of combinational logic that determines the the next state given the current state and some inputs. The output is determined by what the current state is. 

Take a look at the following diagram.

![generic_fsm.png](https://cdn.alchitry.com/verilog/mojo/generic_fsm.png)

This is what an FSM looks like in hardware. The only storage it has is for the current state. Since the main block of logic is combinational, there can't be any flip-flops inside of it. Remember, **combinational logic** will produce the same outputs given the same set of inputs at any time. 

This is all very abstract. Let's now look at how to actually design an FSM.

### The States

The first thing to do when designing an FSM is to figure out what states you will need.

Since we are going to use the FSM to control a robot, we need to think about the behavior we want.

First, the robot has two contact switches mounted on the front of it as shown below.

![robot_wiskers.jpg](https://cdn.alchitry.com/verilog/mojo/robot_wiskers.jpg)

These are wired up so that when they are not being pressed, the signal line is connected to ground, but when pressed, it get connected to +5V. Remember, the Mojo's IO pins are not 5V tolerant, however, because this robot is using the Servo Shield, this is exactly what we want.

By using these switches, the robot can realize when it runs into something. For some basic object avoidance, we will make the robot back up when it hits something then turn right if the left switch was pressed or turn left if the right switch was pressed. When the robot hasn't hit anything it will just drive forward.

This leads us to five states.

- **FORWARD**
- **BACKUP_RIGHT**
- **TURN_RIGHT**
- **BACKUP_LEFT
- **TURN_LEFT

Notice that there are two versions of the **BACKUP** state, **BACKUP_RIGHT** and **BACKUP_LEFT**. This is because we need to encode in the states which one will turn right after it backs up and which will turn left. If we didn't have separate states, we would have to read the state of the switch after it backed up and at that point the switch would not be pressed anymore.

Take a look at the basic flow of states to help clear this up.

![fsm_blank.png](https://cdn.alchitry.com/verilog/mojo/fsm_blank.png)

### State Transitions

We now need to figure out under what conditions we would like the state to change.

The first one is easy, when the FSM is in the **FORWARD** state it should change to the **BACKUP_RIGHT** state when the left switch is pressed, or to the **BACKUP_LEFT** state when the right switch is pressed.

The next ones are a little different. We want them to just flow to the next state, but we can't just have them flow immediately to the next state otherwise the robot won't have any time to backup or turn! It will happen so fast that it will appear that nothing happened.

To keep the state the same for a longer amount of time, we need to introduce a counter.

The counter **can't** be part of the FSM because a counter requires some flip-flops to store the counter value! Instead, the counter is part of what is known as the **data path**. The FSM portion of circuit simply supplies signals to reset the counter and the data path provides signals like the counter has reached a certain value.

This naming convention is a bit arbitrary and you shouldn't worry about it too much when designing your own FSMs. If it seems to make your circuit a lot simpler if you break some rules, you probably should.

Take a look now at the state diagram with the transitions labeled.

![fsm.png](https://cdn.alchitry.com/verilog/mojo/fsm.png)

### Implementation

The easiest way to understand how to write an FSM is to just take a look at one.

```verilog,short,linenos
module robot_fsm (
    input clk,
    input rst,
    input switch_left,
    input switch_right,
    output reg [7:0] left,
    output reg [7:0] right
  );
 
  localparam STATE_SIZE = 3;
 
  localparam FORWARD = 0,
    BACKUP_RIGHT = 1,
    TURN_RIGHT = 2,
    BACKUP_LEFT = 3,
    TURN_LEFT = 4;
 
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg [25:0] ctr_d, ctr_q;
 
  reg [1:0] sl_d, sl_q, sr_d, sr_q;
 
  always @* begin
    sl_d[0] = switch_left;
    sl_d[1] = sl_q[0];
    sr_d[0] = switch_right;
    sr_d[1] = sr_q[0];
 
    ctr_d = ctr_q + 1'b1;
    state_d = state_q;
 
    case (state_q)
      FORWARD: begin
        ctr_d = 25'd0;
        if (sr_q[1]) begin
          state_d = BACKUP_LEFT;
        end else if (sl_q[1]) begin
          state_d = BACKUP_RIGHT;
        end
      end
      BACKUP_RIGHT: begin
        if (ctr_q == {26{1'b1}})
          state_d = TURN_RIGHT;
      end
      TURN_RIGHT: begin
        if (ctr_q == {25{1'b1}})
          state_d = FORWARD;
      end
      BACKUP_LEFT: begin
        if (ctr_q == {26{1'b1}})
          state_d = TURN_LEFT;
      end
      TURN_LEFT: begin
        if (ctr_q == {25{1'b1}})
          state_d = FORWARD;
      end
      default: state_d = FORWARD;
    endcase
 
    case (state_q)
      FORWARD: begin
        left = 8'h50;
        right = 8'h50;
      end
      BACKUP_RIGHT: begin
        left = 8'hB0;
        right = 8'hB0;
      end
      TURN_RIGHT: begin
        left = 8'hB0;
        right = 8'h50;
      end
      BACKUP_LEFT: begin
        left = 8'hB0;
        right = 8'hB0;
      end
      TURN_LEFT: begin
        left = 8'h50;
        right = 8'hB0;
      end
      default: begin
        left = 8'h80;
        right = 8'h80;
      end
    endcase
  end
 
  always @(posedge clk) begin
    if (rst) begin
      state_q <= FORWARD;
    end else begin
      state_q <= state_d;
    end
    ctr_q <= ctr_d;
    sl_q <= sl_d;
    sr_q <= sr_d;
  end
 
endmodule
```

First let's look at the declaration of states.

```verilog,linenos,linenostart=10
localparam STATE_SIZE = 3;
 
localparam FORWARD = 0,
  BACKUP_RIGHT = 1,
  TURN_RIGHT = 2,
  BACKUP_LEFT = 3,
  TURN_LEFT = 4;
 
reg [STATE_SIZE-1:0] state_d, state_q;
```

Here we declare the various states we will use in a human readable way. By using **STATE_SIZE** it makes it easy to add or remove states if we change the design later.

All the stuff with **sl_d**, **sl_q**, **sr_d**, and **sr_q**, are used to prevent meta-stability when reading the switches. Be sure to check out the [metastability and debouncing tutorial](@/tutorials/archive/verilog/mojo/metastability-and-debouncing.md) if you need a refresher. 

Take note of the following two lines.

```verilog,linenos,linenostart=29
ctr_d = ctr_q + 1'b1;
state_d = state_q;
```

The first line says that the counter should continue counting unless something in our FSM says otherwise.

The second line says that the state should remain the same unless we specify a new state.

These types of defaults are very good practice because they will prevent the case where you forget to assign a value to the reg which results in latches and bad things.

Finally, the first case statement is used for determining the next state.

```verilog,linenos,linenostart=32
case (state_q)
  FORWARD: begin
    ctr_d = 25'd0;
    if (sr_q[1]) begin
      state_d = BACKUP_LEFT;
    end else if (sl_q[1]) begin
      state_d = BACKUP_RIGHT;
    end
  end
  BACKUP_RIGHT: begin
    if (ctr_q == {26{1'b1}})
      state_d = TURN_RIGHT;
  end
  TURN_RIGHT: begin
    if (ctr_q == {25{1'b1}})
      state_d = FORWARD;
  end
  BACKUP_LEFT: begin
    if (ctr_q == {26{1'b1}})
      state_d = TURN_LEFT;
  end
  TURN_LEFT: begin
    if (ctr_q == {25{1'b1}})
      state_d = FORWARD;
  end
  default: state_d = FORWARD;
endcase
```

When the counter is found to be high enough, the state transitions from **BACKUP_XXX** to **TURN_XXX**. Once it gets high enough again, it transitions from **TURN_XXX** to **FORWARD**. The counter will overflow during the first transition because it reached the top, and when the FSM reaches the **FORWARD** state the counter is held at 0.

The second case statement is used to generate the outputs based on the current state.

```verilog,linenos,linenostart=60
case (state_q)
  FORWARD: begin
    left = 8'h50;
    right = 8'h50;
  end
  BACKUP_RIGHT: begin
    left = 8'hB0;
    right = 8'hB0;
  end
  TURN_RIGHT: begin
    left = 8'hB0;
    right = 8'h50;
  end
  BACKUP_LEFT: begin
    left = 8'hB0;
    right = 8'hB0;
  end
  TURN_LEFT: begin
    left = 8'h50;
    right = 8'hB0;
  end
  default: begin
    left = 8'h80;
    right = 8'h80;
  end
endcase
```

These are fed to two servo modules (see the [servos tutorial](@/tutorials/archive/verilog/mojo/servos.md)) for more info) and control the wheels of the robot.

### Final Product

Now check out the FSM in action!

{{ youtube(id="eqGPOE-J_CU?si=FoF80eUCaDhFixnF") }}

You can download the full project code [here](https://cdn.embeddedmicro.com/fsm/Mojo-FSM.zip).