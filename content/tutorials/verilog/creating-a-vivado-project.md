+++
title = "Creating a Vivado Project"
weight = 1
+++

This tutorial is to get you familiar with how to create a project and the very basics of Verilog.

Before starting this tutorial, make sure you have setup Vivado by following this [tutorial](@/tutorials/setup/vivado.md). You'll need to install the [Alchitry Loader](@/alchitry-labs.md) as well.

You will need to download the base project available [here](https://github.com/alchitry/Au-Base-Project/archive/master.zip), or check it out from [GitHub](https://github.com/alchitry/Au-Base-Project).

Extract that file to where you want to keep your projects. It is a good starting point for any project created for the Alchitry Au.

The file structure is as follows.

- Au-Base-Project
- au_base_project.ip_user_files - _where IP cores will go that you generate_
- au_base_project.hw - _used by Vivado_
- au_base_project.src - _where you put all the files you write_
- au_base_project.xpr - _the Vivado project file_

Open up Vivado and click Open Project under the Quick Start menu and find the au_base_project.xpr file you extracted.

![Screenshot_from_2019-07-02_09-58-48.png](https://cdn.alchitry.com/verilog/mojo/Screenshot_from_2019-07-02_09-58-48.png)

It should now look something like this.

![](https://cdn.alchitry.com/verilog/mojo/Screenshot_from_2019-07-02_09-59-39.png)

For your very first project, we are simply going to wire up the reset button to one of the LEDs on the board. We will make it so the LED will turn on when you push the button. 

Go ahead and double click on the left where it says **au-top (au-top.v)** under the Sources panel. The file should open on the right and you should see the following code.

```verilog,linenos
module au_top(
    input clk,
    input rst_n,
    output[7:0] led,
    input usb_rx,
    output usb_tx
    );
 
    wire rst;
 
    reset_conditioner reset_conditioner(.clk(clk), .in(!rst_n), .out(rst));
 
    assign led = rst ? 8'hAA : 8'h55;
 
    assign usb_tx = usb_rx;
 
endmodule
```

Let me explain what each part of the code does.

### Port declarations

```verilog,linenos
module au_top(
    input clk,
    input rst_n,
    output[7:0] led,
    input usb_rx,
    output usb_tx
    );
```

This is the **port declaration**. This tells what signals are going in and out of the module. Remember we are designing circuits, not writing code, so it is good to think of each module as a block that has some inputs and generates some outputs. For now we only are interested in the **rst_n** input and the **led** outputs.

In Verilog there are two data types, **wire** and **reg**. The default in a port declaration is a wire. For now, we will only be working with wires and regs will be covered in the next tutorial. 

You may have noticed this line.

```verilog,linenos,linenostart=4
output[7:0]led,
```

This is not a single output but actually 8! You can create an array of wires (or regs)  by using those brackets. What **[7:0]** actually means is that led will be an array of eight wires that have an index from 7 down to 0, inclusive. 

It is possible to do [8:1] or [0:7], but unless you have a **very very** good reason for doing that then you should stick to the convention. Mixing what you used as a base index and the order can create major headaches.

### Declaring a wire

This brings us to the first line after the port declaration. 

```verilog,linenos,linenostart=9
wire rst;
```

In this line we are declaring a new wire called rst.

In this case, we are declaring a one bit wire. However, you can declare an array of wires (sometimes also called an n-bit wire where n is the width of the array) with the following line.

```verilog
wire [9:0] array;
```

In this case, we would now have a 10-bit wire called array.

You could also assign the wire a value when declaring it like the following.

```verilog,linenos,linenostart=9
wire rst = ~rst_n;
```

It is a common convention to name signals that are active low (meaning a 0 is active) by appending **_n** to the end of their name. Following that convention, **rst_n** is active low, but we want an active high signal. To make **rst** an active high version of **rst_n** we can just invert **rst_n**. The **~** operator is the **not** operator. 

However, we don't really want to do this since we need to condition our reset signal. This is because the reset signal comes from an external source and isn't synchronized with our clock. Don't worry about this for now. It'll be covered later.

### Instantiating a Module

To take care of the reset conditioning, we have a module called the _reset_conditioner_ that will do all the magic for us.

```verilog,linenos,linenostart=11
reset_conditioner reset_conditioner(.clk(clk), .in(!rst_n), .out(rst));
```

The first _reset_conditioner_ is the name of the module we want to instantiate, the second _reset_conditioner_ is the name of this particular instance. The name you give the instance isn't particularly important. Just name it something descriptive so the hierarchy of your project is easy to understand. Using the same name for the instance and the module type is common when you only have one instance of it.

The next part of the declaration wires up the inputs and outputs to signals in our design. The name following the period is the name of the module's port. The name in the parenthesis is the signal we are connecting it to.

The notable ones here are we are connecting _!rst_n_ to _in_ and _out_ to _rst_. The ! in front of _rst_n_ negates it just like the ~ from before. Both the ! and ~ operators are defined as **not** (meaning inverting). However, the ! is a _logical not_ while the ~ is a _bitwise not_. For a single bit like _rst_n_ they are interchangable. The difference will be covered more later.

The _rst_ wire we declared earlier is connected to the module's output. We can then use _rst_ in the rest of our design.

### Assigning a value

There are many times where you want to assign a value to a wire that is already declared somewhere else. In this case, you can use the **assign** keyword.

```verilog,linenos,linenostart=13
assign led = rst ? 8'hAA : 8'h55;
```

Now is a good time to introduce constants in Verilog. A constant looks something like **8'hD5**, **5'd61**, or **4'b0101**. In these three cases, you can tell how many bits wide each constant is by the first number. The first one is 8 bits, the second 5, and the third 4. This is important because you usually want the constant's width to match the signal you are assigning it to. 

The second part of the constant is the base for the number. A **h** means the number is in hex, a **d** means it's decimal, and **b** means it's binary. The rest of the constant is the actual value.

There are actually two special values a bit can have, **Z** and **X**. Z means that the wire is high-impedance, or disconnected. X means that we don't care about the value, or the value is unknown (when you do simulations).

It's important to know that an FPGA can't realize internal high impedance signals. You should typically avoid using Z unless it directly connects to a top-level output (or inout) where the FPGA can set the pin to high impedance. If you use them internally, the tools will fake it with "enable" signals which will result in a sub-optimal design.

It is helpful to assign a value of X when you don't care since it will allow the tools to set whatever value it wants at that time. This gives them a bit more freedom to optimize. Note that a value of X can't actually exist in hardware. A bit will always be 0 or 1.

Now, let's look a bit closer at the assign statement.

```verilog,linenos,linenostart=13
assign led = rst ? 8'hAA : 8'h55;
```

Ok, so what is going on here? We are using the **ternary** operator to select between two values to assign to _led_. The ternary operator is like an **if** statement and is realized in hardware with a multiplexer. If the value of the part before the **?** is true (non-zero) then the value directly following it is used. If it is false (zero), then the value after the **:** is used. In this case, when _rst_ is 1 (button pressed), the we use the value _8'hAA_. When it is 0 (button released), we use _8'h55_.

The last line in this module assigns _usb_tx_ to be _usb_rx_. This simply loops any serial data we receive. Since we aren't using these it is a reasonable default,.

### Creating a bin file

It is now time to take our project and create a bin file that we can load onto the Au. To do this, find the **Generate Bitstream** entry under **PROGRAM AND DEBUG** on the way left of the window. Double click on it and the build cycle will start.

In the top right corner, you will see the stage that is being run. It will run through three main build stages, synthesis, implementation, and bitstream generation.

Synthesis is where the tools look at your design and convert into a more abstract circuit representation.

Implementation is taking that circuit and laying it out in the FPGA using the actual hardware resources available.

Bitstream generation is taking the implemented design and creating a file that can be used to configure the FPGA.

Once Vivado has finished building the project it should look like this.

![Screenshot_from_2019-07-02_10-35-23.png](https://cdn.alchitry.com/verilog/mojo/Screenshot_from_2019-07-02_10-35-23.png)

### Loading the bin file

Once you open up the Alchitry Loader, select the .bin file created by Vivado. You can find it under _au_base_project.runs/impl_1/au_top.bin_.

Make sure _Alchitry Au_ is selected as the board.

You can check _Program Flash_ if you want the configuration to be stored on the board for use after a power cycle. If you uncheck this, it will only be configured until it loses power.

![Screenshot_from_2019-07-02_10-39-29.png](https://cdn.alchitry.com/verilog/mojo/Screenshot_from_2019-07-02_10-39-29.png)

Click _Program_ and your design will begin to transfer to the Au!

Once it has transferred, try pressing the reset button. When you push the button the LEDs will flip states (off->on, on->off).

Congratulations, you've completed your first project!