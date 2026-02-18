+++
title = "Alchitry Constraints Reference"
weight = 1
inline_language = "acf"
date = "2025-02-04"
aliases = ["tutorials/alchitry-constraints-reference"]
+++

This page is a reference for Alchitry Constraints V2.

{{ youtube(id="dnk6_uN5UyE?si=eKinloydxoEf2rXi") }}

# Alchitry Constraints File Contents

An Alchitry Constraints File (.acf extension) contains a list of [pin constraints](#pin-constraints).

## Comments

Comments take the same form as in [Lucid](@/tutorials/references/lucid-reference.md#comments).

Use `//` for a single line comment and `/*    */` for a multi-line comment.

## Pin Constraints

The main purpose of a pin constraint is to tell the tools which physical pin on the FPGA corresponds to a port 
of your design's top-level module.

A pin constraint takes the following form.

```acf
pin port_name PIN_NAME OPTIONAL_ATTRIBUTE_LIST
```

Here, `port_name` corresponds to a port of your top-level module.
If the port is an array, then it should also include [array selectors](@/tutorials/references/lucid-reference.md#array-selection)
to select only a single bit.

The `PIN_NAME` is the name of the physical pin to connect to `port_name`.
This name is the Alchitry pin name and not the pin name of the FPGA.
See the [pinout section](#pinouts) for the various pin names.

Finally, the `OPTIONAL_ATTRIBUTE_LIST` is a list of [attributes](#attributes) that apply to only this pin.

## Attribute Block

Specifying attributes for every single pin constraint would often become very tedious as many pins will share the same attribute values.
This is where attribute blocks come into play.
They take a very similar form to the [connection blocks](@/tutorials/references/lucid-reference.md#connection-blocks) in Lucid.

```acf
ATTRIBUTES_LIST {
   ...
}
```

The `ATTRIBUTES_LIST` is a comma-seperated list of [attributes](#attributes).

The attributes in the list are applied to every [pin constraint](#pin-constraints) inside the brackets.

Attribute blocks can also be nested to allow for fine-grained assignments.

For example, the Hd constraints uses two `STANDARD` blocks along with a single `PINOUT` block.

```acf,short
PINOUT(V2) {
    STANDARD(LVCMOS33) { // standard 3.3V IO standard
        pin hdmi_sda_1 A70
        pin hdmi_scl_1 A72
        pin hdmi_cec_1 A76
        pin hdmi_hp_1 A78

        pin hdmi_sda_2 A69
        pin hdmi_scl_2 A71
        pin hdmi_cec_2 A75
        pin hdmi_hp_2 A77
    }

    STANDARD(TMDS_33) { // HDMI IO standard
        pin hdmi_clk_1_p A48
        pin hdmi_clk_1_n A46
        pin hdmi_data_1_p[0] A54
        pin hdmi_data_1_n[0] A52
        pin hdmi_data_1_p[1] A60
        pin hdmi_data_1_n[1] A58
        pin hdmi_data_1_p[2] A66
        pin hdmi_data_1_n[2] A64

        pin hdmi_clk_2_p A47
        pin hdmi_clk_2_n A45
        pin hdmi_data_2_p[0] A53
        pin hdmi_data_2_n[0] A51
        pin hdmi_data_2_p[1] A59
        pin hdmi_data_2_n[1] A57
        pin hdmi_data_2_p[2] A65
        pin hdmi_data_2_n[2] A63
    }
}
```

## Attributes

An attribute takes the following form.

```acf
ATTRIBUTE_NAME(attribute_value)
```

This assigns the value, `attribute_value`, to the attribute named `ATTRIBUTE_NAME`.

There are a handful of different attributes currently supported.

### PINOUT

This attribute is either `V2`, `V1`, `PT_ALPHA`, or not specified.

When it is specified, it says that the pinout used for that pin should use that version's pin mapping.

When it isn't specified, the project's board's version is used.
For example, an Au V1 will use `V1`.

Most of the time, if specified, it should match the board's version.
However, if a `V1` pinout is specified when using a `V2` board, then the tools assume you are using a 
[V2->V1 adapter](https://shop.alchitry.com/products/alchitry-v2-v1-adapter).
In this case, the tools will translate the pinout to the adapter's pinout.

If a `V2` version is used with a `V1` board an error is thrown.

The value `PT_ALPHA` is specifically for the first batch of Pt boards that had a pinout error.
It is only valid when [`SIDE`](#side) is set to `TOP`.
The bottom pinout of the alpha boards should use a `PINOUT` of `V2`.

### SIDE

Most boards only have ports on the top side.
However, the [Pt](https://shop.alchitry.com/products/alchitry-pt) has pins on both sides.

To distinguish between the top and bottom, the `SIDE` attribute was added.

`SIDE` can have a value of `TOP` or `BOTTOM`.
It defaults to `TOP`.

On the Pt, the top and bottom connectors both have banks A and B, and the pin names are identical.
This means that a constraint file that works for the top of the board can be simply wrapped in a `SIDE(BOTTOM)` attribute
block to use the board with the bottom connectors.

### STANDARD

This specifies the IO standard to apply to the pin.

Most of the time, it will be set to `LVCMOS33`.
This is the basic 3.3V IO standard.
It is also the only standard supported by the [Cu](https://shop.alchitry.com/products/alchitry-cu-v2).

The [Au](https://shop.alchitry.com/products/alchitry-au) and [Pt](https://shop.alchitry.com/products/alchitry-pt) both
support the same IO standards.
There are too many standards to list here, but page 98 of [UG471](https://docs.amd.com/v/u/en-US/ug471_7Series_SelectIO)
has a nice table summarizing the requirements for each standard.

Each IO standard has various requirements that must be met in order for it to be used.
The biggest one is the `Vcco` voltage.
All the pins on the Cu and most of the Au and Pt have `Vcco` fixed at 3.3V.

The Au and Pt have one group of pins that can have `Vcco` switched between 3.3V, 2.5V, and 1.8V.
This drastically opens up the IO standards available on these pins.

For example, by setting `Vcco` to 2.5V, the tri-voltage pins can be used as `LVDS_25` outputs or enable termination 
when used as inputs.
Any pins on the Au/Pt can be used as `LVDS_25` inputs as long as they don't use internal termination.

The other common requirement is the `Vref` voltage.
Many standards don't require a specific `Vref` and for the ones that do, an internal reference can typically be used.
However, only one `Vref` can be set for a bank of pins.
Here, _bank_ refers not to the connector's bank but rather the FPGA's internal bank.

In the [Au's schematic](https://cdn.alchitry.com/docs/Au-V2/AuSchematic.pdf), the bank number is the first number 
of the FPGA's IO signal names.
On page 2, you can see the header's pinout as well as the associated pin banks for each signal.
The banks are numbers like `14`, `34`, and `35`.

All the IO standards used in a bank must have at most one `Vref` requirement.

### FREQUENCY

This attribute marks the pin as a clock input with the given frequency.

The frequency value takes the form of a number followed by a frequency unit.
The unit can be `Hz`, `KHz`, `MHz`, or `GHz`.
For example, `100MHz`.

Clock inputs should also be typically placed on a clock capable input pin.
Xilinx (for the Au/Pt) calls these `MRCC` or `SRCC` pins.
Lattice (for the Cu) calls these `GBIN`.
You can look at each board's schematic to see what pins are clock capable inputs.

For V2 boards, pins `A41`, `A42`, `A47`, `A48`, `B41`, `B42`, and `B47` are clock capable inputs.

The Au also includes `B48`.

The Pt also includes `B24`, `B29`, `B30`, `B48`, `C41`, `C42`, `C47`, `C48`, `D41`, `D42`, `D47`, and `D48`.

### PULL

This attribute is used to enable a pin's pull-up or pull-down resistors.

For the Cu, `UP` is the only valid value.

For the Au/Pt, `UP`, `DOWN`, or `KEEP` are valid values.

`UP` enables a weak pull-up.
`DOWN` enables a weak pull-down.
`KEEP` enables a weak pull to the same value the pin currently is (0 -> pull-down, 1 -> pull-up).

### DRIVE

The attribute specifies the drive strength of the pin in mA.

It is not supported by the Cu.

It is only valid when paired with specific [IO standards](#standard).
For the valid values of each standard, see table 1-56 on page 101 of [UG471](https://docs.amd.com/v/u/en-US/ug471_7Series_SelectIO).

For `LVCMOS33` on the Au/Pt, these are `4`, `8`, `12`, or `16`.

This number specifies the drive strength in mA and defaults to `12`.

### SLEW

This attribute specifies the slew rate of the pin and is only supported by the Au/Pt, not the Cu.

The slew rate is how fast the edge transitions.

It is only valid when paired with specific [IO standards](#standard).
For the valid values of each standard, see table 1-56 on page 101 of [UG471](https://docs.amd.com/v/u/en-US/ug471_7Series_SelectIO).

For standards that support a slew rate, the valid values are `FAST` or `SLOW` with `SLOW` being the default.

Using a `FAST` slew rate may help with high speed signals but may also cause more power consumption and noise if not 
used carefully.

### DIFF_TERM

The `DIFF_TERM` attribute specifies if internal differential termination should be enabled.
It can have a value of `TRUE` or `FALSE` and defaults to `FALSE`.

It is only available with some [`STANDARD`](#standard) values on the Au and Pt.
See [UG471](https://docs.amd.com/v/u/en-US/ug471_7Series_SelectIO) for details on which ones.

It is most often used with `LVDS_25` on the tri-voltage pins.
Using internal termination requires that VCCO be set to 2.5V for the pins using it.
Failing to set the tri-voltage pins correctly could damage the FPGA.

# Pinouts

The available pins vary depending on your board, but they follow a standard format.

The pins broken out on the connectors are named by the bank letter followed by the pin number.
For example, pin 2 on bank A is `A2`.

The V2 boards have two banks on top, A and B.
The [Pt](https://shop.alchitry.com/products/alchitry-pt) has two more on the bottom. 
They're also called A and B but distinguished via the 

The V1 boards have four banks, A, B, C, and D on top.

Check the schematic for the [Cu V1](https://cdn.alchitry.com/docs/alchitry_cu_sch.pdf), [Au V1](https://cdn.alchitry.com/docs/alchitry_au_sch.pdf), [Cu V2](https://cdn.alchitry.com/docs/Cu-V2/CuSchematic.pdf) or [Au V2](https://cdn.alchitry.com/docs/Au-V2/AuSchematic.pdf) for what pins are populated on the connectors.

In addition to the pins on the connectors, there are some special internal pin names.

All boards have the pins `LED0`-`LED7`, `RESET`, `CLOCK`, `USB_RX`, and `USB_TX`.

The Cu (V1 and V2) also have `SPI_MOSI`, `SPI_MISO`, `SPI_SCK`, and `SPI_SS` that connect to the configuration flash.

The Au (V1, V1+, and V2) and Pt also have `SPI_D0`-`SPI_D3`, `SPI_SCK`, and `SPI_SS` that connect to the configuration flash.
There is also `VP` and `VN` which are special analog inputs.

The Pt also has `C29` - `C36` that connect to where the LED signals on the Au and Cu are broken out on the control connector.
The LED signals aren't broken out on the Pt.

The Pt also has `USB_D2` - `USB_D7`, `USB_RXF`, `USB_TXE`, `USB_RD`, `USB_WR`, and `USB_SIWUI` for using the FIFO-based 
interface with the FTDI chip.
Note that what would be `USB_D0` is `USB_RX` and `USB_D1` is `USB_TX`.

Finally, there are `DDR_DQ0`-`DDR_DQ15`, `DDR_DQS0_P`, `DDR_DQS0_N`, `DDR_DQS1_P`, `DDR_DQS1_N`, `DDR_DM0`, `DDR_DM1`,
`DDR_ODT`, `DDR_RESET`, `DDR_BA0`-`DDR_BA2`, `DDR_CK_P`, `DDR_CK_N`, `DDR_CKE`, `DDR_CS`, `DDR_RAS`, `DDR_CAS`, `DDR_WE`,
`DDR_A0`-`DDR_A13` for interfacing with the DDR3.
You generally shouldn't specify these directly as the [MIG core](@/tutorials/advanced/ddr3-memory.md) does it for you.

# Native Constraints

Sometimes you may need to do something more advanced that isn't directly supported within the Alchitry Constraint Format.
For those cases, you can use a `native` block.

The `native` block takes the following form.

```acf
native {
  // Native constraints here
}
```

The text inside the block will be inserted into the final constraint file mostly as is.
This allows you to write [XDC](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints/About-XDC-Constraints) constraints
for the Au or Pt and SDC constraints for the Cu.

Inside the `native` block, you have access to two helper functions. `acf_pin()` and `acf_port()`.

## acf_pin()

The `acf_pin()` function allows you to access the Alchitry pin converter inside the native block.
This lets you use the names of the pins on the connectors instead of the FPGA's pin.

For example, `acf_pin(A3)`, when used with the Au, will be replaced by `N6` (the name of the FPGA pin).

If the native block is wrapped in an attribute block specifying a `PINOUT` or `SIDE`, that is taken into account
during the translation.

## acf_port()

The `acf_port()` function allows you to get the name of a top-level port.
The name of the port in Lucid isn't always exactly the same in the translated files, and this function ensures you use
the correct name.

For example, `acf_port(clk)` will be replaced with the name of the `clk` signal (most likely just `clk`).

The port should also include all the indexing.
This is where translation often differs from Lucid to the final name.

For example, `acf_port(led[4])` will be replaced with the correct port name for the `led[4]` signal.