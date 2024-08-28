+++
title = "Alchitry Labs V2.0.13 - Verilog Interoperability"
date = "2024-08-28"
inline_language = "lucid"
+++
Today version [V2.0.13](https://github.com/alchitry/Alchitry-Labs-V2/releases/tag/2.0.13) of Alchitry Labs was released!

# Verilog Interoperability

A ton has changed/been added since the last post about [V2.0.8](@/news/alchitry-labs-v2.0.8.md).

The biggest feature, by far, is the addition of Verilog interoperability.

You can now add Verilog modules and instantiate them from Lucid. This was an important missing feature to allow for vendor specific things to be easily integrated into Lucid projects.

For example, in a Verilog module, you can instantiate the primitives outlined in [UG953](https://docs.amd.com/viewer/book-attachment/Lz7t3FLJuzYlv9pBdksO6Q/ob7lIrXtxRMJLY4I6UEprg) for the Au/Au+. This is important for stuff like the upcoming _Alchitry Hd_ that utilizes the `OSERDESE2` primitive to output HDMI video data.

While the entire Verilog module is checked for syntax error in the editor, Alchitry Labs doesn't look at the content inside the Verilog modules. It only ever looks at the module interface (parameters and ports).

This means that Verilog inside Alchitry Labs has a lot less guards in place and should only really be used as glue to existing Verilog.

It also has the major downside that Verilog modules are essentially ignored during simulations.

# String Indexing

To make Verilog smoothly interoperate with Lucid, the indexing for strings was reverted to how it worked in Lucid V1. That is, the right-most letter is index 0 instead of the left-most.

For example, the string `"Hello"` in Lucid is represented as an `[5][8]` array where index `[0]` points to `"o"`. In V2.0.12 and earlier, index `[0]` pointed to `"H"`.

You can use the `$reverse()` function to restore the indexing to the previous behavior.

Verilog uses the right-side indexing so it now matches. This was important for passing strings as parameters which is often done with Xilinx's primitives. Before this change, the Verilog side would see the strings as reversed causing them not to be recognized.

While having the right side of string be index 0 seems a little strange, it does nicely match how arrays and everything else are indexed. Now, the right side is always index 0.

# Build Flow

The way projects are built underwent a huge change. Previously, when building a project, the tools would start with the top-level module and build out a tree of all instantiated modules underneath it. This has the huge benefit of knowing what all the parameter values are as they **must** be specified at this point.

The big downside of this, is that a separate Verilog translation needs to happen for every different combination of parameters on a module. For example, if you used a counter module and set it's parameter `#SIZE(8)` but in another location used the counter with `#SIZE(16)` then two separate Verilog modules would have been generated.

This was a fairly small downside to making all constant values calculable when converting to Verilog. However, it has the big downside of making it impossible to call a Lucid module directly from Verilog.

In the new version, each module is translated to Verilog in isolation properly using parameters. 

This makes it possible for Lucid modules to be used inside Verilog modules.

It also likely helps the build tools to do things more optimally.

# `$isSim()`

A new function, `$isSim()`, was introduced. This function evaluates to `1b1` if running in an interactive simulation and `1b0` otherwise.

This is useful for dealing with the _much_ slower clock speeds when running an interactive simulation (usually around 1,000 Hz instead of 100,000,000 Hz).

For example, providing a different `DIV` parameter value to a `multiSevenSeg` module with the following makes the display work well in simulation and builds.

```lucid
multiSevenSeg seg (#DIV($isSim() ? 1 : 16))
```

Note that `$isSim()` evaluates to `1b0` during test benches.

# Beta Release

Things are getting pretty close to the release of V2.1.0 which will mark the first beta release.

Check out the [V2.1.0 Milestone on GitHub](https://github.com/alchitry/Alchitry-Labs-V2/issues?q=is%3Aopen+is%3Aissue+milestone%3A%222.1.0+Beta+Release%22) to track the remaining features to be added before the release.

If you're using the preview builds and run into any issues, be sure to report them on [GitHub](https://github.com/alchitry/Alchitry-Labs-V2/issues) so I can get them fixed ASAP!