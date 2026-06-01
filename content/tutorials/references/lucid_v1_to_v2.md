+++
title = "Lucid V1 to V2"
weight = 4
date = "2026-06-01"
inline_language = "lucid"
+++

This page covers the major differences from Lucid V1 to Lucid V2.

<!-- more -->

While there was already [a blog post](@/news/lucid-1-vs-2.md) about this, this page has more up-to-date information.

This page should not be treated as a replacement for the [Lucid Reference](@/tutorials/references/lucid-reference.md)
or the [Alchitry Constraints Reference](@/tutorials/references/alchitry-constraints-reference.md).

# Style Changes

Let's start off with the most basic changes, those to style.

## Optional Semicolons

First off, the new Lucid grammar now accepts a new line as a semicolon.

This means that as long as each expression is on a separate line, you don't need to use semicolons at all.

This change was motivated by many modern programming languages.

## Camel Case

This is fairly subtle, but camel case is now the preferred naming format for all basic names. 
The libraries and examples in Lucid V1 were fairly inconsistent between `camelCase` and `snake_case`.

This is just to make things more consistent.

Be aware that this impacts many of the components in the _Components Library_.
Both their names and the names of their ports.
However, the functionality of most of them remain unchanged.

## Struct Position

The first breaking change is that struct sizes are now specified after the array size 
(or name if there isn't an array size) instead of after the type.

For example, before when declaring a `sig` with an array of 8 structs with type `myStruct` you would write the following.

```lucid
sig<myStruct> mySig[8];
```

This is now written as the following.

```lucid
sig mySig[8]<myStruct>
```

This change was made to better match how the elements in the signal are structured.

For example, `mySig[1].structElement` is how you access the `structElement` of the second element in the array.

In both cases, the `sig` is an array of structs so the array index always comes first.

This also makes a bit more sense for the cases when you need to specify the width of a signal that doesn't have a type.

For example, a struct declaration could look like this.

```lucid
struct myStruct {
    structElement<otherStruct>,
    structArray[3]<otherStruct>,
}
```

# No More .WIDTH

Something that always felt kind of out of place to me was the `.WIDTH` attribute attached to "all" signals in Lucid V1.

While it worked for the most part, it had two issues I wanted to address.

First, it just didn't seem to fit. There was nothing else like it in the language.

Second, it could only be used on full signals, not expressions or anything else.

Both of these are fixed by replacing it with the new `$width()` function.

Simply pass in whatever you want, and it'll spit out a constant value representing the width of the signal/expression.

This fits much better as there are plenty of other functions to calculate constant values.

The use of `.WIDTH` was in Lucid before there were custom Lucid functions. 
Otherwise, it probably would've been a function from the beginning.

Note that is behaves a bit differently for multidimensional widths.
Instead of producing an array of values, it now requires you to specify which dimension you want to get the width for.
See [the built-in section of the Lucid Reference](@/tutorials/references/lucid-reference.md#built-in) for details.

# Negative Indices

Many, if not most, of the uses of `.WIDTH` were to get the MSB of an array.
You would commonly do something like the following

```lucid
sig my_sig[PARAMETER_WIDTH]; // width set by a parameter value so unkown
...
my_sig[my_sig.WIDTH-1] = 0; // set MSB to 0
```

While this works, having to type out the width expression can be cumbersome.
This is where the new negative indicies come in.
If you've used something like Python before, these should feel right at home.

```lucid
my_sig[-1] = 0 // sets the MSB to 0 in Lucid V2
```

If the index is negative, it wraps back around from the top.
This means that the index `-1` is always the MSB, `-2` is the bit before the MSB, etc.

This is especially helpful for ranges where you can do something like `my_sig[-1:-3]` to grab the top 3 bits instead of
having to write out `my_sig[my_sig.WIDTH-1:my_sig.WIDTH-3]`.

# Simplification

There are a few changes made to make things a bit simpler.

## `repeat` Loops

For loops were replaced with the new `repeat` loop.

Lucid V1 used _C_ style for loop that were easy to write in a way that would be impossible to implement in hardware.

The new `repeat` loop has the simple syntax of `repeat(i, count, start = 0, step = 1) {}` where `i` is an optional loop variable.
`count` is a constant expression.
`start` and `step` are also constant expressions but are optional.
The loop will repeat `count` times and `i` will be set from `start` to `start + step * (count - 1)`.

This syntax makes it impossible to write a loop with a variable number of iterations (which hardware can't accommodate).

## No More `var`

The `var` type was always a bit weird. It was basically just a 32 bit `sig` that you would use with for loops.

No for loops means you doubly don't need it.

Anywhere you had a `var` before could be replaced with a `sig`.

## Bye `fsm`, Hello `enum`

The type `fsm` was also kind of a weird type. 
It was a `dff` with a list of constants attached.

Nothing kept you from using these constants in other places in your designs and a few times I did just that. 
It always felt a little wrong.

Now the `enum` type lets you declare a list of constants that will have their values assigned by the tools just like `fsm`,
but it is separate from any storage type.

Something like

```lucid
fsm state { IDLE, START_BIT, DATA, STOP_BIT };
...
state.d = state.START_BIT;
```

is now replaced with

```lucid
enum States { IDLE, START_BIT, DATA, STOP_BIT }
dff state[$width(States)]
...
state.d = States.START_BIT
```

Using `$width()` on the `enum` type returns the minimum number of bits needed to represent all the values.

This makes the `dff` type the only storage type.

# Parameter Test Values

In Lucid V1 you had to choose between better error checking and making a parameter optional.

Lucid V2 adds the `~` operator during parameter declaration to allow you to specify a test value.

Here's an example.

```lucid
module uartTx #(
    CLK_FREQ ~ 100000000 : CLK_FREQ > 0,            // clock frequency
    BAUD ~ 1000000 : BAUD > 0 && BAUD <= CLK_FREQ/2 // desired baud rate
)(
```

Both the parameter `CLK_FREQ` and `BAUD` have test values specified. 
These values are used when the module is being checked for errors but hasn't been instantiated.

If these values were omitted, the error checking code doesn't know what they could be so it has to do its best to check for potential errors.

You could provide a value with `=` instead of `~` but this allows the parameter to be omitted when it is instantiated.

The `~` version provides a value for the error checker to use but still requires a value to be explicitly presented when instantiated.

# Test Benches

A huge reason for the whole Alchitry Labs/Lucid V2 rewrite was to add simulations.

These have been covered in a [previous blog post](@/news/lucid-v2-update-2.md)

# Timing and Error Checking

I've sometimes received questions asking why some project worked in Alchitry Labs V1 but not in V2.

There are two cases that cover most of these.

First, Alchitry Labs V1 did **not** check if timing passed.
It was left up to you to look through the build logs to ensure _All constraints were met._
If timing failed to pass, you still got a .bin file, and you could still program your board, but there were no 
guarantees it would work.

Even if it worked, it might not work tomorrow, or after it warms up, or on another FPGA of the same type.

Alchitry Labs V2 looks at the timing report and checks that all constraints were met.
If they fail, it gives you an obvious build error.

The next major reason some code worked in V1 but not V2 is that the error checking in V1 was very lax and riddled with
edge cases that weren't checked.
The new Lucid parser in V2 is much more robust and is able to check for many other types of mistakes that V1 just let slide.

These mistakes, again, would sometimes not be a problem but sometimes would.

The biggest change that I've seen V2 throw new errors are for partially assigned signals.
V2 is now much better at ensuring that every part of a signal has a value under all circumstances.
This is crucial for avoiding latches being introduced into a design which can cause unreported timing errors leading
a design to fail, sometimes sporadically.

# Alchitry Constraints

The format for _Alchitry Constraints_ is mostly the same but now with additional features.

For full details, check out the [Alchitry Constraints Reference](@/tutorials/references/alchitry-constraints-reference.md).

## Optional Semicolons

Just like in Lucid V2, semicolons are now optional and can be replaced with line-breaks.

## Clocks

The biggest change is that the `clock` keyword no longer exists.
Instead, you add a `FREQUENCY` attribute to a `pin` declaration.

For example, instead of...

```acf
pin clk CLOCK;
clock clk 100MHz;
```

You now just do this.

```acf
pin clk CLOCK FREQUENCY(100MHz)
```

Note that in this example `CLOCK` is the name of the signal on the Alchitry board that connects to the 100MHz on-board clock.
If you had an external clock it would be something like `A41` instead.

## Attributes

Speaking of attributes, these are now a thing in ACF V2.

Strictly speaking, you don't need to provide any attributes to use a pin if you want to use the same defaults that 
were assumed in ACF V1.

However, you can now specify different attributes without having to resort to the native constraint formats.

Attributes allow you to specify things like the IO standard when using differential signals or just something not `LVCMOS33`.
They also allow you to specify which side of the board your pinout applies to (important for the 
[Pt](https://shop.alchitry.com/products/alchitry-pt)) and what pinout version you're using 
(important for the [V2 -> V1 adapter](https://shop.alchitry.com/products/alchitry-v2-v1-adapter)).

## Native Blocks

You can now specify blocks of constraints in the FPGA's native format (XDC for Xilinx and SDC for Lattice).
This is useful if you need to really get into the weeds and do things not supported by ACF but still have the convenience of
using the built-in pinout conversion.