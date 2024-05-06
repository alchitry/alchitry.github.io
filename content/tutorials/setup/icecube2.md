+++
title = "iCEcube2 Setup"
weight=1
+++

The first step to setting up your environment is to install iCEcube2. iCEcube2 is a program provided by Lattice (the manufacture of the FPGA on the Cu) that is used to build your projects. It holds all the secret sauce that converts your text into an FPGA configuration file (bin file).

Head over to Lattice's website and download the [latest version of iCEcube2 here](http://www.latticesemi.com/iCEcube2).

The download links are at the bottom of the page.

You will need to create an account to download the software and create a (free) license file for it.

## Getting a License

Before launching the installer, you should get a license file.

Lattice used to offer free licenses to anyone but now offers free licenses only to "hobbyists, enthusiasts, community educators & start-up companies."

Go to the _Licensing_ section of [this page](https://www.latticesemi.com/iCEcube2) for information on how to get a license.

You may need your MAC address for the license.

On Windows, open the command prompt and type in the following.

```bash
ipconfig /all
```

It is labeled as _Physical Address_.

On Ubuntu 18.10, you can find your MAC in Settings->Network->Wired (or Wireless)->Gear Icon. It's labeled as _Hardware Address_ under the _Details_ tab. 

Alternatively, you can find it with the following command.

```bash
ip link show
```

The MAC address format on Linux is colon separated but Lattice wants dashes so swap them after you copy paste it.

They will email you a license file for that MAC address.

You will need to download this file and put it somewhere safe. iCEcube2 will require that it stays where you put it.

## Launching the Installer

### Windows

You should be able to extract file you downloaded and simply double click to run it.

### Linux

If you are using Ubuntu you will need to install a bunch of 32bit packages to be able to run the software. You can run the following command to do this.

```bash
sudo apt-get install libxext6:i386 libsm6:i386 libxi-dev:i386 libxrandr-dev:i386 libxcursor-dev:i386 libxinerama-dev:i386 libfreetype6:i386 libfontconfig:i386 libglib2.0-0:i386 libstdc++6:i386
```

On Ubuntu 18.10, the version of libpng that is available is libpng16 but iCEcube2 looks for libpng12. You can download the .deb package [here](https://vhdlwhiz.com/wp-content/uploads/2020/05/libpng12-0_1.2.54-1ubuntu1b_i386.deb).

Most Linux systems don't use the old _eth0_ naming convention for your network interface anymore. However, the licensing system of iCEcube2 does.

You can make Ubuntu name your network interface _eth0_ by creating a udev rule.

Run the following command to open a text editor.

```bash
sudo gedit /etc/udev/rules.d/10-net-naming.rules
```

The paste the following line in. You will need to change the fake MAC address _aa:bb:cc:dd:ee:ff_ to your actual MAC address you found earlier. Save the file and close the editor.

```lucid
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:bb:cc:dd:ee:ff", NAME="eth0"
```

You will need to reboot for this to take effect.

On Linux you don't need root permissions if you are installing it somewhere you already have write permissions. I usually install mine to _/opt/lattice/icecube2_ which I have setup to be owned by me. By default, it tries to install it to your home directory.

You should now be able to run the installer.

If you run into syntax issues when building this is typically because the scrips in the iceCube2 install are set to use /bin/sh which points to Dash by default on Ubuntu. You can set this to Bash using the following command and selecting _No_.

```bash
sudo dpkg-reconfigure dash
```

### Installing

The installer itself is pretty straight forward. 

![Screenshot_from_2019-03-21_14-54-20.png](https://cdn.alchitry.com/setup/Screenshot_from_2019-03-21_14-54-20.png)

Just run through pointing it to where you want it installed and your license file you downloaded.