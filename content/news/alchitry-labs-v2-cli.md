+++
title = "Alchitry Labs V2 - Command Line Interface"
date = "2023-09-11"
+++

It has been a while since I last wrote about the progress on Alchitry Labs V2 and a lot has changed.

## Build Tools

I've spent a good amount of time working on building out the Gradle build script so that the deployment process will be much easier than it was for Alchitry Labs V1.

When I was looking for a way to create the Window's installer, I discovered that [Compose Multiplatform](https://github.com/JetBrains/compose-multiplatform/tree/master) has a built in [packaging tool](https://github.com/JetBrains/compose-multiplatform/blob/master/tutorials/Native_distributions_and_local_execution/README.md)!

It turns out that this still has the major downside of needing to be running on the OS that you want to package for. This means you can't build an installer for Windows from Linux. Bummer, but not the end of the world.

I ran into two other issues when flushing out the build script. First, Compose's build tools only support creating one launcher per application. I need to create two. The main one to launch Alchitry Labs and the second to launch the Alchitry Loader.

These two programs are actually the same thing with just a different argument passed to them to show a different GUI.

It turns out that jpackage, the tool used by Compose, has a way to add additional launchers but Compose currently gives no way to access it. I add the support I needed, I forked the Compose plugin and submitted a [pull request](https://github.com/JetBrains/compose-multiplatform/pull/3640).

For now, I'm using my local forked version of the Compose plugin, but hopefully they'll accept the pull request or make some similar changes to allow creating additional launchers.

## Command Line Interface

Something I often get emails about is for command line support in Alchitry Labs. Well, I'm happy to announce that the command line interface for Alchitry Labs V2 will be well supported.

I've decided to get everything working via the command line before diving too much into the GUI.

Right now, the loading tools already work. So if you've been looking for a way to load your Alchitry boards from the command line, check out the very early releases below.

The command line is broken into a bunch of subcommands.

```
$ alchitry --help
Usage: alchitry_labs options_list
Subcommands: 
    new - Create a new project
    clone - Clone an existing project
    check - Check a project for errors
    build - Build an Alchitry Project
    load - Load a project or .bin file
    sim - Simulate a project
    labs - Launch Alchitry Labs GUI
    loader - Launch Alchitry Loader GUI

Options: 
    --help, -h -> Usage info 
```

If you install the .deb on Linux, you'll get access to the `alchitry` command.

On Windows, the `Alchitry.exe` executable in the installation directory can be used.

You can run `--help` on each subcommand for more info.

```
$ alchitry load --help
Usage: alchitry_labs load options_list
Options: 
    --project, -p -> Alchitry project file { String }
    --flash, -f [false] -> Load project to FPGA's flash (persistent) 
    --ram, -r [false] -> Load project to FPGA's RAM (temporary) 
    --list, -l [false] -> List all detected boards 
    --device, -d [0] -> Index of device to load { Int }
    --bin -> Bin file to load { String }
    --board, -b -> Board used in the project { Value should be one of [Au, Au+, Cu] }
    --help, -h -> Usage info 
```

For example, you can load a .bin file like this.

```
$ alchitry load --bin alchitry.bin -b Au+ --flash
Checking IDCODE...
Loading bridge configuration...
Erasing...
Flashing 100% │███████████████████████████████████│ 335339/335339 (0:00:01 / 0:00:00) 
Resetting FPGA...
Done.
```

If you try this out, let me know what you think over at the [discussions page](https://github.com/alchitry/Alchitry-Labs-V2/discussions).
## Releases

These aren't really a "release" as much as just something you can try and mess around with.

That being said, the loading features should be fully working.

[Linux Deb](https://cdn.alchitry.com/labs-v2/alchitry-labs_2.0.0-ALPHA-0-1_amd64.deb)

[Windows Installer](https://cdn.alchitry.com/labs-v2/Alchitry-2.0.0-ALPHA-0.msi)

The Labs GUI will open but it doesn't really do much. It is basically just a test right now for the custom text editor.

The Loader GUI doesn't open/exist at all yet.

The command line tools work for creating and simulating projects as well as loading .bin files.