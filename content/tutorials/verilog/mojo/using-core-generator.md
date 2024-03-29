+++
title = "Using Core Generator"
weight = 16
+++

Core Generator (also called **CoreGen**) is a powerful tool provided by Xilinx to help easily and efficiently accomplish some common functions. It allows you to generate modules for things like RAMs, ROMs, clock synthesis, complicated math functions, and even basic processor cores.

This tutorial will show how we used CoreGen to perform some complicated math and generate the block RAMs used in our [Clock/Visualizer Shield Demo](https://cdn.embeddedmicro.com/clock-shield/Mojo-Clock.zip). If you haven't already, you should download the project so you can follow along.

After you download the project, open it up in ISE.

Once in ISE, to access CoreGen, click on **Tools->Core Generator...**

This will automatically open the CoreGen project file for the Clock/Visualizer Shield.

![CoreGen_main.resized.png](https://cdn.alchitry.com/verilog/mojo/CoreGen_main.resized.png)

On the left hand side of the window, you have the cores that are available to be generated on the top and the cores being used in the project on the bottom left. On the right is information about the currently selected core.

You can see for this project we used 8 cores. Four of them are RAMs, one performs a square root, one is a decimation filter, another is a FIFO, and the last is the one that performs the Fourier Transform.

Let's start with one of the most commonly used cores, block RAM. Double click on **sample_ram**.

![CoreGen_sample_ram.resized.png](https://cdn.alchitry.com/verilog/mojo/CoreGen_sample_ram.resized.png)

This RAM is used to store the samples from the microphone before they are ready to be processed. If you take a look at the diagram on the left you can see the module's inputs and outputs.

This module has inputs **ADDRA\[9:0]**, **DINA\[15:0]**, **WEA\[0:0]**, **CLKA**, **ADDRB\[9:0]**, **CLKB** and output **DOUTB\[15:0]**. As you may be able to tell, this RAM is a **simple dual port RAM**. That means that it has two independent ports, one for writing and one for reading. This allows for different address to be read and written simultaneously.

If you look at the bottom of the window you will see **< Back** and **Next >** buttons. You can use these to go through the various pages of configuration options. On the second page you can see where we set the **Memory Type** to be a **Simple Dual Port RAM**.

![CoreGen_ram_page_2.resized.png](https://cdn.alchitry.com/verilog/mojo/CoreGen_ram_page_2.resized.png)

On the same page there are also options to tell CoreGen what to optimize when generating your RAM. We have **Minimum Area** selected, which is the most important constraint in most cases.

As you go through the configuration settings, you'll find settings for each port's **width** and **depth**. The **width** of a RAM is how many bits belong to each address. In this case, we use 16 bits as our width since the audio samples are 16 bits wide. The **depth** is how many address the RAM will have. While you don't strictly need to use a power of two for this, it can make life simpler because then you don't have any invalid addresses.

Once you configure a core how you want, just click the **Generate** button to get CoreGen to generate the core.

You should look at the other cores used in the project as well as the other cores available to you in your own projects. One thing to be aware of is that **not all cores are free**. Xilinx does a good job of providing a good base of free cores that cover a lot of functionality, but fancier cores such as the cores found in **Standard Bus Interfaces,** require you to purchase a license to use them in the FPGA (you can generally simulate with them, but that's no fun).

### Adding cores to your project

After you have generated your core, it's still not in your project! First close CoreGen and go back to ISE.

Since all the cores we are using in the Clock/Visualizer Shield Demo are already added, you'll get errors if you try to add it again. However, we'll do it anyways to show you how it's done.

Most cores will have two files you need to add to your project, a **.v** file and a **.ngc** file. It's very important to have both, because the **.ngc** file is the one that actually has the information about the implementation of the core. The **.v** file is used as a kind of glue to connect the **.ngc** to your project.

Click on **Project->Add Source**

Navigate to where your cores were generated, in this case it's in the folder named **ipcore_dir**.

![CoreGen_Adding_Core.png](https://cdn.alchitry.com/verilog/mojo/CoreGen_Adding_Core.png)

Select the two files for your core and click open. This will add them to your project, but like we said before, these are already in the project so it gives you an error.

### Using your cores

Once you've created your core and added it to your project, you need to actually use it!

If you look in the **ipcore_dir** folder and open up the **.veo** file for your core, you will find an example on how to instantiate the core.

There are a lot of comments in the file but here is the important content of the **sample_ram.veo** file

```verilog,linenos,linenostart=49
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
sample_ram your_instance_name (
  .clka(clka), // input clka
  .wea(wea), // input [0 : 0] wea
  .addra(addra), // input [9 : 0] addra
  .dina(dina), // input [15 : 0] dina
  .clkb(clkb), // input clkb
  .addrb(addrb), // input [9 : 0] addrb
  .doutb(doutb) // output [15 : 0] doutb
);
// INST_TAG_END ------ End INSTANTIATION Template ---------
```

You can just copy and paste this into your project to use the **sample_ram** module. Of course, you still need to specify the correct inputs and outputs.

That's it! Using CoreGen is a great way to get some of the heavy lifting in a project done for you and in a very efficient way.