+++
title = "Hello YOUR_NAME_HERE"
weight = 5
+++

In this tutorial we will be making some modifications to the Hello World! project from the last tutorial so make sure you have read the [ROMs and FSMs tutorial](@/tutorials/archive/lucid_v1/roms-and-fsms.md) first. We will be personalizing the greeter so that it first asks for your name and then prints "Hello NAME" where NAME is the name you entered. To do this we will need some form of memory and in this case we will use a single port RAM.

With the project open from the last tutorial, you can make a copy to edit for this tutorial by going to **File->Clone Project**. Enter a new name in the dialog that pops up and click **Create**.

## The RAM

We need to add the RAM component to our project. Go to **Project->Add Components...** and under _Memory_ check off _Simple RAM_.

Go ahead and open up **simple_ram.v**.

```lucid
module simple_ram #(
    parameter SIZE = 1,  // size of each entry
    parameter DEPTH = 1  // number of entries
  )(
    input clk,                         // clock
    input [$clog2(DEPTH)-1:0] address, // address to read or write
    output reg [SIZE-1:0] read_data,   // data read
    input [SIZE-1:0] write_data,       // data to write
    input write_en                     // write enable (1 = write)
  );
 
  reg [SIZE-1:0] ram [DEPTH-1:0];      // memory array
 
  always @(posedge clk) begin
    read_data <= ram[address];         // read the entry
 
    if (write_en)                      // if we need to write
      ram[address] <= write_data;      // update that value
  end
 
endmodule
```

Note that this component is written in Verilog instead of Lucid. This is because the tools that actually build your project can be very picky when it comes to deciding if something is a block of RAM or not. By using this module we can ensure that our RAM is properly recognized as RAM. This is important because FPGAs actually have dedicated block RAM (also known as BRAM). If your RAM is big enough, the tools will use BRAM to implement it instead of the FPGA fabric. Using BRAM is both substantially faster and smaller than the FPGA fabric.

A single port RAM like this works much the same as the ROM from the last tutorial. However, we now have the option to write to an address instead of only reading. To write to an address, we simply supply the address and data to write then set _write_en_ to 1. The data at that address will then be updated to whatever _write_data_ is.

The parameters _SIZE_ and _DEPTH_ are used to specify how big we want the RAM to be. _SIZE_ specifies how big each entry is. In our case we will be storing letters and a letter is 8 bits wide so SIZE will be set to 8. _DEPTH_ is used to specify how many entries we want. This will be the maximum name length we can accept.

## The Greeter (revisited)

Just like the last tutorial we will have a _greeter_ module. The interface to this module is exactly the same as before but it is now a bit more mannered and will greet you personally.

Like most tutorials, I'll post the entire module here and then break it down.

```lucid
module greeter (
    input clk,         // clock
    input rst,         // reset
    input new_rx,      // new RX flag
    input rx_data[8],  // RX data
    output new_tx,     // new TX flag
    output tx_data[8], // TX data
    input tx_busy      // TX is busy flag
  ) {
 
  const HELLO_TEXT = $reverse("\r\nHello @!\r\n"); // reverse so index 0 is the left most letter
  const PROMPT_TEXT = $reverse("Please type your name: ");
 
  .clk(clk) {
    .rst(rst) {
      fsm state = {IDLE, PROMPT, LISTEN, HELLO}; // our state machine
    }
 
    // we need our counters to be large enough to store all the indices of our text
    dff hello_count[$clog2(HELLO_TEXT.WIDTH[0])]; // HELLO_TEXT is 2D so WIDTH[0] gets the first dimension
    dff prompt_count[$clog2(PROMPT_TEXT.WIDTH[0])];
 
    dff name_count[5]; // 5 allows for 2^5 = 32 letters
    // we need our RAM to have an entry for every value of name_count
    simple_ram ram (#SIZE(8), #DEPTH($pow(2,name_count.WIDTH)));
  }
```

### No More ROM

So unlike last tutorial, we aren't going to use an explicit ROM module. This is because some convenient features of Lucid allow us to easily use constants with strings as ROMs. Let us take a look at the constant declaration.

```lucid
const HELLO_TEXT = $reverse("\r\nHello @!\r\n"); // reverse so index 0 is the left most letter
const PROMPT_TEXT = $reverse("Please type your name: ");
```

