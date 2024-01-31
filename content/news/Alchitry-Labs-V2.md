+++
title = "Alchitry Labs V2"
date = "2023-06-07"
inline_language = "lucid"
+++

I am now starting to work on the UI of the Alchitry Labs rewrite!

Alchitry Labs currently use UI toolkit, SWT. 
This is the UI toolkit developed and used by Eclipse.
At the time I started working on what was then the Mojo IDE, SWT was a solid choice.
It allowed me to create a single UI that worked on Windows and Linux with minimal effort, and it looked native on both
platforms.

However, it hasn't aged super well.

I found it to be fairly limited when trying to do anything custom.
For example, I wanted the project tree on the left side of the window to stay the same size when you resized the window.
The main code editor should be the only thing that changes size to accommodate the new window size.
SWT doesn't allow for this, and instead you specify the size of each side as a percent.
My workaround was to recalculate the percentages every time the window size changes to keep one side a fixed size.
This mostly works, but if you resize the window a lot, you may notice the divider jumps around due to rounding errors.

In newer versions of SWT, something changed/broke that broke the tooltip window from popping up when hovering over an
error in the text editor.
I spend a stupid amount of time trying to figure out a fix for this before giving up and sticking with an old version
of the library.
This annoyingly prevents other bugs from getting fixed though.

One of the worst offenders is the undo/redo bug in the current Alchitry Labs. 
I've spent days trying to get the undo/redo function to be reliable, but for whatever reason, the way SWT handles the
edit events have prevented me from getting it to always work. V2 already has a fully reliable undo/redo working.

TLDR, I'm moving to something else.

## Jetpack Compose

If you do any UI work and haven't tried [Jetpack Compose](https://github.com/JetBrains/compose-multiplatform) you're 
missing out.

This is a declarative UI framework originally developed for use on Android, but it has since made its way onto more 
platforms including desktop.

I find it a joy to use, and it doesn't lock you into anything allowing me to create whatever custom UI elements or 
tweaks I need.

Unfortunately, the built-in text editor (TextField) has terrible performance if you are trying to edit any decent amount
of text.
This led me to write my own custom editor that has solid performance for thousands of lines of code.

While this was a substantial amount of work, it also opens up potential in the future for doing cool tricks like 
collapsable blocks. This was impossible with SWT.

## Lucid Parser

I've also implemented the snapshots for `$tick` and added `$silentTick` which skips the snapshot step.
The snapshots get compiled into a simulation result that holds the value of every signal in the design for every call
of `$tick`.


This will allow the UI to display the results of the entire simulation.

## The Repo

The Lucid Parser repo has been renamed to [Alchitry Labs V2](https://github.com/alchitry/Alchitry-Labs-V2) and now 
contains the UI and parser code. 
This is where all the progress can be found.

There is a [discussion page](https://github.com/alchitry/Alchitry-Labs-V2/discussions), or you can 
[email me](mailto:justin@alchitry.com) and let me know your thoughts.
