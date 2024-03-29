+++
title = "ISE Setup"
weight=2
+++

ISE is a program created by Xilinx to support their FPGAs. It includes a bunch of other tools that will be useful for creating your projects. ISE is required to do any work because it is what actually synthesizes your designs into bit files that can be loaded onto the Mojo.

The process is fairly long, but it shouldn't be too tricky if you follow these instructions. These instructions were written for ISE 14.7 and tested on Ubuntu 12.04, Ubuntu 12.10, Linux Mint, Windows 7, Windows 8, and Windows 10.

A quick note for Windows 10. Xilinx doesn't officially support Windows 10 but with a simple work around it should run just fine. They recently released a "Windows 10" version that is really just the Linux version bundled with a virtual machine to run on Windows. This version won't work with the Mojo IDE. I highly recommend using the older version which is now labeled as "Windows 7" even on Windows 10. There is a simple workaround explained in the "Windows 10 64bit" section below that makes this version work.

First [click here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html) to go to the Xilinx downloads page. Under "Version" select 14.7. **Do not select "14.7 (Windows 10)" even if you are using Windows 10.** Scroll down a bit until you see **ISE Design Suite**. Under that header you should see full installers for Windows and Linux. Choose the one for the system you are installing ISE on.

You will then be prompted to login. If you don't have an account, create one. Once you have logged in the download should start.

If you have Java installed, you may be prompted to use their "Download Manager", if not it will just start like any other download. The method you use does not make a difference; however, if you have problems with the download manager you can disable Java in your browser and try again to prevent it from using it.

The file is big, about 6.5GB, so make sure you have plenty of space! (Also, the installation requires a further 16GB of space.)

Once the file is downloaded you need to decompress it. The file is a tar file so if you are on Windows you will need to install something like [7-Zip](http://www.7-zip.org/download.html). Some tar extractors fail to properly extact this archive. 7-Zip is known to work so if you have trouble with the installer, try extracting it with 7-Zip.

For Windows, just open the folder and double click on **xsetup** to start the installation.

For Linux, you will need to open up a terminal and cd into the directory where you extracted the files. Then run the setup with **sudo ./xsetup**.

Once in the setup, accept all the license agreements. Once you are on the page that asks which edition to install, choose the **ISE WebPACK** option and click next.

![win_select.jpg](https://cdn.alchitry.com/setup/win_select.jpg)

You are then prompted to select what you would like to install. You only need to select the first option as shown. If you are running Windows 8 on a 64bit computer, you don't need to check anything as the built-in license manager doesn't work anyways. I've also been told that having **Use multiple CPU cores for faster installation** can cause it to lock up during install, but I personally haven't had that happen.

![lin_license.jpg](https://cdn.alchitry.com/setup/lin_license.jpg)

Once the install is done you should be prompted to get a license.

Choose the **Get Free ISE WebPack License** option and click next.

If you are using Windows clicking **Connect Now** should open up a webpage for you. If you are on Linux you will probably be shown the same prompt, but if clicking **Connect Now** doesn't work you can go to [http://www.xilinx.com/getlicense](http://www.xilinx.com/getlicense).

From that page login and select **ISE Design Suite: WebPACK License**. Click on the button in the bottom left labeled **Generate Node-Locked License**.

Click next twice and you should be emailed your license! Open up your email and download the .lic file.

Now go back to the installation window. Under the **Manage Xilinx Licenses** tab click **Copy License...** and select your .lic file. If you are on Windows 8, clicking **Copy License...** will crash the license manager. See below how to get your license setup in Windows 8.

Once it finishes copying the license file you can close the window. ISE is now installed and ready to use!

If you are a Windows user you can stop here. However, if you are using Linux the following steps will make it easier to use ISE.

## Windows 8.1/10

Xilinx has released a guide for overcoming the common problems with Windows 8.1 and 10. [Check out the guide here.](http://www.xilinx.com/support/answers/62380.html)

## Windows 10 64bit

The latest updates to Windows 10 seem to break PlanAhead. The second part of [this post](https://www.eevblog.com/forum/microcontrollers/guide-getting-xilinx-ise-to-work-with-windows-8-64-bit/) titled "Fixing PlanAhead not opening from 64-bit Project Navigator" seemed to fix the issue.

## Windows 8 64bit

To get your license installed in Windows 8 you need to create a folder in the root of your home drive (usually C). Name the folder ".xilinx." note both dots. Once you made the folder it should show up as ".xilinx" (no trailing dot). For whatever reason, Windows requires you to have that trailing dot and it removes it automatically. Once you have that folder created just drop your Xilinx.lic file into it. ISE should now find the license file and open without complaints.

The 64bit version of ISE doesn't work correctly in Windows 8. Every time it tries to open a file dialog it crashes. To fix this you need to use the 32bit version.

First navigate to C:\Xilinx\14.7\ISE_DS\ISE\bin

The **nt** folders contain the executables. Right now any shortcuts you have and file associations point to the 64bit version. Move into the **nt** folder.

Copy the file **ise**. Move back to the **bin** folder and into the **nt64** folder. Rename the current **ise** file to **ise64** and paste the 32bit version of the **ise** file. This will make sure you use the 32bit version.

If you would like a shortcut on your start screen, rename the file you just pasted into **nt64** to **ISE Design Suite**. Then right click it and choose **pin to start**.

![](https://cdn.alchitry.com/setup/image-asset.png)

Once it is pinned you need to rename it back to **ise**. I found that trick of renaming, pinning, change name back to be useful to make the launcher on the start page.

## Creating a launcher in Linux

Open up a terminal and enter

```bash
cd /opt/Xilinx/14.7/ISE_DSsudo gedit run_ise.sh
```

In the text editor paste the following code.

```bash
#!/bin/bash. /opt/Xilinx/14.7/ISE_DS/settingsXX.shise
```

Make sure you replace XX with the type of computer you are using (32 for 32bit computers;  64 for 64bit computers).

Save and close the file. Then back in the command line enter the following.

```bash
sudo chmod +x run_ise.sh
```

This will make the file you just created executable.

The following applies to Ubuntu. If you are using Linux Mint just right click on the **Menu** button and click **Edit menu**. From there you can create a launcher the same way as shown below.

Enter the following in the terminal.

```bash
sudo apt-get install --no-install-recommends gnome-panelsudo gnome-desktop-item-edit /usr/share/applications/ --create-new
```

![launcher_ubuntu.png](https://cdn.alchitry.com/setup/launcher_ubuntu.png)

Fill out the form as shown. For the command select the run_ise.sh file you created in /opt/Xilinx/14.7/ISE_DS.

An icon can be found at /opt/Xilinx/14.7/ISE_DS/ISE/data/images/pn-ise.png

Click OK to create the launcher.

ISE should now show up in Unity.