+++
title = "Lucid V2 - Update 1"
date = "2023-05-30"
inline_language = "lucid"
+++

I just pushed what I believe is the last piece of the core Lucid 2 rewrite. Since the last update, I added `$widthOf()`,
 `$fixedPoint()`, `$cFixedPoint()`, and `$fFixedPoint()` functions.

The `$widthOf()` function takes one argument and returns its width (number of bits). If the value is an array, the 
returned value is also an array with each entry the width of the dimension. 

For example, `$widthOf({8b0, 8b1})` will return an array `{8, 2}` since the first dimension has two elements and the 
inner dimension has 8. Remember that in Lucid (and all HDLs) arrays are indexed right to left to match bit numbers
instead of left to right like most programming languages.

If you read the [original post](https://alchitry.com/news/lucid-v2), you may remember for enums I presented the syntax
`$widthOf(myFSM)` to get the width of the enum. I ended up scrapping this since passing `myFSM` as an argument would 
be a weird exception since you can't use enums directly anywhere else. Instead, I added the `.WIDTH` constant just to 
enums. So you can now get the width of an enum by using `myFSM.WIDTH` or `$widthOf(myFSM.INIT)` (where `INIT` is any 
member of `myFSM`).

## Fixed Point

The fixed point functions work as expected. The basic one, `$fixedPoint()`, takes three arguments, the value to convert,
 the total width, and the fractional width. It returns the fixed point value that is closest to the given value.

The function `$cFixedPoint()` takes the same arguments but returns the closet value that is greater than or equal to
the given value.

The function `$fFixedPoint()` is the same but returns the closet value that is less than or equal to the given value.

## Interfaces

I attempted to implement interfaces, but along the way I discovered they were just too complicated to add at this point 
for what I believe to be a relatively niche feature.

They presented many weird cases that would be difficult to deal with such as an array of modules that used an interface.

In the end, I decided using structs was a decent compromise to the added complexity.

## Next Step

The next step is to add test benches. I think I have most of this flushed out in my mind (again refer to the 
[previous post](https://alchitry.com/news/lucid-v2) for details) but now it's time to get it down in code.

I don't anticipate this being too difficult to write since the groundwork for simulations is already all there. In 
[my tests](https://github.com/alchitry/LucidParserV2/blob/466cdff73db24370cc8cf0f493eaa8d9a996ba21/src/test/kotlin/ModuleInstanceTests.kt#L79)
I've already simulated modules of counters.

Once that's done, it'll be on to creating the Verilog translator.

As before, there is a [discussion page](https://github.com/alchitry/LucidParserV2/discussions) setup as part of the repo
where you can let me know your thoughts.