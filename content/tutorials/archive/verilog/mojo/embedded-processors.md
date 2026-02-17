+++
title = "Embedded Processors"
weight = 19
+++

This tutorial is an advanced topic and is not recommend for beginners. If you want to write software in your design we recommend using the microcontroller on the Mojo before trying to embed a processor as the tools and setup can be very messy. Checkout [this tutorial](@/tutorials/archive/verilog/mojo/memory-mapping.md) for more information.

This tutorial will outline how to add a **MicroBlaze MCS** to your project. The **MicroBlazeMCS** is a 32bit microprocessor core provided by Xilinx. It will allow you to write **C/C++** code that will interact with the rest of your design. While this can be very helpful in many projects, setting it up can be a bit confusing. This tutorial will hopefully demystify the process.

Like most tutorials here, the first step is downloading the [Mojo Base Project](https://github.com/embmicro/mojo-base-project/archive/master.zip).

### Generating the core

Go ahead and open up your fresh project in **ISE**.

Right click on somewhere in the **Hierarchy** panel on the left and select **New Source...**

Select **IP (CORE Generator & Architecture Wizard)** and set the **File Name** to **microblaze_mcs** and click **Next**.

Expand **Embedded Processing** and **Processor** to find **MicroBlaze MCS**. Choose that and click **Next**.

Click **Finish**.

The configuration wizard should now show up.

![coregen_microblaze.resized.png](https://cdn.alchitry.com/verilog/mojo/coregen_microblaze.resized.png)

In the first tab, **MCS**, change the **Input Clock Frequency** to 50 since we will be running the core at 50MHz.

Take note of the **Instance Hierarchical Design Name,** it is very important later on. For now we'll just leave it at the default **mcs_0**.

Set **Memory Size** to **16KB**. The absolute minimum required for this project is **8KB**, but if you add any extra code, you will want a little more.

The **Memory Size** option is important because it dictates how much memory the processors has to store your code and variables. You will want to use a little memory as possible that will still fit your program since it uses valuable block RAM inside the FPGA.

If you look at the top of the window you will see tabs for all the different peripherals available to you.

In this tutorial, we will be using a timer to control how fast some LEDs blink. That means we will need a **FIT** (**F**ixed **I**nterval **T**imer) and some **GPO** (**G**eneral **P**urpose **O**utputs).

In the **FIT** tab, check the **Use Timer** box.

We want our timer to count the number of **milliseconds** that elapse which will allow us to create a flexible delay function. Since the Mojo uses a 50MHz clock, we want the **Number of Clocks Between Strobes** to be 50,000,000 / 1,000 = 50,000.

We will also want the timer to generate an interrupt, so check the **Generate Interrupt** box.

![coregen-fit.resized.png](https://cdn.alchitry.com/verilog/mojo/coregen-fit.resized.png)

Head over to the **GPO** tab since we need some outputs for the LEDs.

In the **General Purpose Output 1** box check the box **Use GPO**.

We only have 8 LEDs, so change the **Number of Bits** to 8.

The **Initial Value of GPO** is fine as the default.

![gpo_microblaze.resized.png](https://cdn.alchitry.com/verilog/mojo/gpo_microblaze.resized.png)

Those are the only peripherals we need for this project, but feel free to check out the other ones as they may come in handy for your own projects. If you really want to get your feet wet, head over to [Xilinx's documentation](http://www.xilinx.com/tools/mb_mcs.htm).

Click **Generate** to generate the core!

### Adding the core to your project

After the core is done generating (it can take a while), you should see **microblaze_mcs** as a file in your project.

We need to now instantiate this in our design. Open up **mojo_top.v** in your editor of choice.

Click on the **microblaze_mcs** source file and expand **CORE Generator** in the **Processes** panel. Double click on **View HDL Instantiation Template**. This file contains an _example_ instantiation of the core. You can refer to this file to make sure you get all the port names right.

![instantiation_template.png](https://cdn.alchitry.com/verilog/mojo/instantiation_template.png)

It's usually a good idea to just copy/paste it into your design and make the edits you need.

In our case, we need to add it to **mojo_top.v**. The file should look as follows.

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
 
  microblaze_mcs mcs_0 (
    .Clk(clk), // input Clk
    .Reset(rst), // input Reset
    .FIT1_Interrupt(), // output FIT1_Interrupt
    .FIT1_Toggle(), // output FIT1_Toggle
    .GPO1(led), // output [7 : 0] GPO1
    .INTC_IRQ() // output INTC_IRQ
  );
 
endmodule
```

Notice I made the instance name **mcs_0**. This **MUST** match the name you use when you generate the core. If you don't instantiate the core at the top of your design, you must include the path in the name in CORE Gen. For example, if you have your core in a module called **magic_sauce** then the path would be **magic_sauce/mcs_0**.

In our design, we don't care about any of the outputs except **GPO1**, which is hooked up to the LEDs.

The last step is to run the setup script that was generated. Open the **Tcl Console** by clicking **View->Panels->Tcl Console**. In the **Tcl Console** tab near the bottom of ISE, enter the following line and hit enter.

```bash
source ipcore_dir/microblaze_mcs_setup.tcl
```

It should print the following.

```
microblaze_mcs_setup: Found 1 MicroBlaze MCS core.
microblaze_mcs_setup: Added "-bm" option for "microblaze_mcs.bmm" to ngdbuild command...
microblaze_mcs_setup: Done.
```

This changes your project settings to accommodate the new core. Note that these changes don't seem to be persistent and you will likely need to run the script each time you open ISE.

There seems to be a bug in ISE which causes one of these settings to be wrong.

Right click on **Implement Design** in the Processes panel with **mojo_top** selected in the Hierarchy panel. Choose **Properties**.

Under the **Other Ngdbuild Command Line Options** you should see **-bm "ipcore_dir/microblaze_mcs.bmm"**. Replace that with **-bm "../ipcore_dir/microblaze_mcs.bmm"**

### Setting up XPS

Now we need to actually setup XPS, the IDE Xilinx provides that will compile our code.

When you installed ISE, you actually installed XPS too!

If you are using **Ubuntu** then you need to issue the following command because Ubuntu doesn't have a program called **gmake**, which is really just **make**.

```bash
sudo ln -s /usr/bin/make /usr/bin/gmake
```

If you are using **Linux** you can create a snazzy launcher by running the following.

```bash
sudo gnome-desktop-item-edit /usr/share/applications/ --create-new
```

Under **Name** enter **XPS SDK**.

Under **Command** enter **/opt/Xilinx/14.6/ISE_DS/EDK/bin/lin64/xsdk**, note that your version of ISE may vary.

You can find an icon at **/opt/Xilinx/14.6/ISE_DS/EDK/eclipse/lin64/eclipse/plugins/com.xilinx.sdk.product_1.0.0/icons/xps_sdk_32.png**

![](https://cdn.alchitry.com/verilog/mojo/launcher.png)

Once you have **XPS** open, there are a few hoops to jump through before the coding can begin.

### Creating the project

Click **File->New->Other...**

Under **Xilinx** choose **Hardware Platform Specification** and click **Next**.

Enter **MojoDemo** as the **Project Name**. Note that you can't have spaces in your project names.

Under **Target Hardware Specification** click **Browse...** and navigate to the **ipcore_dir**. Select **microblaze_mcs_sdk.xml**.

![xps_hardware_project.resized.png](https://cdn.alchitry.com/verilog/mojo/xps_hardware_project.resized.png)

Click **Finish**.

Now you can create a project for your actual code. Click **File->New->Other...** and choose **Application Project** under **Xilinx**.

Under **Project Name** enter **LED_Controller**.

Make sure that **Hardware Platform** is set to **MojoDemo** and the processor is **microblaze_mcs**.

Under **Target Software** make sure the **OS Platform** is set to **standalone**, **Language** is set to **C**, and **Board Support Package** is set to **Create New -> LED_Controller_bsp**.

![xps_app_project.png](https://cdn.alchitry.com/verilog/mojo/xps_app_project.png)

Click **Next**.

Choose **Empty Application** for a **Template** and click **Finish**.

Open the project folder on the left for your project, **LED_Controller**. Right click the **src** folder and choose **New->Source File**. Enter **LEDBlinker.c** as the file name and click **Finish**.

Open the new file and paste in the following code.

```c
#include <xparameters.h>
#include <xiomodule.h>
 
XIOModule gpo;
volatile u32 ct = 0;
 
void timerTick(void* ref) {
  ct++; // increase ct every millisecond
}
 
void delay(u32 ms) {
  ct = 0; // set the counter to 0
  while (ct < ms) // wait for ms number of milliseconds
    ;
}
 
int main() {
  XIOModule_Initialize(&gpo, XPAR_IOMODULE_0_DEVICE_ID); // Initialize the GPO module
 
  microblaze_register_handler(XIOModule_DeviceInterruptHandler,
                              XPAR_IOMODULE_0_DEVICE_ID); // register the interrupt handler
 
  XIOModule_Start(&gpo); // start the GPO module
 
  XIOModule_Connect(&gpo, XIN_IOMODULE_FIT_1_INTERRUPT_INTR, timerTick,
                    NULL); // register timerTick() as our interrupt handler
  XIOModule_Enable(&gpo, XIN_IOMODULE_FIT_1_INTERRUPT_INTR); // enable the interrupt
 
  microblaze_enable_interrupts(); // enable global interrupts
 
  u8 leds = 0;
  while (1) {
    // write the LED value to port 1 (you can have up to 4 ports)
    XIOModule_DiscreteWrite(&gpo, 1, leds++);
    delay(1000); // delay one second
  }
}
```

This code works by first initalizing the GPO module, fixed-interval timer, and interrupts. The fixed-interval timer is setup to fire an interrupt every millisecond which will call our interrupt handler, **timerTick**. Each time **timerTick** is called, it increments a global variable **ct**. The **delay** function uses **ct** to delay for specified number of milliseconds.

It is worth looking at the other templates when you create a project to get an idea of some other functions you can use.

Find the hammer icon on the top tool bar to build the project and generate an **.elf** file. This is the file that tells ISE how to program the processor.

### Adding the .elf file to your project

There is one last command to run to finish the project setup.

Back in ISE, go to the **Tcl Console** again and enter the following command.

```bash
microblaze_mcs_data2mem /path/to/project/LED_Controller/Debug/LED_Controller.elf
```

Note that you will have to replace **/path/to/project** with your actual path.

It should output something similar to the following.

```
microblaze_mcs_data2mem: Found 1 MicroBlaze MCS core.
microblaze_mcs_data2mem: Using "LED_Controller.elf" for microblaze_mcs
microblaze_mcs_data2mem: Added "-bd" options to bitgen command line.
microblaze_mcs_data2mem: Running "data2mem" to create simulation files.
microblaze_mcs_data2mem: Bitstream does not exist. Not running "data2mem" to update...
microblaze_mcs_data2mem: Done.
```

You can now double click **Generate Programming File** to generate a **.bin** file that you can load onto your Mojo.

If all went well you should now see the LEDs counting the seconds.

### Editing the code

If you want to edit the code in **XPS** all you have to do after building the project is re-run the **Generate Programming File** stage in ISE to update the **.bin** file. You don't need to re-run **Synthesize** nor **Implement Design**.