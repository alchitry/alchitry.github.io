+++
title = "Camera"
weight = 11
+++

In this tutorial we will go over how to use the Camera Shield and SDRAM Shield to capture images, but first, let me take a selfie!

![robotselfie.jpg](https://cdn.alchitry.com/lucid_v1/mojo/robotselfie.jpg)

## Take a Picture

This tutorial will run a bit backwards from most of the other tutorials. First, we will use the example project to take a picture, then go through and understand it.

Before we continue, make sure the firmware on your Mojo is up-to-date. Some USB bugs were fixed that may cause issues when trying to capture an image. To flash the latest firmware, in the Mojo IDE click **Tools->Flash Firmware...**

With that out of the way, create a new project based on the _Image Capture_ example.

Build the project and load it onto your Mojo.

Now make sure your setup goes Mojo->SDRAM Shield->Camera Shield->OV2640. It's important that the SDRAM Shield be the first board in the stack. Also, you have to be using the OV2640 camera module for the design to work.

With the stack setup and the design loaded, you should see the right LED on the Mojo blinking 7.5 times per second. The LED toggles each time a picture is taken (15 frames per second).

In the Mojo IDE, go to **Tools->Image Capture...**.

![imgcapture.png](https://cdn.alchitry.com/lucid_v1/mojo/imgcapture.png)

Leave everything as the defaults and with your Mojo plugged in, click _Capture_.

You should now see the image start to load. It takes some time for it to come through so be patient.

Once the image is loaded, you can save it as a .png by clicking _Save Image_.

## What's Going On

It's time to dig into the design to understand what's going on. It's always a good idea to start at the top level and work down, so open up _mojo_top.luc_.

```lucid,short
module mojo_top (
    input clk,                    // 50MHz clock
    input rst_n,                  // reset button (active low)
    output led [8],               // 8 user controllable LEDs
    input cclk,                   // configuration clock, AVR ready when high
    output spi_miso,              // AVR SPI MISO
    input spi_ss,                 // AVR SPI Slave Select
    input spi_mosi,               // AVR SPI MOSI
    input spi_sck,                // AVR SPI Clock
    output spi_channel [4],       // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,                 // AVR TX (FPGA RX)
    output avr_rx,                // AVR RX (FPGA TX)
    input avr_rx_busy,            // AVR RX buffer full
    output<Sdram.out> sdramOut,   // SDRAM outputs
    inout<Sdram.inOut> sdramInOut,// SDRAM inouts
    output camera_scl,            // camera sccb clock
    inout camera_sda,             // camera sccb data
    output camera_xclk,           // camera main clock
    input camera_pclk,            // camera pixel clock
    input camera_href,            // camera href signal
    input camera_vsync,           // camera vsync signal
    input camera_data [8],        // camera pixel data
    output camera_rst,            // camera reset (active low)
    output camera_pwdn            // camera power down (active high)
  ) {
 
  sig rst;  // reset signal
  sig fclk; // 100MHz clock
 
  // boost clock to 100MHz
  clk_wiz clk_wiz;
  always {
    clk_wiz.CLK_IN = clk;   // 50MHz in
    fclk = clk_wiz.CLK_OUT; // 100MHz out (it's like magic!)
  }
 
  .clk(fclk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
 
    .rst(rst) {
      // inouts need to be connected at instantiation and directly to an inout of the module
      sdram sdram (.sdramInOut(sdramInOut));
 
      // interface to the camera (OV2640)
      ov2640 cam (#CLK_FREQ(100000000), .sda(camera_sda));
 
      // toggle to show frame captures
      dff frame_toggle;
 
      // interface to the AVR (and PC indirectly)
      avr_interface avr (#CLK_FREQ(100000000));
 
      // serial port to register interface
      reg_interface reg_int (#CLK_FREQ(100000000));
 
      // memory arbiter to connect multiple devices to SDRAM
      memory_arbiter mem_arb (#DEVICES(2));
 
      // module to capture an image and save it to SDRAM
      img_capture img_capture;
    }
  }
 
  // adapter to give read-only access to the SDRAM over the USB port
  ram_to_reg rtr;
 
  always {
    reset_cond.in = ~rst_n;                 // input raw inverted reset signal
    rst = reset_cond.out;                   // conditioned reset
 
    // avr interface connections
    avr.cclk = cclk;
    spi_miso = avr.spi_miso;
    avr.spi_mosi = spi_mosi;
    avr.spi_sck = spi_sck;
    avr.spi_ss = spi_ss;
    spi_channel = avr.spi_channel;
 
    // serial port connections
    avr_rx = avr.tx;
    avr.rx = avr_tx;
 
    avr.channel = hf; // disabled
 
    // avr to register interface connections
    avr.tx_block = avr_rx_busy;
    reg_int.rx_data = avr.rx_data;
    reg_int.new_rx_data = avr.new_rx_data;
    reg_int.tx_busy = avr.tx_busy;
    avr.tx_data = reg_int.tx_data;
    avr.new_tx_data = reg_int.new_tx_data;
 
    // default to no capture
    img_capture.start = 0;
 
    // if new write command to address 0
    if (reg_int.regOut.new_cmd && reg_int.regOut.write && reg_int.regOut.address == 32d0)
      img_capture.start = 1;                // start image capture
 
    if (cam.image.end_frame)                // if frame over
      frame_toggle.d = ~frame_toggle.q;     // toggle frame_toggle
 
    led = 0;                                // default to off
    led[0] = frame_toggle.q;                // toggle led[0] with each image captured
    led[7] = ~img_capture.idle;             // show when image is being captured
 
    // arbiter to memory connections
    mem_arb.memIn = sdram.memOut;
    sdram.memIn = mem_arb.memOut;
 
    img_capture.img = cam.image;            // image feed
 
    // image capture to memory arbiter connection
    mem_arb.devIn[0] = img_capture.memOut;
    img_capture.memIn = mem_arb.devOut[0];
 
    // register interface to register adapter connections
    rtr.regIn = reg_int.regOut;
    reg_int.regIn = rtr.regOut;
 
    // register adapter to memory connections
    rtr.memIn = mem_arb.devOut[1];
    mem_arb.devIn[1] = rtr.memOut;    
 
    sdramOut = sdram.sdramOut;              // connect controller to SDRAM
 
    // camera connection
    cam.cam_clk = clk_wiz.CAM_CLK;          // 24MHz
    cam.data = camera_data;
    camera_scl = cam.scl;
    camera_xclk = cam.xclk;
    cam.pclk = camera_pclk;
    cam.href = camera_href;
    cam.vsync = camera_vsync;
    camera_rst = cam.rst_cm;
    camera_pwdn = cam.pwdn;
  }
}
```

There's a lot going on, so I drew a block diagram to help you out.

![imagecapture.png](https://cdn.alchitry.com/lucid_v1/mojo/imagecapture.png)

The _ov2640.luc_ component deals with initializing the camera and reading in the pixel data. Open up this file and take a look.

```lucid,short
global Camera {
  // structure for storing the image data
  struct image_data {
    end_frame,        // end of frame reached (active high)
    end_line,         // end of line reached (active high)
    new_pixel,        // new pixel (active high)
    pixel [16]        // pixel data (valid when new_pixel = 1)
  }
}
 
module ov2640 #(
    CLK_FREQ = 50000000 : CLK_FREQ > $pow(2,18) // clock frequency
  )(
    input clk,        // main clock, must be CLK_FREQ
    input cam_clk,    // camera clock, typically 24MHz
    input rst,        // reset
 
    // SCCB Interface
    output scl,       // clock
    inout sda,        // data
 
    // Main camera interface
    output xclk,      // clock output to camera
    input pclk,       // pixel clock from camera
    input href,       // href flag
    input vsync,      // vsync flag
    input data [8],   // pixel data
    output rst_cm,    // reset camera (active low)
    output pwdn,      // power down camera (active high)
 
    // FPGA interface
    output<Camera.image_data> image // image data
  ) {
 
  .clk(clk) {
    .rst(rst) {
      fsm state = {WAIT_RESET, RESET_CAMERA, WAIT_SETUP, PROG_CAMERA, DONE};        // main fsm
      dff rom_addr [$clog2(OV2640_config.ENTRIES)];                                 // ROM address
      dff cam_delay [$clog2(CLK_FREQ)-9];                                           // delay counter
      sccb sccb (#CLK_DIV_SIZE($clog2(CLK_FREQ)-17), #WRITE_ADDR(8h60), .sda(sda)); // sccb interface
    }
    dff<Camera.image_data> img;  // output buffer
    dff href_old, vsync_old;     // vsync/href edge detectors
    dff byte_ct;                 // pixel byte counter
  }
 
  ov2640_config reg_rom;         // configuration ROM
 
  xil_ODDR2 oddr (#DDR_ALIGNMENT("NONE"), #INIT(0), #SRTYPE("SYNC")); // ODDR to output cam_clk to xclk
  always {
    oddr.C0 = cam_clk;
    oddr.C1 = ~cam_clk;
    oddr.CE = 1;
    oddr.D0 = 1;
    oddr.D1 = 0;
    oddr.R = 0;
    oddr.S = 0;
    xclk = oddr.Q;
    rst_cm = 1; // active low
    pwdn = 0;   // active high
  }
 
  // subsignals from fifo buffer
  sig sync_href, sync_vsync, sync_data[8];
 
  // reset conditioner for pclk clock domain
  reset_conditioner wrst_cond (.clk(pclk), .in(rst));
 
  // asyncronous fifo for crossing clock domains (pclk to clk)
  async_fifo fifo (#SIZE(10), #DEPTH(8), .wclk(pclk), .rclk(clk), .wrst(wrst_cond.out), .rrst(rst));
 
  always {
    // defaults
    cam_delay.d = 0;
    reg_rom.addr = rom_addr.q;
    sccb.addr = reg_rom.reg_addr;
    sccb.value = reg_rom.value;
    sccb.write = 0;
    scl = sccb.scl;
 
 
    case (state.q) {
      state.WAIT_RESET:
        cam_delay.d = cam_delay.q + 1;                  // wait power on
        if (&cam_delay.q)                               // if timer elapsed
          state.d = state.RESET_CAMERA;                 // switch states
      state.RESET_CAMERA:
        if (!sccb.busy) {                               // if not busy
          if (rom_addr.q != 2) {                        // if not second command
            rom_addr.d = rom_addr.q + 1;                // increment command address
            sccb.write = 1;                             // write command
          } else {
            state.d = state.WAIT_SETUP;                 // reset command sent, need to wait for it
          }
        }
      state.WAIT_SETUP:
        cam_delay.d = cam_delay.q + 1;                  // wait for camera to come back up
        if (&cam_delay.q)
          state.d = state.PROG_CAMERA;                  // start configuring the registers
      state.PROG_CAMERA:
        if (!sccb.busy) {                               // if sccb bus isn't busy
          if (rom_addr.q != OV2640_config.ENTRIES) {    // if there are more registers to write
            rom_addr.d = rom_addr.q + 1;                // increment address
            sccb.write = 1;                             // write the register
          } else {                                      // otherwise...
            state.d = state.DONE;                       // configuration is done
          }
        }
      state.DONE:
        state.d = state.DONE;                           // do nothing but stay here
      default:
        state.d = state.WAIT_RESET;                     // shouldn't reach here
    }
 
    // defaults
    fifo.wput = 1;                                      // always put data into the fifo
    fifo.rget = 1;                                      // always get data from the fifo
    fifo.din = c{href, vsync, data};                    // connect camera data into fifo
    sync_href = fifo.dout[9];                           // href out of the fifo
    sync_vsync = fifo.dout[8];                          // vsync out of the fifo
    sync_data = fifo.dout[7:0];                         // pixel data out of the fifo
 
    image = img.q;                                      // output img.q
 
    // defaults
    img.d.end_frame = 0;
    img.d.end_line = 0;
    img.d.new_pixel = 0;
 
    // if new fifo data and camera is configured
    if (!fifo.empty && state.q == state.DONE) {
      href_old.d = sync_href;                           // save href
      vsync_old.d = sync_vsync;                         // save vsync
 
      if (vsync_old.q && !sync_vsync)                   // if vsync fell
        img.d.end_frame = 1;                            // signal end of frame
 
      if (href_old.q && !sync_href)                     // if href fell
        img.d.end_line = 1;                             // signal end of line
 
      if (!sync_href || !sync_vsync)                    // if invalid
        byte_ct.d = 0;                                  // reset byte_ct
 
      if (sync_href && sync_vsync) {                    // if valid
        img.d.pixel = c{img.q.pixel[7:0], sync_data};   // shift in pixel data
        byte_ct.d = ~byte_ct.q;                         // flip byte counter
        if (byte_ct.q)                                  // if both bytes read
          img.d.new_pixel = 1;                          // flag we have a new pixel
      }
    }
  }
}
```

The OV2640 camera (with the configurations in the IDE) takes a 24MHz clock and uses an internal PLL to boost it to 36MHz. This clock is used to output the pixel data. The problem is we need a way to capture the pixel data reliably without violating any timing constraints. We could just use this clock for the entire design, but the SDRAM controller is designed to work at 100MHz and if you ever want to do some more complicated processing the extra speed may be nice.

To get the pixel data from the 36MHz clock domain to our 100MHz domain, we can use an _asynchronous FIFO_. A FIFO (or **F**irst **I**n **F**irst **O**ut) buffer is a type of memory structure that allows you to write/read data to/from it. Unlike a chunk of RAM, you don't specify addresses, but rather just that you'd like to read or write. The order that you write data dictates the order that you read it. In other words, the order is preserved. What's special about an _asynchronous FIFO_, is that the writing and reading operations can happen from two different clock domains.

We can write all the pixel data to the FIFO with the 36MHz clock, then read it back out with the 100MHz clock. The only restrictions when using a FIFO is that your average read speed needs to be equal to or faster than the write speed so you don't fill up the FIFO and drop data. You also need to size the FIFO so that it can handle the largest burst size you need to absorb.

In our case, we are reading at 100MHz and writing at 36Mhz, so we will have no problems keeping up with the data flow.

There are four signals the camera uses to send image data to us. _pclk_ is the pixel clock. This is the 36MHz clock that the rest of the signals are aligned to. _vsync_ is the vertical sync signal. It tells us when a frame starts and stops. _href_ is horizontal reference. It tells us when a row starts and stops. _data_ is the eight data lines that convey the actual color information.

When _href_ and _vsync_ are both high, each rising edge of _pclk_ signals a new valid byte of data on _data_. The current configuration of the camera has it outputting 16 bits per pixel, so a new pixel is received every two rising edges of _pclk_.

The _ov2640_ module's job is to output the pixel data and flags for the end of row/frame. Each time _vsync_ falls, the end of a frame is signaled. Each time _href_ falls, the end of a row if signaled. Ever other valid _pclk_ cycle, the two bytes are packed together into a single 16 bit pixel that is output.

The format of each pixel is 565 RGB. That means bits 15-11 are red, 10-5 are green, and 4-0 are blue. You can convert these values to 24 bit color by appending the MSBs of each color so that it's 8 bits wide. For example, if red is 5 bits wide, you can do _c{red\[4:0],red\[4:2]}_ to get the 8 bit equivalent. Note that you aren't actually upscaling the color, but just converting to a different color space.

As we mentioned before, these signals can't be sampled directly in the 100MHz clock domain so the asynchronous FIFO is setup so that each rising edge of _pclk_ writes the _href_, _vsync_, and _data_ signals to it. In the 100MHz clock domain, we simply wait until the FIFO has data to read and treat that data as the three signals to generate the pixel data and flags.

### Configuration

When the camera is first powered up, it isn't taking any pictures. It needs to go through a fairly complicated configuration process before it'll start sending useful data. Unfortunately, camera companies seem to feel the need to keep all the configuration data locked up under NDAs. Fortunately, I was able to find a [Linux driver](https://stuff.mit.edu/afs/sipb/contrib/linux/drivers/media/i2c/soc_camera/ov2640.c) for this camera that contained all the configuration data needed to get it to spit out images. This data is packed into the _ov2640_uxga_config.luc_ module.

This driver contained different configuration settings for various frame sizes from 176x144 to 1600x1200. The _ov2640_uxga_config.luc_ module contains data for 1600x1200 resolution images. If you want to change the resolution, you can remove this component and add one of the other configuration ROMs under _Image_ in the components library. Note that you can only have one of these modules in your project at any given time as they all use the same module name, _ov2640_config_.

This camera is capable of shooting up to 60fps at 408x304, but unfortunately, these configurations are always 15fps. I haven't found any valid configurations for properly setting it up to shoot at higher frame rates, but if someone does find one, [let us know](mailto:support@embeddedmicro.com).

The configuration data is written using a protocol called _SCCB_, or **S**erial **C**amera **C**ontrol **B**us. SCCB is very similar to I2C, with only very minor differences.

## Image Capture

Now that we have the camera setup and spitting out useful pixel information, we need to do something with it.

In this tutorial, we are going to simply save the pixel data into SDRAM so that it can be used later. Open up _img_capture.luc_.

```lucid,short
module img_capture (
    input clk,                       // clock
    input rst,                       // reset
 
    input start,                     // start flag (1 = start)
    output idle,                     // idle flag (1 = idle)
 
    input<Camera.image_data> img,    // image data stream
 
    output<Memory.master> memOut,    // memory interface
    input<Memory.slave> memIn
  ) {
 
  .clk(clk) {
    .rst(rst) {
      fsm state = {IDLE, WAIT_FRAME, WAIT_PIXEL_1, WAIT_PIXEL_2, WRITE_SDRAM};
 
      // RAM may not be ready for each pixel so we need to buffer the writes
      mem_write_buffer buffer (#DEPTH(8));
    }
    dff addr[$clog2(OV2640_config.IMG_SIZE/2)];       // RAM address to write to
    dff data[32];                                     // data to write
  }
 
  always {
    buffer.memIn = memIn;                             // connect buffer to RAM
    memOut = buffer.memOut;
 
    buffer.devIn.valid = 0;                           // not valid
    buffer.devIn.write = 1;                           // always a write
    buffer.devIn.data = data.q;                       // connect data
    buffer.devIn.addr = addr.q;                       // connect address
    idle = state.q == state.IDLE;                     // idle when we are IDLE
 
    case (state.q) {
      state.IDLE:
        addr.d = 0;                                   // reset address
        if (start)                                    // if start
          state.d = state.WAIT_FRAME;                 // wait for the next frame
 
      state.WAIT_FRAME:
        if (img.end_frame)                            // if end of current frame
          state.d = state.WAIT_PIXEL_1;               // start capturing pixels
 
      state.WAIT_PIXEL_1:
        if (img.new_pixel) {                          // if new pixel     
          data.d[15:0] = img.pixel;                   // write to lower half
          state.d = state.WAIT_PIXEL_2;               // wait for next pixel
        }
 
      state.WAIT_PIXEL_2:
        if (img.new_pixel) {                          // if new pixel
          data.d[31:16] = img.pixel;                  // write to upper half
          state.d = state.WRITE_SDRAM;                // write data to SDRAM
        }
 
      state.WRITE_SDRAM:
        if (!buffer.devOut.busy) {                    // if buffer isn't full (busy)
          buffer.devIn.valid = 1;                     // new command
          addr.d = addr.q + 1;                        // increment the address
          state.d = state.WAIT_PIXEL_1;               // wait for next pixel
 
          if (addr.q == (OV2640_config.IMG_SIZE/2)-1) // if we read in all the pixels
            state.d = state.IDLE;                     // return to idle
        }
 
      default:
        state.d = state.IDLE;                         // shouldn't reach here
    }
  }
}
```

This module waits until _start_ signals to capture a frame. It then waits for the current frame to end (signaling a fresh frame is about to start). Once the frame starts, it waits for the first pixel, save it in a dff, then when the next pixel is received it write them both to RAM. The reason it needs to wait for two pixels is because each pixel is 16 bits of data and the SDRAM interface uses 32 bits of data per address. This means we can pack two pixels into each address.

This continues until we have written an entire frames worth of pixels to RAM. We know how many pixels are in a frame from the _OV2640_config.IMG_SIZE_ constant. This constant is defined in the configuration ROM, so if you switch out the ROM, this constant will change everywhere.

There is one minor issue that we didn't consider yet. We get a new pixel at a rate of 36MHz/2 = 18MHz. This means we need to write to RAM at a rate of 18MHz/2 = 9MHz. A write takes 5 clock cycles @ 100MHz (assuming the row is already open) so we should be able to write at 20MHz. However, SDRAM requires refresh cycles to keep the contents intact. This means that periodically there will be fairly large delays. A refresh operation takes 11 cycles. That means, in the worst case, we have to wait 16 cycles between writes. 16 cycles is equivalent to 6.25MHz and since we need to write on average at 9MHz, we have a problem. The solution, another FIFO.

The key is that we need to average a rate 9MHz. The average write performance is easily about 9MHz, we just need to smooth out the delays caused from refresh cycles and opening/closing rows. There is a component, _mem_write_buffer_ that has the same interface as the SDRAM controller that will absorb our writes and spew them out when the SDRAM controller isn't busy.

This buffer makes sure that we don't lose any pixels and everything is written to RAM.

Just to recap, we now have the camera configured and spitting out pixel data. When we receive a signal to capture a frame, we then save the pixel data into SDRAM starting at address 0 and going to address (OV2640_config.IMG_SIZE/2)-1.

## Retrieving the Image

Now that we have a way to capture an image in SDRAM, we need a way to trigger the capture and read the data back.

This is where the [Register Interface](@/tutorials/archive/lucid_v1/mojo/register-interface.md) comes in handy. If you haven't read that tutorial yet, make sure you do.

Just as a recap, the register interface allows us to easily issue read and write commands over the USB port on the Mojo to specific addresses. We can then use these addresses for whatever we want.

We can use a write to address 0 to trigger the capture of an image. Check out these lines from _mojo_top_.

```lucid
// default to no capture
img_capture.start = 0;
 
// if new write command to address 0
if (reg_int.regOut.new_cmd && reg_int.regOut.write && reg_int.regOut.address == 32d0)
  img_capture.start = 1;                // start image capture
```

When a write to address 0 is detected, we set _img_capture.start_ to 1 to capture an image.

We now just need a way to give the register interface access to the SDRAM.

This is where _ram_to_reg_ takes over.

```lucid
module ram_to_reg (
    // register interface
    input<Register.master> regIn,
    output<Register.slave> regOut,
 
    // memory interface
    output<Memory.master> memOut,
    input<Memory.slave> memIn
  ) {
 
  always {
    memOut.write = regIn.write;                  // connect write flags
    memOut.data = regIn.data;                    // connect data for writes
    memOut.addr = regIn.address[22:0];           // memory only uses 23 bit addresses
    memOut.valid = regIn.new_cmd & ~regIn.write; // valid only for new read commands
    regOut.data = memIn.data;                    // connect data from reads
    regOut.drdy = memIn.valid;                   // connect read valid flag
  }
}
```

This modules takes all read requests from the register interface and forwards them the SDRAM controller. The results from the SDRAM controller and sent back to the register interface. Note that writes could easily be forwarded too, but we are using writes to address 0 to signal an image capture and we don't want to corrupt the image data.

Notice how similar these interfaces are. We barely have to do anything to forward the requests.

## Memory Arbiter

We now have a way to take an image, save it, and retrieve the data. However, there's one last issue we need to address. We now have the _img_capture_ and _ram_to_reg_ modules needing to connect to the SDRAM controller.

We need a way to give both modules access to the SDRAM. Good thing we have the _memory_arbiter_ component. This component allows you to connect an arbitrary number of modules implementing the master memory interface (things that want to write/read from RAM) to a single slave (the SDRAM controller).

```lucid,short
module memory_arbiter #(
    DEVICES = 2 : DEVICES > 0                               // number of devices to arbitrate
  )(
    input clk,                                              // clock
    input rst,                                              // reset
    input<Memory.slave> memIn,                              // memory inputs
    output<Memory.master> memOut,                           // memory outputs
    input<Memory.master> devIn[DEVICES],                    // devices inputs
    output<Memory.slave> devOut[DEVICES]                    // devices outputs
  ) {
 
  // simple structure to hold pending commands
  struct command {
    valid,                                                  // valid flag (1 = valid)
    write,                                                  // write/read flag (1 = write)
    addr[23],                                               // address to read/write
    data[32]                                                // data for writes
  }
 
  .clk(clk), .rst(rst) {
    dff<command> commands[DEVICES];                         // buffer for pending commands
    dff device[$clog2(DEVICES)];                            // device waiting for a read
    fsm state = {IDLE, WAIT_READ};                          // current state
    dff activeDev[$clog2(DEVICES)];                         // highest priority device with pending command
  }
 
  var i;
 
  always {
    // defaults
    memOut.data = 32bx;
    memOut.valid = 0;
    memOut.addr = 23bx;
    memOut.write = 1bx;
 
    for (i = 0; i < DEVICES; i++) {
      devOut[i].busy = commands.q[i].valid;                 // if the command isn't valid we can take a new one
      devOut[i].data = 32bx;                                // don't care
      devOut[i].valid = 0;                                  // not valid
 
      // if not busy and new command issued
      if (!commands.q[i].valid && devIn[i].valid) {
        commands.d[i].valid = 1;                            // command pending
        commands.d[i].write = devIn[i].write;               // save the command type
        commands.d[i].addr = devIn[i].addr;                 // save the address
        commands.d[i].data = devIn[i].data;                 // save the data
      }
 
      // set activeDev to the lowest index with a pending command
      if (commands.q[DEVICES-1-i].valid)
        activeDev.d = DEVICES-1-i;
    }
 
    case (state.q) {
      state.IDLE:
 
        // if the memory bus isn't busy and we have a pending command
        if (!memIn.busy && commands.q[activeDev.q].valid) {
          memOut.data = commands.q[activeDev.q].data;       // command data
          memOut.addr = commands.q[activeDev.q].addr;       // command address
          memOut.write = commands.q[activeDev.q].write;     // command type (r/w)
          memOut.valid = 1;                                 // new command
          commands.d[activeDev.q].valid = 0;                // command has been processed
          if (!commands.q[activeDev.q].write) {             // if it is a read
            device.d = activeDev.q;                         // save active device
            state.d = state.WAIT_READ;                      // wait for the result
          }
        }
 
      state.WAIT_READ:
        if (memIn.valid) {                                  // if we have the result
          devOut[device.q].data = memIn.data;               // send it to the waiting device
          devOut[device.q].valid = 1;
          state.d = state.IDLE;                             // go back to IDLE
        }
 
      default:
        state.d = state.IDLE;
    }
  }
}
```

The way it works is it takes requests from any any attached master module. These requests are then issued to the slave in priority order. That means that the first device always has the highest priority, followed by the next, etc.

Priority order is nice because it is simple to implement as it has no internal state (you don't care who was just served). However, it isn't a fair algorithm. That means if the module with the highest priority saturates the memory bus, lower priority modules will never get their requests served.

This isn't typically a problem as long as you order the masters carefully.

In our case, it actually doesn't really matter if the _img_capture_ or _ram_to_reg_ module has higher priority as they won't be operating at the same time (the image is captured, then it is read back). Anyways, the _img_capture_ module was given higher priority as it attaches to the 0th position and _ram_to_reg_ attaches to the 1st position.

## Conclusion

If we go back and look at the block diagram from the beginning, all the connections should now make sense.

![imagecapture.png](https://cdn.alchitry.com/lucid_v1/mojo/imagecapture.png)

The SCCB and Config ROM modules are used to configure the camera. The camera then spits out image data that the OV2640 modules brings over to the 100MHz clock domain and packs into pixel chunks. The image data is then fed into the Image Capture module that, when told to, saves an entire frame into the SDRAM. Writes are buffered in the RAM Write Buffer so we don't drop any pixels when the SDRAM is busy refreshing or opening a new row. The Register Interface module allows us to issue reads and writes to various addresses. If a write to address 0 is issued, we issue a start command to the Image Capture module. All reads are forwarded to the Reg to RAM module which sends them to the SDRAM controller. The Memory Arbiter allows us to give both the Image Capture and Reg to RAM modules access to the SDRAM.

The Image Capture Tool in the Mojo IDE issues a write to address 0 when you click _Capture_. It then waits a small amount of time for the image to be captured and then reads all the addresses needed for an entire frame. As the image data is read in, it builds an image out of it.