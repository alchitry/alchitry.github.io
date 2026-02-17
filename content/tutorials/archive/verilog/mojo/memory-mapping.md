+++
title = "Memory Mapping"
weight = 17
aliases = ["tutorials/verilog/mojo/memory-mapping.md"]
+++

This tutorial covers a common technique for interfacing a peripheral to a processor known as **memory mapping**. Memory mapping is were you break out a set of functions or settings and map them to a set of values that are selected by a given address. Typically the master is able to read and write these values however it chooses much like a block of RAM. However, these values aren't just blocks of memory, they effect some external device. Because this is used for interfacing it is sometimes called **memory mapped IO**.

### Memory mapped IO in processors

The most common place you see memory mapped IO is inside a processor. Actually, if you've ever programmed an Arduino or other microcontroller, chances are you have already been exposed to this technique.

A great example is the **PORT** registers of an ATmega microcontroller (the ones used by Arduino). When you write code for these processors you can write something like the following.

```c
PORTB = 0xAA;
```

This will set the 8 IO pins designated to **PORTB** to the value 0xAA. However, in your code **PORTB** is actually just a macro and is really a pointer to a special memory address. This address in memory doesn't simply map to RAM but also maps to an IO peripheral that takes the value and outputs it to the IO pins.

Without memory mapped IO, the microcontroller would have no way to input or output any data!

This example of an IO port is very simple, but the devices that are memory mapped can literally be anything. Pretty much all processors use this technique, including your computer. Everything in your computer is memory mapped to the CPU. When you install a driver on your computer, you are installing the piece of code responsible for reading and writing values to these special memory locations to make the device work.

### Memory mapping the FPGA

The microcontroller on the Mojo doesn't have an external RAM interface so we can't map the FPGA directly to its memory space. However, the FPGA is connected over an SPI bus and we can use that!

Before we dive into how we are going to do this, download the two demo projects for this tutorial.