Here we are using a function called _$reverse()_. This function takes some constant expression and reverse the order of the top most dimension of the array. Since strings are 2D arrays with the top most dimension being the letter order, this is exactly the same as typing the string backwards like we did in the last tutorial. This is just a little bit cleaner and easier to deal with.

Because strings are 2D arrays, we can simply use _HELLO_TEXT[i]_ to access the _i_th letter of it.

Note that we are using the @ symbol in place of a name. This will signal to our design where to insert the name that was recorded.

### Modules and DFFs

Just like before we have an FSM _state_. This will store the current state of our module. _IDLE_ is where we will start and it will initialize everything. _PROMPT_ will print the prompt asking for your name. _LISTEN_ will listen to you type your name and echo it back. Finally, _HELLO_ will greet you personally.

We need counters to keep track of what letter in each ROM we are currently positioned.

```lucid
dff hello_count[$clog2(HELLO_TEXT.WIDTH[0])]; // HELLO_TEXT is 2D so WIDTH[0] gets the first dimension
dff prompt_count[$clog2(PROMPT_TEXT.WIDTH[0])];
```

Let us take a look at _hello_count_. We need it to be wide enough so that we can index all the letters in HELLO_TEXT. We can get how many letters there are in the string by using the _WIDTH_ attribute. Because _HELLO_TEXT_ is a multi-dimensional array (2D in this case), _WIDTH_ will be a 2D array. The first index of _WIDTH_ is the number of indices in the first dimension of _HELLO_TEXT_. This is the number of letters. So we simply use _HELLO_TEXT.WIDTH[0]_. Note that the second dimension has a width of 8 since each letter is 8 bits wide.

We can then use the _$clog2()_ function as before to make sure it is large enough to store values from 0 to _HELLO_TEXT.WIDTH[0]_-1.

Next take a look at _name_count_. This will be used to index into the RAM. We can set this width to be whatever we want, but the size of the RAM will grow exponentially with it. I set it to 5 which will allow for a name of 2<sup>5</sup>, or 32 letters long. We will play with this towards the end of the tutorial.

We need the size of the RAM to match the size of _name_count_.

```lucid
simple_ram ram (#WIDTH(8), #DEPTH($pow(2,name_count.WIDTH)));
```

Here we are using the function _$pow()_ which takes two constants and returns the first to the power of the second. In this case, _name_count.WIDTH_ is 5, so 2<sup>5</sup> is 32. By using _name_count.WIDTH_ instead of typing in 5 or 32 directly, we ensure that if we change the width of _name_count_ then everything will still work.

### The FSM

The _IDLE_ and _PROMPT_ states should look very familiar to the last tutorial so we will jump to the _LISTEN_ state.

```lucid
// LISTEN: Listen to the user as they type his/her name.
state.LISTEN:
  if (new_rx) { // wait for a new byte
    ram.write_data = rx_data;        // write the received letter to RAM
    ram.write_en = 1;                // signal we want to write
    name_count.d = name_count.q + 1; // increment the address
 
    // We aren't checking tx_busy here that means if someone types super
    // fast we could drop bytes. In practice this doesn't happen.
    new_tx = rx_data != "\n" && rx_data != "\r"; // only echo non-new line characters
    tx_data = rx_data; // echo text back so you can see what you type
 
    // if we run out of space or they pressed enter
    if (&name_count.q || rx_data == "\n" || rx_data == "\r") {
      state.d = state.HELLO;
      name_count.d = 0; // reset name_count
    }
  }
```

Here we wait until _new_rx_ is 1. This signals that we have a new byte to process and that the data on _rx_data_ is valid. We then write _rx_data_ into our RAM. We are writing to the address specified by _name_count.q_ as _ram.address_ is set to this in the beginning of the always block.

We also need to send the character we received back so that you can see your name as you type it. We simply set _new_tx_ to 1 and _tx_data_ to _rx_data_. Note that we aren't checking _tx_busy_ so it is possible this byte will be dropped. However, in practice you can't type fast enough for this to be an issue. If you wanted to make this more robust you would need to buffer the received letters and send them out only when _tx_busy_ was 0.

The if statement is used to know when to stop. We have two conditions to stop on. The first is if we simply run out of space. To check of this we use _&name_count.q_. The & operator here **and**s all the bits of _name_count.q_ together into a single bit. This tells us if all the bits of _name_count.q_ are 1. The second condition is that the user pressed the enter key. We want to accept "\n" or "\r" as a stop character so we check for both.

