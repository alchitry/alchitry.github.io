+++
title = "Without Alchitry Labs"
weight = 3
date = "2026-03-25"
+++

This page has reference materials for using Alchitry boards outside of [Alchitry Labs](@/alchitry-labs.md).

<!-- more -->

Most of the time it is recommended to use [Alchitry Labs](@/alchitry-labs.md) to build projects for the Alchitry boards.
However, sometimes people want to use the vendor tools (Vivado and iCEcube2) directly.
This page if for those cases.

# Constraint Files

Whenever a project is built in Alchitry Labs, it generates files that can be used by the vendor tools in the `build` directory.
This can be helpful to have the mapping for pins on headers be done automatically for you.

You can create a basic project, add your constraints, build it, then find the native constraint file in `build/constraint`.
For details on the ACF format, see the [ACF reference page](@/tutorials/references/alchitry-constraints-reference.md).

If you are just trying to use one of the boards we sell, here are some pre-exported constraint files.

## Cu V2

* [Cu Base SDC](/docs/constraints/cu/cu_base.sdc)
* [Cu Base PCF](/docs/constraints/cu/cu_base.pcf)
* [Io](/docs/constraints/cu/cu_io.pcf)
* [Ft](/docs/constraints/cu/cu_ft.pcf)
* [Ft+](/docs/constraints/cu/cu_ft_plus.pcf)

## Au V2

* [Au Base](/docs/constraints/au/au_base.xdc)
* [Io](/docs/constraints/au/au_io.xdc)
* [Ft](/docs/constraints/au/au_ft.xdc)
* [Ft+](/docs/constraints/au/au_ft_plus.xdc)
* [Hd](/docs/constraints/au/au_hd.xdc)
* [DDR MIG Project](/docs/constraints/au/au_mig.prj)
* [DDR MIG Pinout](/docs/constraints/au/au_mig.xdc)

## Pt V2

Because the Pt has connectors on both sides, boards that can be put on either side have different constraints for each.

* [Pt Base](/docs/constraints/pt/pt_base.xdc)
* [Io Top](/docs/constraints/pt/pt_io_top.xdc)
* [Ft Top](/docs/constraints/pt/pt_ft_top.xdc)
* [Ft Bottom](/docs/constraints/pt/pt_ft_bottom.xdc)
* [Ft+ Top](/docs/constraints/pt/pt_ft_plus_top.xdc)
* [Ft+ Bottom](/docs/constraints/pt/pt_ft_plus_bottom.xdc)
* [Hd Top](/docs/constraints/pt/pt_hd_top.xdc)
* [Hd Bottom](/docs/constraints/pt/pt_hd_bottom.xdc)
* [DDR MIG Project](/docs/constraints/pt/pt_mig.prj)
* [DDR MIG Pinout](/docs/constraints/pt/pt_mig.xdc)