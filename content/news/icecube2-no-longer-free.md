+++
title = "iCEcube2 No Longer Free"
date = 2024-04-17
updated = 2024-05-06
+++

{% callout(type="info") %}
Lattice has since added a note about free licenses for "hobbyists, enthusiasts, community educators & start-up companies." See the Licensing section at the bottom of [this page](https://www.latticesemi.com/iCEcube2).
{% end %}

It appears that Lattice Semiconductors, the manufacture of the FPGA used in the [Cu](@/boards/cu.md), has decided to pull a fast one and silently change the license required to use [iCEcube2](@/tutorials/introduction/icecube2.md) from free to an __expensive__ subscription.

It's unclear when exactly this change happened, but looking at the latest snapshot from [the wayback machine](https://web.archive.org/web/20240224150050/https://www.latticesemi.com/Support/Licensing) on February 24th, 2024, it was still free.

On the [live site](https://www.latticesemi.com/Support/Licensing) iCEcube2 is now only listed as _Subscription_ for all FPGA families it supports.

Heading over to their [online store](https://www.latticestore.com/products/tabid/417/searchid/1/searchvalue/lsc-sw-icecube2/default.aspx), I'm currently seeing pricing of __$471.31__ for the first year and __$353.15__ to renew each additional year.

This is insane!

iCEcube2 hasn't had any meaningful software updates in many many years. Just take a look at the [versions](https://www.latticesemi.com/Products/DesignSoftwareAndIP/FPGAandLDS/iCEcube2#_B014C41EC7EA406C8BF8E943EABA6317).

The only thing that makes sense to me is that they very much do __not__ want you to use it.

# Contact Lattice

If this change bothers you as much as it does me, I highly encourage you to [contact Lattice](https://www.latticesemi.com/en/About/ContactUs) and let them know what you think. [Click here for their general inquiries email](mailto:general_inquiries@latticesemi.com).

I've sent them an email asking what's going on and I'll update this post if/when they respond.

# A Beacon of Hope

Luckily, we have an alternative, [Project IceStorm](https://github.com/YosysHQ/icestorm) and [Yosys](https://github.com/YosysHQ) more generally.

The open source tools for FPGAs have continued to improve and my latest experiences with them for the [Alchitry Cu](@/boards/cu.md) have been excellent.

[Alchitry Labs V2](@/alchitry-labs.md) comes with all the necessary open source tools bundled to work with the Cu without having to compile/install anything else.