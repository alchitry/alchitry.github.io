+++
title = "Alchitry Loader V2"
date = "2023-09-18"
+++

The Alchitry Loader portion of the Alchitry Labs V2 rewrite is mostly done!

![Alchitry Loader](https://cdn.alchitry.com/labs-v2/loader-alpha.png)

The new loader automatically detects connected boards and lists them in a drop down. This allows you to have more than one board connected without conflict.

Under the hood, it now also handles the D2XX driver a bit more elegantly. It first tries to load the proprietary D2XX library (libd2xx) and if it fails, it falls back to the open source libUSB driver.

On Windows, you'll almost always be using D2XX from FTDI. However, on Linux, libUSB is the default but you can install libd2xx and it'll be detected and used.

There are still a few weird kinks to work out but it is overall usable (and an improvement over the old one).

On Windows, I haven't been able to figure out how to configure the installer to not install a shortcut for the command line interface version of the launcher. After running the installer, you'll see a shortcut called "alchitry" which doesn't seem to do anything. This is the command line interface launcher.

There seems to be a bug in `jpackage` that ignores the value of the `--win-shortcut` option and always makes shortcuts. I'll have to dig into more eventually.

On Linux, I've been having a hard time getting the window's icon to be set correctly. On Gnome, it seems to be working but on Ubuntu (22.04) it shows the default Java icon and has some kind of secondary ghost window that you can't focus.

# Installers

[Windows Installer](https://cdn.alchitry.com/labs-v2/Alchitry%20Labs-2.0.0-ALPHA-1.msi)

[Linux Installer](https://cdn.alchitry.com/labs-v2/alchitry-labs_2.0.0-ALPHA-1-1_amd64.deb)