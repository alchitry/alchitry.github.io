+++
title = "Alchitry Labs V2 - snake_case"
date = "2024-09-23"
inline_language = "lucid"
+++

Alchitry Labs V2.0.17 just release and is a major shift from previous releases.

# snake_case

When starting on Lucid V2, I had originally though to make `camelCase` the default style for names.
However, I think this was a poor choice for a few reasons and decided to switch to `snake_case`.

The biggest reason to use `snake_case` is because this is what is used by Verilog.
All the Xilinx tools use `snake_case` so when mixing Lucid and Verilog it is nicer to have a consistent style.

Lucid V1 was also mostly documented in `snake_case` but the styling wasn't super consistent.
This is what made me think to switch in the first place.
I generally prefer the aesthetics of `camelCase`, but writing `rst_n` as `rstN` is just awful.

Adding a `_n` or `_p` suffix to names is common with differential signals (as seen in the DDR3 MIG module).
Single letters are hard to discern in `camelCase` and are much better in `snake_case`.

# What Changed

In V2.0.17, all the components and example projects switched to use `snake_case` for names.

Functions names also changed so `$silentTick()` became `$silent_tick()`.

The keyword `testBench` also changed to `testbench`.
It seems a bit inconsistent if the word testbench is two words or one, but it seems like it is more often seen as one.
I also thought using `test_bench` as a keyword felt weird.

## Auto-migration

If you open an older project with Alchitry Labs V2.0.17 or newer, it will automatically migrate your code.
This means files will be renamed and all `camelCase` will be replaced with `snake_case`.

Also, in the Io constraints and examples `ioSel` became `io_select` and `ioSeg` became `io_segment` for clarity.
The migration will change these names as well.

I'm sorry for any inconvenience this causes to anyone already using Alchitry Labs V2, but I believe in the long run this is the better choice.

I'll be updating the tutorials and documentation today to reflect these changes.
