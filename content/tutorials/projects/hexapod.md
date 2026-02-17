+++
title = "Hexapod"
weight = 2
+++

![DSC_0166.resized.jpg](https://cdn.alchitry.com/projects/hexapod/DSC_0166.resized.jpg)

This hexapod is fully controlled by a single Mojo leveraging the power that an FPGA provides. It consists of an aluminum frame (purchased from MicroMagic Systems which no longer seems to exist), 20 servo motors (12x HS-645MG, 7x HS-225MG, 1x HS-322HD), a Mojo V3 with an SDRAM Shield, Servo Shield, and a custom camera shield. The camera used is an OV2640. 

### Example Designs

[**Arduino Project**](http://cdn.embeddedmicro.com/hexapod/Mojo-Hexapod-Arduino.zip) - The following FPGA projects assume that this project is loaded onto the ATmega32U4. The microcontroller is responsible for calculating the angles of the legs for the FPGA.

[**Image Capture**](http://cdn.embeddedmicro.com/hexapod/Mojo-Hexapod-Capture.zip) - This design will take a snapshot from the camera and store it in SDRAM. The image can then be read out to your computer through the ATmega32U4. I used a simple Java program to do this. The Eclipse project is below.

[**Image Capture Java Program**](http://cdn.embeddedmicro.com/hexapod/ImageCapture.zip) - This is the Eclipse project for a simple Java program that will interface with the Mojo to capture and show an image. The image can then be saved as a PNG.

[**Blob Tracking**](http://cdn.embeddedmicro.com/hexapod/Mojo-Hexapod-Blob.zip) - This design uses the camera to detect red blobs. The color of the blob can be set in the **color_threshold.v** file. For more information see below.

### More Images

![DSC_0198.resized_large.jpg](https://cdn.alchitry.com/projects/hexapod/DSC_0198.resized_large.jpg)

![DSC_0144.resized_large.jpg](https://cdn.alchitry.com/projects/hexapod/DSC_0144.resized_large.jpg)

![DSC_0181.resized_dfaaaf80-fad4-4e2e-b9df-42009b1c83f5_large.jpg](https://cdn.alchitry.com/projects/hexapod/DSC_0181.resized_dfaaaf80-fad4-4e2e-b9df-42009b1c83f5_large.jpg)

![DSC_0172.resized_large.jpg](https://cdn.alchitry.com/projects/hexapod/DSC_0172.resized_large.jpg)

## Blob Tracking

{{ youtube(id="KxeSHZFrkOw?si=FpYJ0RTmOG-YkKYP") }}

You can download the complete FPGA project and Arduino project below.

- [FPGA Project](http://cdn.embeddedmicro.com/hexapod/Mojo-Hexapod-Blob.zip)
- [Arduino Project](http://cdn.embeddedmicro.com/hexapod/Mojo-Hexapod-Arduino.zip)

### Overview

The flow of this design is as follows.

1. The camera is configured to output 1600x1200 images at its full 15 FPS.
2. The camera starts streaming frames to the FPGA
3. Each pixel is converted from RGB to HSV (**H**ue **S**aturation **V**alue)
    1. The HSV value is compared to some preset values to determine if the pixel is a _red_ pixel
    2. _Red_ pixels are converted into a 1 while non-red are converted into a 0
4. In each row, groups of red pixels are joined together to form **runs**
    1. A run consists of the starting and ending indices of the group
5. Each run is compared to the previous row's runs
    1. If the runs overlap then the new run takes on the label of the overlapping run
    2. The associated object properties are updated including bounding box, center of mass, and mass (number of pixels)
6. If the new run has already been labeled, but overlaps with another run of a different label, the two objects are joined
    1. The second object becomes a pointer to the first and their properties are merged
    2. Any updates to the now invalid object are redirected
7. If an object has not been updated after an entire row, it is considered to be finished
    1. Finished objects are written to SDRAM if their mass is greater than a preset size
8. Once a frame has finished processing, a pin connecting to the microcontroller is pulled high
    1. The microcontroller reads the objects from the SDRAM through the FPGA using SPI and picks the largest one
    2. It calculates new angles for all the servos so that the robot will look towards the object
    3. The new servo values are sent back to the FPGA to update the PWM signals

### Interfacing with the camera

The camera used in this project is the OV2640. This is a decent camera for the price, but that's assuming you can get it configured properly.

The datasheet for this camera leaves a lot to be desired. The actual recommended configuration is completely missing. However, after visiting the _second_ page of a Google search, I was able to find a C header that defined various configurations for the camera used in the Linux kernel. I took the header and modified it a bit to make a C program that would print out text that could be used in a Verilog ROM. You can download the source for that program [here](http://cdn.embeddedmicro.com/hexapod/ov2640reg.zip).

In that program you can set the resolution and format you want, but unfortunately, even at lower resolutions you still only get 15 FPS since that driver simply sets the camera up to scale the images instead of changing the mode.

Take a look at the **ov2640_reg.v** file to see the register configuration. The first value in each entry is the address while the second value is the actual value. Don't ask me what these values do because I have no idea. Most of them are marked _Reserved_ in the datasheets I've seen, but this configuration works.

Note that if you change the ROM make sure to update the **REG_COUNT** localparam in **ov2640.v** to reflect the number of entries.

Take a look now at the **ov2640.v** file. This is the actual interface to the camera. There are two important possibly unusual pieces of code here.

```verilog
// This is used to drive the camera clock
ODDR2 #(
    .DDR_ALIGNMENT("NONE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
  ) ODDR2_inst (
    .Q(xclk), // 1-bit DDR output data
    .C0(cam_clk), // 1-bit clock input
    .C1(~cam_clk), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D0(1'b1), // 1-bit data input (associated with C0)
    .D1(1'b0), // 1-bit data input (associated with C1)
    .R(1'b0), // 1-bit reset input
    .S(1'b0) // 1-bit set input
  );
```

This is used to drive the clock signal xclk out to the camera. In the FPGA clock signals can't be routed like data signals so you have to use an **ODDR** (**O**utput **D**ouble **D**ata **R**ate) block. Typically these blocks are used to output data on the rising and falling edges of a clock (hence _double_ data rate). However, here we fix the data as 1 and 0 so that it toggles with the clock. This same trick was used with the [SDRAM controller](@/tutorials/archive/lucid_v1/mojo/sdram.md).

The clock **xclk** is generated in **mojo_top.v** by the module **sdram_clk_gen**. This module was generated using [CoreGen](@/tutorials/archive/verilog/mojo/using-core-generator.md)  and it takes the 50MHz clock from the on board crystal and generates a 100MHz clock and a 20MHz clock. The 100MHz clock is used as the general system clock as well as the clock for the SDRAM (hence the name of the module). The 20MHz clock is only used to feed the camera and is actually not used for anything else.

The second piece of possibly new code is used because the camera outputs data with its own internal clock. The camera takes that 20MHz clock and boosts it to around 30MHz and uses that to output data. That means the FPGA can't simply clock data in using its internal clock because of possible [meta-stability problems](@/tutorials/archive/verilog/mojo/metastability-and-debouncing.md).

```verilog
camera_fifo camera_fifo (
    .rst(rst), // input rst
    .wr_clk(pclk), // input wr_clk
    .rd_clk(clk), // input rd_clk
    .din({vsync,href,data}), // input [9 : 0] din
    .wr_en(1'b1), // input wr_en
    .rd_en(rd_en), // input rd_en
    .dout({vsync_fifo,href_fifo,data_fifo}), // output [9 : 0] dout
    .full(), // output full
    .empty(empty) // output empty
  );
```

To prevent any clocking problems, a dual clock **FIFO** (**F**irst **I**n **F**irst **O**ut) buffer is used. This module was also generated using CoreGen.

A FIFO buffer as two ports, an input and and output. Data goes into the FIFO through the **din** input and is added to the buffer every time **wr_clk** rises. The **empty** signal goes low where there is data in the buffer. To data can then come out of **dout** in the order that it was written to **din** but this time the data is clocked with **rd_clk** instead of **wr_clk**. This makes FIFOs an excellent tool for crossing clock domains.

It's important to note that you need to read the data from the FIFO at least as fast as you write it (on average) so that the buffer does not overflow. In this case the read clock is 100MHz while the write clock is only 30MHz so that isn't a problem.

The rest of this module is pretty straight forward. It simply takes the signals from the camera and outputs signals for the end of each frame and line as well as each new pixel.

### Color conversion

The data output from the camera is in **RGB565** (5 bits **R**ed, 6 bits **G**reen, 5 bits **B**lue) format. However, we want to cover this to **HSV** since that will make it easier to tell what color the pixel is. This is done in the **rgb_to_hsv.v** file. This module is based on [this module](http://web.mit.edu/6.111/www/f2011/tools/rgb2hsv.v) from MIT. The divider modules are generated again by CoreGen.

The dividers have a latency of 18 clock cycles so the total module has a latency of 19 clock cycles! However, it is fully pipelined so that it can accept a new value every clock cycle. In this case we don't really care about latency too much since it just delays the data by minuscule amount with no chance of dropping any data.

The **color_threshold.v** file holds the code that converts the HSV value to a 0 or 1 depending on its color. Line 52 is where you would change the values if you wanted to track a different color.

```verilog
assign pixel = (h < 5 || h > 245) && s > 115 && s < 210 && v > 30;
```

The **pipeline** module you see being used all over the place is simply a parameterizable module that consists of a bunch of flip-flops chained together. It will simply delay the data by **LENGTH** number of clock cycles. This is useful when you have some data you want to keep paired up with other data that is being processed.

### Finding runs

The **run_finder** module in **run_finder.v** is responsible for taking the binary pixels from **color_threshold** and grouping them into runs. This is a fairly straightforward task with a few edge cases. If a run is still going when the end of a row happens, the run must be finished and output.

The runs from **run_finder** may not be able to be processed immediately by the blob detector so they are buffered by a FIFO in **run_fifo_manager.v**. The format of the runs is slightly changed so that they are easier to handle in blob detector. Each entry in the FIFO is either a new run, the end of a line, or end of the frame.

Since it is possible that an end of line/frame happens at the same time as a new pixel, the module is setup to write new pixels first, then end of lines, and finally end of frames.

### Blob detection

This is where the real magic happens. The file **blob_detector.v** is where a stream of runs are converted into objects.

The blob detection algorithm is based on [this article](http://www.electronics.dit.ie/staff/aschwarzbacher/research/mpc08-1Blob.pdf) with a few modifications. This paper is worth reading if you are interested in how this actually works. It's important to have a firm understanding of what is happening before diving into the code.

The basics of what happens is that each new run is compared to a list of runs from the previous row. Each previous run has a label that points into a RAM that temporarily stores the objects being processed. If a new unlabeled run overlaps with a run in the previous row, that run gets the label of the previous run and the object is updated in the RAM to include the new run. If the run is already labeled but overlaps with a run of a different label, the two objects are joined together in the object RAM and the second object is set to point at the first object. That way if any runs overlap with rows that belong to the now invalid object, they can be redirected to the valid merged object. If a run does not overlap with any other runs, it is assumed to be a new object and space is allocated in the object RAM.

To keep track of used and unused objects in the object RAM, two linked lists are maintained. Initially, each entry in the RAM is setup as an unused object and is set to point to the next object. When a new object is created it takes the first element in the list and adds it to the used object list. These linked lists are maintained so that it is easy to keep track of where an unused object is as well as iterate over all the used objects.

After a row is finished, each object in the used object list is marked as **not-updated**. After the next row, each object is checked to see if it was marked **updated**. If it was, it is simply marked **not-updated** again. However, if the object was not updated, that means that that object will never be updated again and should be removed from the RAM to make space for more objects.

When this happens, the unused and used object lists are updated. If the removed object is larger than the **MIN_SIZE** parameter, then it is written to SDRAM.

Once an end of frame is detected, all the valid objects still in the object RAM are flushed out and written to SDRAM if they are large enough. Finally the number of total objects output is written to the SDRAM and the module signals it has finished.

### Arduino code

The microcontroller simply waits for the FPGA to signal that new data exists by pulling one of the shared pins high. There are four pins that can be used for anything. These are called the **flag** pins in this design. Only the first of the four is used.

Once the microcontroller knows that data is ready, it uses the SPI interface that connects it to the FPGA to read that data that is in the SDRAM. The actually details of how this happens will be covered in another tutorial. However, you can take a look at the **fpga_interface** file for the functions used. It basically works by memory mapping some functions in the FPGA and allowing them to be read and written over SPI. One of these functions is reading and writing to the SDRAM. The microcontroller tell the FPGA the address it wants to read and the result shows up in four other registers (since it has a 32 bit interface that equals 4 bytes) that can then be read.

First the number of objects is read. Then for each object it's size/mass is read and if the mass is larger than the previously seen largest object, the rest of the object properties are read.

Finally once all the objects have been read, only the largest objects data is actually kept. This is used to calculate a new position for the servos.

In between samples from the FPGA, the servos are moved smoothly to the last known target. This allows the robot to move smoother than would normally allow, given 15 frames per second from the camera.

The values calculated for the servos are written to the FPGA over SPI using the same memory mapped design. The module **reg_ctrl.v** shows the actual memory mapping used.