When we are moving onto the next state, notice that we reset _name_count_. This is so that we can start printing the name from the beginning.

```lucid
// HELLO: Prints the hello text with the given name inserted
state.HELLO:
  if (!tx_busy) { // wait for tx to not be busy
    if (HELLO_TEXT[hello_count.q] != "@") { // if we are not at the sentry
      hello_count.d = hello_count.q + 1;    // increment to next letter
      new_tx = 1;                           // new data to send
      tx_data = HELLO_TEXT[hello_count.q];  // send the letter
    } else {                                // we are at the sentry
      name_count.d = name_count.q + 1;      // increment the name_count letter
 
      if (ram.read_data != "\n" && ram.read_data != "\r") // if we are not at the end
        new_tx = 1;                                       // send data
 
      tx_data = ram.read_data;              // send the letter from the RAM
 
      // if we are at the end of the name or out of letters to send
      if (ram.read_data == "\n" || ram.read_data == "\r" || &name_count.q) {
        hello_count.d = hello_count.q + 1;  // increment hello_count to pass the sentry
      }
    }
 
    // if we have sent all of HELLO_TEXT
    if (hello_count.q == HELLO_TEXT.WIDTH[0] - 1)
      state.d = state.IDLE; // return to IDLE
  }
```

In this state, we are going to use two counters, _hello_count_ and _name_count_. First we will start by sending each letter of _HELLO_TEXT_. However, once we hit the "@" letter we will send all the letters in our RAM. Once that is done, we will finish sending the rest of _HELLO_TEXT_.

Once everything has been sent, we return to the _IDLE_ state to await another key press to start it all over again.

## The Top Level

The top level tile file is exactly the same as last time since the interface to our _greeter_ module is the same.

{% fenced_code_tab(tabs=["Au", "Cu", "Mojo"]) %}
```lucid
module au_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx           // USB->Serial output
  ) {
   
  sig rst;                  // reset signal
   
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
     
    .rst(rst) {
      #BAUD(1000000), #CLK_FREQ(100000000) {
        uart_rx rx;
        uart_tx tx;
      }
       
      greeter greeter; // instance of our greeter
    }
  }
   
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
     
    rx.rx = usb_rx;         // connect rx input
    usb_tx = tx.tx;         // connect tx output
      
    greeter.new_rx = rx.new_data;
    greeter.rx_data = rx.data;
    tx.new_data = greeter.new_tx;
    tx.data = greeter.tx_data;
    greeter.tx_busy = tx.busy;
    tx.block = 0;
     
    led = 8h00;             // turn LEDs off
  }
}
```
---
```lucid
module cu_top (
    input clk,              // 100MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input usb_rx,           // USB->Serial input
    output usb_tx           // USB->Serial output
  ) {
   
  sig rst;                  // reset signal
   
  .clk(clk) {
    // The reset conditioner is used to synchronize the reset signal to the FPGA
    // clock. This ensures the entire FPGA comes out of reset at the same time.
    reset_conditioner reset_cond;
     
    .rst(rst) {
      #BAUD(1000000), #CLK_FREQ(100000000) {
        uart_rx rx;
        uart_tx tx;
      }
       
      greeter greeter; // instance of our greeter
    }
  }
   
  always {
    reset_cond.in = ~rst_n; // input raw inverted reset signal
    rst = reset_cond.out;   // conditioned reset
     
    rx.rx = usb_rx;         // connect rx input
    usb_tx = tx.tx;         // connect tx output
      
    greeter.new_rx = rx.new_data;
    greeter.rx_data = rx.data;
    tx.new_data = greeter.new_tx;
    tx.data = greeter.tx_data;
    greeter.tx_busy = tx.busy;
    tx.block = 0;
     
    led = 8h00;             // turn LEDs off
  }
}
```
---
```lucid
module mojo_top(
    input clk,              // 50MHz clock
    input rst_n,            // reset button (active low)
    output led [8],         // 8 user controllable LEDs
    input cclk,             // configuration clock, AVR ready when high
    output spi_miso,        // AVR SPI MISO
    input spi_ss,           // AVR SPI Slave Select
    input spi_mosi,         // AVR SPI MOSI
    input spi_sck,          // AVR SPI Clock
    output spi_channel [4], // AVR general purpose pins (used by default to select ADC channel)
    input avr_tx,           // AVR TX (FPGA RX)
    output avr_rx,          // AVR RX (FPGA TX)
    input avr_rx_busy       // AVR RX buffer full
  ) {
 
  .clk(clk), .rst(~rst_n){
    // the avr_interface module is used to talk to the AVR for access to the USB port and analog pins
    avr_interface avr;
 
    greeter greeter; // instance of our greeter
  }
 
  always {
    // connect inputs of avr
    avr.cclk = cclk;
    avr.spi_ss = spi_ss;
    avr.spi_mosi = spi_mosi;
    avr.spi_sck = spi_sck;
    avr.rx = avr_tx;
 
    // connect outputs of avr
    spi_miso = avr.spi_miso;
    spi_channel = avr.spi_channel;
    avr_rx = avr.tx;
 
    avr.channel = hf; // ADC is unused so disable
    avr.tx_block = avr_rx_busy; // block TX when AVR is busy
 
    greeter.new_rx = avr.new_rx_data;
    greeter.rx_data = avr.rx_data;
    avr.new_tx_data = greeter.new_tx;
    avr.tx_data = greeter.tx_data;
    greeter.tx_busy = avr.tx_busy;
 
    led = 8h00;             // turn LEDs off
  }
}
```
{% end %}

