+++
title = "Lucid V2"
date = "2023-05-18"
inline_language = "lucid"
+++

A full rewrite of the Lucid parser in Alchitry Labs has been a long time coming.
<!-- more -->

The current parser has had feature after feature crudely bolted on to a shaky foundation. It was originally only written
to convert Lucid into Verilog. Later, error checking for signal widths was added. Then full parsing on constant values
was added. Then parsing of non-constant values was kind of added. Then... then... then...

A lot of the code is confusing and many sections are redundant. On top of that, null checks weren't my specialty and
I often forgot to check when something could've been null resulting in a crash when bad syntax was entered.

The new parser is fixing all this while adding many more features. It is written in Kotlin which largely fixes null 
checks by having null safe types built into the language.

## Breaking Changes

I'm also taking this opportunity to re-imagine some aspects of Lucid. Because of this, Lucid 2 will break compatibility
with the original Lucid.

For example, currently you can use the `.WIDTH` property of signals in Lucid to access their dimensions (number of bits).
In Lucid 2, this is getting replaced by the `$widthOf()` function. This will allow you to not only get the widths of 
signals but also expressions. It also helps clean up the internal code when resolving signals.

The `fsm` type is being removed and being replaced with `enum`. The `fsm` type was kind of a strange type in that it 
really was just a `dff` with an associated set of constants. The new method is to use `enum` to declare a set of 
constants and use a `dff` to hold them. Here's an example.

```lucid
enum myFSM { INIT, START, RUN, STOP }
dff myDff[$widthOf(myFSM)]

always {
    myDff.d = myFSM.START
}
```

This simplifies things by making `dff` the only sequential type.

The eagle eyed among you may have noticed that there aren't any semicolons in the above code snippet. Semicolons are
optional in Lucid 2. 

The `var` type is also being removed. The only real use for the `var` type was in `for` loops which you could still use
a `sig` type for. It wasn't particularly intuitive as it had the size of a computer `Int` when everything else a single
bit.

Speaking of `for` loops, these are replaced with `repeat` blocks. These have the syntax `repeat(count, var) { ... }` 
where `count` is the number of times to repeat the block and `var` is the name to use for the current iteration index.
This signal is automatically generated for you and you don't need to declare it somewhere else. It is only visible 
inside the repeat block.

There are a handful of other minor changes. When declaring a `dff` or `sig`, you can now only declare one per line.
Declaring multiple off the same keyword was rarely used and often made the code harder to read. Removing this also
made the backend code cleaner.

The struct portion of a declaration was moved after the array indices. An old `dff` declaration with that
used a struct used to look like this `dff<myStruct> myDff[8] (.clk(clk));`. It now looks like this 
`dff myDff[8]<myStruct> (.clk(clk))`. The original style was based on generics in languages like Java, but the new style
fits better with how you actually index the values. It makes it much clearer that `myDff` is an array of structs.

## New Additions

There will be some new functions to help when working with fixed point numbers. I haven't nailed all these down yet but
something along the lines of `$fixedPoint(3.14159, 8, 4)` will generate an 8-bit wide number with 4 bits used for the
decimal (aka `8b00110010`) that is the closest approximation to the 3.14159. There will also be ceiling and floor 
versions that generate the closet value above or below the given value respectively.

I'm also planning to implement interfaces. These will basically be like `struct` but each member will have a direction
associated with it. I found myself often creating two `struct` where one would be for inputs and one would be for 
outputs. For example, the `memory.in` and `memory.out` structs used by the 
[DDR interface](@/tutorials/archive/lucid_v1/ddr3-memory.md).

Interfaces will allow combining these into a single port. There will be "a" and "b" versions of each interface where
the "b" version is a mirrored copy of "a" (inputs are outputs, outputs are inputs). That way a module with an "a" port 
can directly connect to a module with a "b" port.

## Simulation

A big motivator for the rewrite was the potential to do full Lucid simulations. The old code would parse constant 
expressions, but it only hinted at the possibility to do a full simulation by iterating the parsing.

The new code builds a full model of your project complete with signal connections, models for always blocks, and other
dynamic expressions. This not only helps with more robust error checking (it's hard to miss something when you're 
required to actually model it all) but will allow for quick simple simulations to check if your logic is working how
you expect.

Much of this is already working. The details are more than the scope of this post, but check out the link to the source
below for details on how it works.

As part of doing simulations, a new `testBench` will be created. I haven't nailed down the specifics for this either
just quiet yet but the current idea is for a `testBench` to look similar to a `module`. Inside the `testBench`, you
will be able to instantiate your module to test. You can then test it via `test` and `function` blocks.

The `test` blocks will work similar to an `always` block in that the contents will run sequentially.

The `function` blocks will be the same except they won't run on their own and can instead be called by `test` blocks.
I'm imagining these being used for common tasks like cycling a clock. For example, something like 
`repeat(100) { cycleClock() }`. The syntax for this is very much still up in the air.

## Source and Discussion

Head over to our [GitHub](https://github.com/alchitry/LucidParserV2) page to check out the current state of things.

There is also a [discussion page](https://github.com/alchitry/LucidParserV2/discussions) setup as part of the repo
where you can let me know your thoughts.
