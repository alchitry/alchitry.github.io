+++
title = "Lucid V1 to V2"
date = "2024-04-01"
inline_language = "lucid"
+++

This post was created for people who are already familiar with Lucid V1 to get up to speed with what's new/different in Lucid V2.

# Style Changes

Let's start off with the most basic changes, those to style.
## Optional Semicolons

First off, the new Lucid grammar now accepts a new line as a semicolon.

This means that as long as each expression is on a separate line, you don't need to use semicolons at all.

This change was motivated by many modern programming languages.
## Trailing Commas

Again taking inspiration from many other languages, trailing commas in lists are now supported.

```lucid
module trailingComma (
    input clk,  // clock
    input rst,  // reset
    output out, // <- LOOK A COMMA
) ...
```

By making trailing commas optional, it helps make it easier to re-arrange items in a list or add new items to the end without modifying previous lines.

## Camel Case

This is fairly subtle, but camel case is now the preferred naming format for all basic names. The libraries and examples in Lucid V1 were fairly inconsistent between `camelCase` and `snake_case`.

This is just to make things more consistent.

## Struct Position

The first breaking change is that struct sizes are now specified after the array size (or name if there isn't an array size) instead of after the type.

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

## One Module Per File

As the heading says, only one module per file is now allowed.

This probably doesn't change anything for most people but it helps keeps things more organized.

You can still have a `global` declaration and a `module` declaration in the same file.

# No More `.WIDTH`

Something that always felt kind of out of place to me was the `.WIDTH` attribute attached to "all" signals in Lucid V1.

While it worked for the most part, it had two issues I wanted to address. 

First, it just didn't seem to fit. There was nothing else like it in the language.

Second, it could only be used on full signals, not expressions or anything else.

Both of these are fixed by replacing it with the new `$width()` function.

Simply pass in whatever you want and it'll spit out a constant value representing the width of the signal/expression.

This fits much better as there are plenty of other functions to calculate constant values.

The use of `.WIDTH` was in Lucid before there were custom Lucid functions. Otherwise, it probably would've been a function from the beginning.

# Simplification

There are a few changes made to make things a bit simpler.

## `repeat` Loops

For loops were replaced with the new `repeat` loop.

Lucid V1 used _C_ style for loop that were easy to write in a way that would be impossible to implement in hardware.

The new `repeat` loop has the simple syntax of `repeat(count, i) {}` where `count` is a constant expression and `i` is an optional loop variable that will have the values `0` to `count - 1`.

This syntax makes it impossible to write a loop with a variable number of iterations (which hardware can't accommodate). 

## No More `var`

The `var` type was always a bit weird. It was basically just a 32 bit `sig` that you would use with for loops. 

No for loops means you doubly don't need it.

Anywhere you had a `var` before could be replaced with a `sig`.

## Bye `fsm`, Hello `enum`

The type `fsm` was also kind of a weird type. It was a `dff` with a list of constants attached.

Nothing kept you from using these constants in other places in your designs and a few times I did just that. It always felt a little wrong.

Now the `enum` type lets you declare a list of constants that will have their values assigned by the tools just like `fsm` but it is separate from any storage type.

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

Both the parameter `CLK_FREQ` and `BAUD` have test values specified. These values are used when the module is being checked for errors but hasn't been instantiated.

If these values were omitted, the error checking code doesn't know what they could be so it has to do its best to check for potential errors.

You could provided a value with `=` instead of `~` but this allows the parameter to be omitted when it is instantiated.

The `~` version provides a value for the error checker to use but still requires a value to be explicitly presented when instantiated.

# Test Benches

A huge reason for the whole Alchitry Labs/Lucid V2 rewrite was to add simulations.

These have been covered in a [previous post](@/news/lucid-v2-update-2.md)