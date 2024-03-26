+++
title = "Alchitry Labs V2 - Update 2"
date = "2024-01-04"
+++

It's been a while since I've posted an update and a lot has happened. Most of the work I've been putting into Alchitry Labs has been for the new GUI.

![Alchitry Labs 2.0.3 PREVIEW](https://cdn.alchitry.com/labs-v2/alchitry-labs-2.0.3-preview.png)

As I've mentioned in a previous blog post, this time around I'm using [Compose Multiplatform](https://www.jetbrains.com/lp/compose-multiplatform/) for creating the UI instead of the now very old [SWT](https://www.eclipse.org/swt/).

Compose is fundamentally different from SWT and allows for a lot more freedom in creating a beautiful UI. However, since Compose for desktop is so new, there are some growing pains I've had to overcome.

## Code Editor

One of the first things I did when starting the Alchitry Labs rewrite was to see if I could make a text editor perform well with Compose. The built in `TextField` widget is fine for small text fields but falls apart for something as complicated as a code editor.

Compose exposes various levels of abstraction you can dig into depending on what you want to accomplish. I jumped a few layers down and created my own code editor composable. 

The most important difference between my code editor and the built in `TextField` is that my code computes the layout of each line individually instead of the entire block of text. The big upside to this is that when text is being edited I only need to compute the lines that change instead of every single line.

This makes editing text fast no matter how big the file is.

There was a lot of complexity added to make this work but the payoff was worth it.

In addition to performance, I was able to add some additional features that are nice to have for the code editor, such as the line numbers in the gutter. These are even flexible so I can potentially later add stuff like icons if needed.

`TextField` also doesn't provide any way to draw a background color behind text so I had to add this custom. This allows for highlighting the token the cursor is on as well as all matching tokens. 

## Tabs

The next major UI hurdle was making the editor tabs work. I already had written a sash composable that would allow me to split a section into left and right or top and bottom resize-able areas (I needed it already for the main layout). However, I wanted to make splitting the editor be as easy as dragging a dropping the tab to where you want it.

Again, compose gives you plenty of tools to do this and I had already done something similar for a different project that I was able to steal most of the code from. With some modifications I ended up where it is now where you can not only drag and drop the tabs to rearrange them but drag them top any side of the window to split it.

This is definitely a step up from the previous version that requires you to split then window then drag the tab over.

## Project Tree

This is something that still needs some work, but one of the new features is that file names in the tree are color coded based on their state (yellow = has warnings, red = has errors).

This was possible because the way projects/files are checked for errors is fundamentally different than before.

When a file is changed, an error check is queued. The error check first parses all the project files for errors like syntax errors. Then starting from the top module, the project is parsed as a tree through the module instances.

This allows for a thorough check of the modules using actual parameter values. 

Some of this could be improved in the future such as caching some of the results for files that haven't changed, but even as it is now it is quite fast.

It currently doesn't fully check modules that fall outside the project tree (in other words, modules that are in the project but not used). I'll add this in a later update.

## Labs and Loader

Alchitry Labs and the Alchitry Loader now share one executable/launcher. This was done because it isn't possible to create two launchers with one installer on macOS.

Instead, when you open Alchitry Labs, it'll open whatever you were using last.

To switch between Labs and the Loader, you simply click the Alchitry logo in the top left and choose "Switch to X"

I have a feeling that most people are using either one or the other and don't often switch between the two. If this isn't you, let me know on the [discussion page](https://github.com/alchitry/LucidParserV2/discussions).

## Test It Out

There is still a lot of features missing, but if you would like you can download the [latest version here](https://alchitry.com/Alchitry-Labs-V2/download.html).

Everything should be there to make a simple project, build, and load it to any of the Alchitry boards.

This also means you should be able to use this to build projects for the Alchitry Cu on a Mac.

## Next Steps

The code editor needs many quality of life improvements such as auto indenting/formatting, auto-complete, support for Verilog, error checking for ACF files, support for Xilinx and Lattice constraint files, context menus (right click), and I'm sure endless more.

I need to also add in the component library, port the project templates to Lucid V2, and add back in support the Vivado's IP catalog.

I also need to build the front end for running simulations. All the code is there to actually run it, there just isn't currently a way to conveniently start it or view the results. This will likely be my first next step.