- [FPGA Project](http://cdn.embeddedmicro.com/mem_map/Mojo-Arduino.zip)
    
- [Arduino Project](http://cdn.embeddedmicro.com/mem_map/mojo_mem_map.zip)
    

This tutorial is a little bit different from the rest of the tutorials in that these two projects are already ready to go. You don't have to make any modifications before building them. This is because this tutorial is not to show how cool it is to make some LEDs blink (it's super cool I know), but rather as a starting point for interfacing the FPGA and Arduino together. I recommend downloading these two projects every time you want to start a new project that interfaces the two devices and start modifying it.

## The FPGA side of things

In the FPGA project, open up **mojo_top.v** and take a look at the basic setup. There are two modules instantiated, **avr_interface** and **reg_ctrl**.

**avr_interface** is responsible for all the communications with the Arduino (AVR, ATmega, and Arduino are basically the same in this context). This is a modified version of the module found in the base project. It has been modified to provide a basic register interface over SPI instead of allowing the FPGA to read the ADC ports. You should also note that the pins that used to be **adc_channel** are now **avr_flags**. These will be covered in detail more later.

You can open up **avr_interface** to checkout how the register interface is implemented. The basic protocol is as follows.

![mem_map_write.png](https://cdn.alchitry.com/verilog/mojo/mem_map_write.png)

![mem_map_read.png](https://cdn.alchitry.com/verilog/mojo/mem_map_read.png)

The transfer starts by the AVR pulling **CS** (**C**hip **S**elect) low. The first byte sent specifies what type of transfer (read or write), if the address is auto-incremented, and the address. The following bytes are the values that are read or written to the corresponding addresses. If **inc** is 1, B1 is from **addr**, B2 is from **addr + 1**, and Bn is from **addr + n - 1**. If **inc** is 0, then the same address is read or written multiple times. If the transfer is for a single address, **inc** doesn't make a difference. A transfer is terminated by **CS** going high.

For example, to write 0xAA to address 0x00, we would send 0x80 (write address 0) followed by 0xAA. To write 0xAA to address 0 and 0xBB to address 1, we would send 0xC0 (write, auto-inc, address 0), 0xAA, 0xBB. It's the same pattern for reads except the values are read on **MISO** instead of written to **MOSI**.

You don't really have to really worry about this protocol since the example code covers both ends of the communication. You simply specify the address and values. However, it is useful to know so you can write your own mutli-byte transfer functions using auto-inc for efficiency.

### Defining the addresses

All the address definitions are in the the module **reg_ctrl**. Open up **reg_ctrl.v** and take a look.

The demo code only has one valid address, address 0. That address is used to read the write values to the LEDs.

```verilog
if (new_req) begin
  if (write)
    case (reg_addr)
      6'h00: led_d = write_value;
    endcase
  else //read
    case (reg_addr)
      6'h00: read_value_d = led_q;
    endcase
  end
```

This block of code is what actually makes address 0 correspond to the LEDs. There is a group of flip-flops **led_d/q** that are connected to the LEDs. When the address is 0 and it's a write, the value of this flip-flop is updated with the **write_value**. When the address is 0 and it's a read, the **read_value_d/q** flip-flops are set to the value of **led_q**. Those flip-flops provide the data for the next SPI transfer. Since the FPGA is clocked at 50MHz and the SPI bus is substantially slower at 4MHz, the FPGA has a few clock cycles to prepare the read data before it is needed. This can be helpful if your read can't be done instantly, unlike this case.

## The Arduino side of things

In the Arduino project, the code for the demo is pretty short and simple.

First take a look at the **registers.h** file. In this file I defined **LED_REG** to be the address of the LEDs, or 0x00. Using this file to define all the address in your design will make it much easier if you ever need to move things around.

Now take a look at **fpga_interface** as shown below.

```c
void writeReg(uint8_t addr, uint8_t value){
  SET(SS, LOW);
  SPI.transfer(0x80|(addr&0x3F));
  SPI.transfer(value);
  SET(SS, HIGH);
}
 
uint8_t readReg(uint8_t addr){
  SET(SS, LOW);
  SPI.transfer(0x00|(addr&0x3F));
  uint8_t v = SPI.transfer(0xff);
  SET(SS, HIGH);
  return v;
}
```

These two functions implement the basic protocol outlined earlier. They only allow for transfers of a single byte and don't use the auto-inc signal at all. If you need to read or write many addresses you should add your own functions in this file that can effienctly interface with your FPGA design.

Now for the brains of the operation. Take a look at the main file, **mojo_mem_map**. Most of the code in this file is just used for loading the FPGA, however, the functions **userLoop()** and **userInit()** are your's to mess with. It's important to try and keep the **userLoop()** execution time low (no while(1) loops) so that the Mojo Loader can get the Mojo's attention before it times out. If it does timeout, a quick retry usually will be enough to get it to work.

```c,linenos,linenostart=30
void userLoop() {
  static unsigned long time = 0;
 
  if (time == 0)
    time = millis();
 
  long curTime = millis();
  // use millis to determin the elapsed time insted of using delay() becuase
  // this will allow the Mojo to stay responsive to the Mojo Loader
 
  // if 100ms have elapsed write to the LEDs
  if (curTime > time + 100) { 
    uint8_t leds = readReg(LED_REG) + 1;
    writeReg(LED_REG, leds);
 
    time = curTime;
  }
}
```

This demo code simply reads the value of the LED address and adds one to it. That new value is written back to the LED address. This happens every 100ms thanks the **millis()** function. The **delay()** function isn't used because that would block execution and delay the Mojo from entering loading mode when requested. In this case a 100ms delay really wouldn't hurt anything, but this is shown as a best practice.

If you load the FPGA and the Arduino with the demo code, the LEDs should start counting up.

### AVR Flags

There are four signals named **avr_flags** that are just general purpose pins that connect the FPGA and AVR. These are great when the AVR is waiting for the FPGA to do something, or for the FPGA to get the AVR's attention. They are configured as inputs to the AVR (outputs of the FPGA) in the demo project.

They can be hooked up anywhere in your design to signal the status of some process.

To read the flags on the AVR you can use code like this.

```c,linenos,linenostart=191
uint8_t flags = (FLAGS_PIN & FLAGS_MASK) >> FLAGS_OFFSET;
if (flags & 0x01) {
  // flag 1 is set!
}
```

**flags** holds the value of all four flags so you can test for each one individually or some combination.

### Conclusion

So what can you use this for? You can basically turn the FPGA into any peripheral you can imagine for your Arduino projects. For a more advanced example on how to use this in your own projects, check out the [hexapod](@/tutorials/projects/hexapod.md) which uses this extensively. The FPGA in this project basically becomes a servo controller and a blob detection sensor. The Arduino code doesn't have to know anything about the camera, it just receives blobs that are detected in the images.