+++
title = "Vivado Setup"
weight=0
+++

The first step to setting up your environment is to install Vivado. Vivado is a program provided by Xilinx (the manufacture of the FPGA on the Au) that is used to build your projects. It holds all the secret sauce that converts your text into an FPGA configuration file (bin file).

Head over to Xilinx's website and download the [Vivado here](https://www.xilinx.com/support/download.html). Avoid version 2020.3.

You want the **WebPACK** version for the Au. This is their free tier.

I recommend downloading the **Web Installer** as it will save you time. During installation you get to select what gets installed saving space as well.

You will need to create an account with Xilinx in order to download the software. This is required by the U.S. government since the software falls under some export regulations.

You will also need this account during install for the web installer to be able to download the various components.

## Launching the Installer

If you are running Windows, simply double click the .exe file that you downloaded.

If you are on Linux, you may need to add execution privileges to the .bin file. You can do that with the following command.

```
chmod +x Xilinx_Vivado_File.bin
```

You will need to change the name of the .bin file to match the on you downloaded.

 You can then run it. You don't need root permissions if you are installing it somewhere you already have write permissions. I usually install mine to _/opt/Xilinx_ which I have setup to be owned by me.

## Installing

The installer itself is pretty straight forward. 

First, you will have to login to your account.

![Screenshot_from_2019-03-18_11-45-44.png](https://cdn.alchitry.com/setup/Screenshot_from_2019-03-18_11-45-44.png)

You'll then have to accept some terms and conditions. The page after that asks what edition you would like to install. If you are only using this for the Au, select **WebPACK**. This is the only free version. For more info on the other versions you can go [here](https://www.xilinx.com/products/design-tools/vivado.html).

![Screenshot_from_2019-03-18_11-40-51.png](https://cdn.alchitry.com/setup/Screenshot_from_2019-03-18_11-40-51.png)

The next page allows you to choose what you install. If you are only using Vivado for the Au you can make yours match the screenshot below.

![Screenshot_from_2019-03-18_11-51-13.png](https://cdn.alchitry.com/setup/Screenshot_from_2019-03-18_11-51-13.png)

Note that you can deselect the **Software Development Kit (SDK)** option completely if you want. This is used to develop softcores (processors inside the FPGA fabric).

On the next page, select where you want to install it.

![Screenshot_from_2019-03-18_11-55-29.png](https://cdn.alchitry.com/setup/Screenshot_from_2019-03-18_11-55-29.png)

Now wack that **Install** button and let it do its thing.