## Building the Project

You should now be all set to build the project. Once the project has build successfully, load it onto your board and open up the serial port monitor to test it out. Note that you have to send it a letter to get it to prompt you for your name.

Here is some demo output.

```
Please type your name: Justin
Hello Justin!
Please type your name: Steve
Hello Steve!
Please type your name: 01234567890123456789012345678901
Hello 01234567890123456789012345678901!
```

Notice that the moment you type 32 letters it cuts you off and says hello.

>The rest of the tutorial is based on the Mojo and ISE.
>
>For the Cu, iCEcube 2 shows similar (although somewhat simplified) statistics. It also seems to pack the RAM into BRAM even when it is only 32 entries deep. Changing it to 1024 (making _name_count_ 10 bits wide) entries deep will cause it to use two BRAMs. This is listed under _Device Utilization Summary_ in the build output.
>
>For the Au, Vivado also shows similar statistics. Look for the table labeled _Report Cell Usage_ in the synthesis output. You will notice it is using eight of something called **RAM32X1S**. This is a 32x1bit RAM that fits our small RAM perfectly! It isn't BRAM but a special slice that can be confirmed as a tiny RAM (or generic logic). If you increase the RAM size, you'll notice it switches to using **RAMB18E1** which is larger more flexible BRAM. See [this document](https://www.xilinx.com/support/documentation/user_guides/ug473_7Series_Memory_Resources.pdf) for more info.

Once you've played with it a bit, look back at the output from the build. If you scroll up a bit from the bottom you should find something that looks like the following.

```short
Device Utilization Summary:
 
Slice Logic Utilization:
  Number of Slice Registers:                    96 out of  11,440    1%
    Number used as Flip Flops:                  96
    Number used as Latches:                      0
    Number used as Latch-thrus:                  0
    Number used as AND/OR logics:                0
  Number of Slice LUTs:                        163 out of   5,720    2%
    Number used as logic:                      157 out of   5,720    2%
      Number using O6 output only:             123
      Number using O5 output only:              12
      Number using O5 and O6:                   22
      Number used as ROM:                        0
    Number used as Memory:                       5 out of   1,440    1%
      Number used as Dual Port RAM:              0
      Number used as Single Port RAM:            4
        Number using O6 output only:             0
        Number using O5 output only:             0
        Number using O5 and O6:                  4
      Number used as Shift Register:             1
        Number using O6 output only:             1
        Number using O5 output only:             0
        Number using O5 and O6:                  0
    Number used exclusively as route-thrus:      1
      Number with same-slice register load:      0
      Number with same-slice carry load:         1
      Number with other load:                    0
```

This tells you how much of the FPGA your design is using. The two most important numbers are typically the slice register and slice LUT usage. You can see in our case we are using about 2% of the space in the FPGA!

The reason we are looking at this is to see how the RAM was implemented in the FPGA. Remember the FPGA has blocks of RAM that we can use? These are shown under **Specific Feature Utilization**. **RAMB16BWER** and **RAMB8BWER** are the two types of BRAM we can use. But wait! We aren't using any! This is because our RAM is too small to warrant its own BRAM.

If we go back to where _name_count_ is declared and make it bigger, we can increase the RAM size.

```lucid
dff name_count[8]; // 8 allows for 2^8 = 256 letters
```

If you build the project again with the bigger RAM, you will get the following.

```short
Device Utilization Summary:
 
Slice Logic Utilization:
  Number of Slice Registers:                    90 out of  11,440    1%
    Number used as Flip Flops:                  90
    Number used as Latches:                      0
    Number used as Latch-thrus:                  0
    Number used as AND/OR logics:                0
  Number of Slice LUTs:                        144 out of   5,720    2%
    Number used as logic:                      140 out of   5,720    2%
      Number using O6 output only:             107
      Number using O5 output only:              12
      Number using O5 and O6:                   21
      Number used as ROM:                        0
    Number used as Memory:                       1 out of   1,440    1%
      Number used as Dual Port RAM:              0
      Number used as Single Port RAM:            0
      Number used as Shift Register:             1
        Number using O6 output only:             1
        Number using O5 output only:             0
        Number using O5 and O6:                  0
    Number used exclusively as route-thrus:      3
      Number with same-slice register load:      2
      Number with same-slice carry load:         1
      Number with other load:                    0
 
Slice Logic Distribution:
  Number of occupied Slices:                    48 out of   1,430    3%
  Number of MUXCYs used:                        16 out of   2,860    1%
  Number of LUT Flip Flop pairs used:          152
    Number with an unused Flip Flop:            70 out of     152   46%
    Number with an unused LUT:                   8 out of     152    5%
    Number of fully used LUT-FF pairs:          74 out of     152   48%
    Number of slice register sites lost
      to control set restrictions:               0 out of  11,440    0%
 
  A LUT Flip Flop pair for this architecture represents one LUT paired with
  one Flip Flop within a slice.  A control set is a unique combination of
  clock, reset, set, and enable signals for a registered element.
  The Slice Logic Distribution report is not meaningful if the design is
  over-mapped for a non-slice resource or if Placement fails.
 
IO Utilization:
  Number of bonded IOBs:                        22 out of     102   21%
    Number of LOCed IOBs:                       22 out of      22  100%
 
Specific Feature Utilization:
  Number of RAMB16BWERs:                         0 out of      32    0%
  Number of RAMB8BWERs:                          1 out of      64    1%
  Number of BUFIO2/BUFIO2_2CLKs:                 0 out of      32    0%
  Number of BUFIO2FB/BUFIO2FB_2CLKs:             0 out of      32    0%
  Number of BUFG/BUFGMUXs:                       1 out of      16    6%
    Number used as BUFGs:                        1
    Number used as BUFGMUX:                      0
  Number of DCM/DCM_CLKGENs:                     0 out of       4    0%
  Number of ILOGIC2/ISERDES2s:                   0 out of     200    0%
  Number of IODELAY2/IODRP2/IODRP2_MCBs:         0 out of     200    0%
  Number of OLOGIC2/OSERDES2s:                   0 out of     200    0%
  Number of BSCANs:                              0 out of       4    0%
  Number of BUFHs:                               0 out of     128    0%
  Number of BUFPLLs:                             0 out of       8    0%
  Number of BUFPLL_MCBs:                         0 out of       4    0%
  Number of DSP48A1s:                            0 out of      16    0%
  Number of ICAPs:                               0 out of       1    0%
  Number of MCBs:                                0 out of       2    0%
  Number of PCILOGICSEs:                         0 out of       2    0%
  Number of PLL_ADVs:                            0 out of       2    0%
  Number of PMVs:                                0 out of       1    0%
  Number of STARTUPs:                            0 out of       1    0%
  Number of SUSPEND_SYNCs:                       0 out of       1    0%
```

Notice that we are using a **RAMB8BWER** now. Also notice that the number of registers and LUTs we are using went down. This is because we are using the BRAM instead of the general fabric.

This is why it is important to use the _simple_ram_ component that implements the template the tools look for. If we used a different coding style the tools may not recognize that it could use BRAM and we could quickly fill up the FPGA with a large RAM that would otherwise take very little space.