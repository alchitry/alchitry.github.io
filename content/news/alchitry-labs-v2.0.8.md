+++
title = "Alchitry Labs V2.0.8"
date = "2024-05-14"
inline_language = "lucid"
+++

![Alchitry Labs 2.0.8](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.8-preview.gif)

Yesterday version 2.0.8 of [Alchitry Labs](@/alchitry-labs.md) was released.

It's been a while since 2.0.7 was released, so I'll do my best not to miss any import updates.

First off, there is now an official [Lucid V2 Reference](@/tutorials/references/lucid-reference.md). This page should be able to answer any questions you have about the details of Lucid V2.

# Known Values

A major refactoring was done for determining if a value is _constant_. The old code would keep track of if a value was constant or not with a simple boolean.

This became a problem when working with `repeat` blocks. The issue is that the loop variable isn't constant but it is known during synthesis and should be able to be used like a constant.

To fix this, the state of an expression is now marked as _dynamic_, _known_, or _constant_.

An important example of this is in the `binToDec` component that uses the `$pow()` function with a loop variable.

```lucid
sig scale[$width(value)] = $pow(10, j)      // get the scale for the digit
```

The value of `j` is different for each loop iteration but can be replaced with a constant during synthesis.

The `$pow()` function accepts arguments that are _known_.

# Updated Repeat Block

The `repeat` block has been modified a bit.

The old syntax was `repeat(count, i)` where `count` was the number of times to loop and `i` was the optional loop variable that would be between `0` and `count-1`.

The repeat block can now take the form `repeat(count)` where `count` is the number of loops and there is no loop variable (like before). However, it can also take the form `repeat(i, count, start, step)` where `i` and `count` are as before (but switched positions). The parameters `start` and `step` are optional and specify the starting value and amount to increment by each loop.

If omitted they default to `start = 0` and `step = 1`.

Note that this is a breaking change as the form `repeat(count, i)` is now `repeat(i, count)`.

# Component Library

The component library has been added. It can be accessed by the three box icon in the main toolbar.

![Component Library](https://cdn.alchitry.com/labs-v2/component-library.png)

Components are now designated in the project tree buy the same three box icon.

# Example Projects

In addition to the components being added, the project templates have been added as well.

This means you can easily start a project for the Io with the Io Base or Io Demo templates.

# Toolchain Settings

A settings menu was added under the main drop down that is accessed by click on the Alchitry logo.

Currently, it is populated with the toolchain settings. These let you select the locations for your Vivado and iCEcube2 installs.

There is also an option to toggle between the built in Yosys toolchain or iCEcube2 when working with the Cu.

The Yosys toolchain was updated in the Linux build to not require that a specific version of Python be installed.