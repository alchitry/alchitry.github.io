+++
title = "Alchitry Labs V2.0.21 - Alchitry Constraints Updated"
date = "2024-12-26"
inline_language = "acf"
+++

[Alchitry Labs V2.0.21-BETA](@/alchitry-labs.md) just dropped with support for the new [Alchitry V2 boards](https://shop.alchitry.com/collections/all).

To properly support the new boards, the format for Alchitry Constraint Files (ACF) was updated. <!-- more -->
The format for every constraint now has the following format.

```acf
pin PORT PIN OPTIONAL_ATTRIBUTES
```

Just like before `PORT` is a port from your design's top-level module and `PIN` in the Alchitry pin to connect it to.

Most of the time, the `PIN` name will follow a format of bank letter followed by the pin number like `A2` for bank A pin 2.
However, there are special values such as `LED0` which corresponds to the pin connected to the first LED on the board.
You can take a look at the current [pinout files](https://github.com/alchitry/Alchitry-Labs-V2/tree/master/src/main/kotlin/com/alchitry/labs2/hardware/pinout) if you're curious about the full list.

# `OPTIONAL_ATTRIBUTES`

The new part of the constraints are the `OPTIONAL_ATTRIBUTES`.

Each attribute takes the form `ATTRIBUTE(VALUE)`.

There are currently six of attributes; `PINOUT`, `STANDARD`, `FREQUENCY`, `PULL`, `DRIVE`, and `SLEW`.

## `PINOUT`

Let's start with `PINOUT`.
This attribute has two valid values, `V1` and `V2`.
This can be used to specify what version of connectors you are using.

If you're using a V1 board, then `V1` is the only valid option.
If you're using a V2 board and set it to `V1`, the tools assume you are using a [V2 → V1 adapter](https://shop.alchitry.com/products/alchitry-v2-v1-adapter) for those pins.

If `PINOUT` isn't specified, the current board version is assumed.
This is useful in the niche case where you're only specifying pins common across every board like in base `alchitry.acf` file.

## `STANDARD`

The next attribute is `STANDARD`.
This is used to set the IO standard.
Most of the time this is `LVCMOS33` and this was set implicitly before.
If you're using a Cu, then this is the only valid option.
However, if you're using any version of the Au, then there are many more options.
The Xilinx document [UG471](https://docs.amd.com/v/u/en-US/ug471_7Series_SelectIO) goes into a lot of detail about the various options.
Not every option in that document is supported, however.

Each IO standard has its requirements to use it.
The biggest constraint on these is the required VCCO.
VCCO is the voltage used to power that bank of IO pins.
Most banks on the Au are powered by 3.3V.
However, on the Au and Au+, one bank can be switched to 1.8V.
On the Au/Pt V2, that bank can be switched to 2.5V.

The Au/Pt V2 uses 2.5V instead of 1.8V to enable `LVDS_25`.
`LVDS_25` is a pretty common standard and it compatible with a lot of LVDS devices.
You can check the Xilinx document [DS181](https://docs.amd.com/v/u/en-US/ds181_Artix_7_Data_Sheet) for the switching voltages to ensure compatibility with your device.

Other than `LVDS_25` and `LVCMOS33`, you'll likely see `LVCMOS25` for single ended signals on the dual voltage pins and `TMDS_33` for HDMI signals.

## `FREQUENCY`

In the new version of Alchitry Constraints, the `clock` keyword was removed in favor of the `FREQUENCY` attribute.
When you have a clock, you now specify it as any other `pin` but you add the `FREQUENCY` attribute specifying the expected frequency.

The value passed to it takes the same format as clocks before, a value with a unit suffix.
For example, `100MHz` or `500KHz`.

## `PULL`

Before, `pullup` and `pulldown` were keywords you could tak onto the end of a `pin` constraint.
Now the `PULL` attribute takes this place.

For the Cu, `PULL` can have a value of `UP` to enable the pin's pullup.

For the Au/Pt, `PULL` can have a value of `UP`, `DOWN`, or `KEEP`.
`UP` and `DOWN` enable the pin's pullup or pulldown respectively.
`KEEP` enables the pin's keeper.

The keeper will weakly try to keep the pin at its current value.
If the pin is low, the pulldown is enabled.
If the pin is high, the pullup is enabled.

## `DRIVE`

The `DRIVE` attribute is only valid on the Au/Pt.

Some `STANDARD` values allow for a drive setting. 
These include `LVCMOS33`, `LVCMOS25`, and `LVTTL`.

The `DRIVE` attribute takes in a number that specifies how strong that pin should be driven in mA.

Valid values for `LVCMOS33` and `LVCMOS25` include 4, 8, 12, or 16.

Valid values for `LVTTL` include 4, 8, 12, 16, or 24.

The default value is 12.

## `SLEW`

The `SLEW` attribute is only valid on the Au/Pt and for specific `STANDARD` values.
Most standards support it but notably `LVDS_25` does not.

It takes a value of `FAST` or `SLOW` with `SLOW` being the default.

Slew rate is how fast a signal transitions.
Using `FAST` may be a good choice for some high speed signals but may lead to reflections and increased noise if not properly designed for.
`FAST` also requires more power.

# Attribute Blocks

It is common to want to apply the same attribute value to a bunch of pins.
This is where attribute blocks come in!

These take the same form of [connection blocks](@/tutorials/references/lucid-reference.md#connection-blocks) in Lucid.
That is, a comma seperated list of attributes followed by a block of constraints enclosed in braces.

Here's the constraint file for the Io V1 with pulldowns enabled.

```acf,short
PINOUT(V1), STANDARD(LVCMOS33) {
    pin io_led[0][0] B21
    pin io_led[0][1] B20
    pin io_led[0][2] B18
    pin io_led[0][3] B17
    pin io_led[0][4] B15
    pin io_led[0][5] B14
    pin io_led[0][6] B12
    pin io_led[0][7] B11
    pin io_led[1][0] B9
    pin io_led[1][1] B8
    pin io_led[1][2] B6
    pin io_led[1][3] B5
    pin io_led[1][4] B3
    pin io_led[1][5] B2
    pin io_led[1][6] A24
    pin io_led[1][7] A23
    pin io_led[2][0] A21
    pin io_led[2][1] A20
    pin io_led[2][2] A18
    pin io_led[2][3] A17
    pin io_led[2][4] A15
    pin io_led[2][5] A14
    pin io_led[2][6] A12
    pin io_led[2][7] A11

    PULL(DOWN) {
        pin io_dip[0][0] B30
        pin io_dip[0][1] B31
        pin io_dip[0][2] B33
        pin io_dip[0][3] B34
        pin io_dip[0][4] B36
        pin io_dip[0][5] B37
        pin io_dip[0][6] B39
        pin io_dip[0][7] B40
        pin io_dip[1][0] B42
        pin io_dip[1][1] B43
        pin io_dip[1][2] B45
        pin io_dip[1][3] B46
        pin io_dip[1][4] B48
        pin io_dip[1][5] B49
        pin io_dip[1][6] A27
        pin io_dip[1][7] A28
        pin io_dip[2][0] A30
        pin io_dip[2][1] A31
        pin io_dip[2][2] A33
        pin io_dip[2][3] A34
        pin io_dip[2][4] A36
        pin io_dip[2][5] A37
        pin io_dip[2][6] A39
        pin io_dip[2][7] A40

        pin io_button[0] B28
        pin io_button[1] B27
        pin io_button[2] B23
        pin io_button[3] B24
        pin io_button[4] C49
    }
    
    pin io_select[0] A9
    pin io_select[1] A8
    pin io_select[2] A42
    pin io_select[3] A43
    
    pin io_segment[0] A5
    pin io_segment[1] A6
    pin io_segment[2] A48
    pin io_segment[3] A46
    pin io_segment[4] A45
    pin io_segment[5] A3
    pin io_segment[6] A2
    pin io_segment[7] A49
}
```

All the `pin` constraints are enclosed in the first attribute block specifying the `PINOUT` and `STANDARD`.
The `io_dip` and `io_button` signals all also have their pulldowns enabled via the `PULL(DOWN)` block.

Just like in Lucid, these attribute blocks can be nested.

This update adds quite a bit of capability to the ACF format which will allow native support for more projects like HDMI signals on the [Hd](https://shop.alchitry.com/products/alchitry-hd).