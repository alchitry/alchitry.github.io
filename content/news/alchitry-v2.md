+++
title = "Alchitry V2 - All New Boards"
date = "2024-11-13"
+++

It's official, all the boards are being redesigned into a new form factor.
If you saw [the last post](@/news/alchitry-platinum-v2.md), then you'll know the Alchitry Pt is in the works and requires faster connectors.

![Au V2 Render](https://cdn.alchitry.com/boards/AuV2Render.jpg)

The final decision was to change the connectors used to the [DF40 series](https://www.hirose.com/en/product/document?clcode=CL0684-4085-8-51&productname=DF40HC(2.5)-60DS-0.4V(51)&series=DF40&documenttype=Catalog&lang=en&documentid=en_DF40_CAT).
Specifically the DF40HC(4.0)-50DS-0.4V and DF40HC(4.0)-80DS-0.4V.

This was for a few reasons.
The two biggest being availability and signal integrity.
These connectors are widely available from places like DigiKey or Mouser.
They're also rated for up to 20 Gbps when using the short 1.5mm stack height version (possible on the bottom of the Pt where it's needed).
In the 4mm stack height version they're rated for at least 1.3 Gbps which is faster than anything any of the Alchitry boards can do.

The new boards use three of these connectors, two 80 pin and one 50 pin.
The 80 pin connectors are all signal pairs surrounded by grounds.
The 50 pin connector can deliver power to the board, provide 3.3V, and has various control signals like JTAG/Done/Reset.

You can check out the [Au V2 schematic](https://cdn.alchitry.com/docs/Au-V2/AuSchematic.pdf) for the full details.

The layout of the boards has also been improved but more notably, they're now even smaller!
They're now 1 cm narrower at 55mm x 45mm instead of the current 65mm x 45mm.

# Return To Manufacturing

If you've tried to buy an Alchitry board through SparkFun in the last year or so, it's fairly likely they were out of stock of something.
They've been going through some growing pains on their manufacturing line so to keep things flowing, we are now taking back manufacturing of boards.

Since we're making the boards again, it only makes sense that we would also sell them.
I'm happy to announce we have a [shop](https://shop.alchitry.com/) again!

The first wave of new boards are now available for pre-order.
Some of them should ship by the end of the year with a few coming early next year.
The product pages will continue to be updated as development progresses for each board.

Until each board is in stock, we will be offering **20% off pre-orders!**
Having full control over part selection and sourcing allows us to focus on costs and improve the value we're able to offer you.

I hope you're as excited as I am for this new chapter.
Feel free to head over to our [forum](https://forum.alchitry.com/) to discuss the new boards.