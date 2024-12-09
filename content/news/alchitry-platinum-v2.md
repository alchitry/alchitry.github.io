+++
title = "Alchitry Platinum and Board Rework"
date = "2024-10-09"
inline_language = "lucid"
+++

The Alchitry Platinum (Pt), is in the early stages of design. 
This version will most likely be based on the XC7A100T-2FGG484C FPGA.
<!-- more -->
This is the same FPGA as the Au+ but in a bigger package with more IO.
The major selling point of this package is the addition of 6.25 Gbps GTP transceivers.
These open up the possibility of much higher interfaces such as PCIe 2.0.

However, it's a bit unclear as to weather or not the current style of connectors would support speeds that fast.
The current connectors were chosen for their high pin density and low cost.
Their datasheets ([19008](http://www.4uconnector.com/online/object/4udrawing/19008.pdf) and [19022](http://www.4uconnector.com/online/object/4udrawing/19022.pdf)) make no mention of signal integrity.

To ensure the high speed signals are solid, we've been looking into other connectors such as the [DF40HC(3.0)-100DS-0.4V](https://www.hirose.com/en/product/document?clcode=CL0684-4085-8-51&productname=DF40HC(2.5)-60DS-0.4V(51)&series=DF40&documenttype=Catalog&lang=en&documentid=en_DF40_CAT).
These are nice since they can easily handle the high speed signals and are readily available (both lacking in the current connectors).

This brings me to the crux of the design.
There are two paths we could take.

The first, would be to use new connectors on the bottom of the Pt to carry the high speed signals and the current connectors on the top maintaining compatibility with all existing products.

The second, would be to use new connectors on both sides of the board.
All the current boards would be redesigned to use the new connectors.
Adapters would be made to convert from the new connectors to the old (and maybe old to the new) to continue to support legacy products.

The pros and cons for the first case are fairly straight forward.
The biggest pro, is the status quo is maintained.
Any existing third-party designs would continue to work with no changes needed.
Any investment in the current (although fairly limited) catalog of elements would be directly usable.

Cons for the first are that there would now be two types of connectors. 
Boards would have to be designed specifically to go on the bottom of the Pt and couldn't be used elsewhere.
Boards designed for the top of other boards couldn't be placed on the bottom of the Pt.

In an interesting set of conditions, using the new connectors would actually be a bit cheaper than the old connectors.
This is in part due to only using two 100 pin connectors per side instead of four 50 pin connectors.
The cost difference isn't significant on a board like the Au or Pt but would be on boards like the Br that is almost entirely based on the connector cost.

The biggest pro for migrating everything to the new connectors is that the Pt would be able to use most stackable elements on either side.
This would allow for combinations of boards that normally wouldn't work because of pin conflicts.

Currently, I'm leaning towards a full redesign using new connectors.
I think long term this would open up more possibilities and now that Alchitry Labs V2 is nearing a releasable state, more of my time is focused on new hardware.
If there is going to be a switch, it will have to happen now before a wave of new elements come out.

I'd love to hear your feedback. 
There is a [thread on the forum](https://forum.alchitry.com/t/alchitry-platinum-planning/1811/3) where you can let me know your thoughts.
I'd also be interested in hearing any features or changes you'd like to see on the new boards.

Thanks for taking the time to read this and for any feedback you can give!



