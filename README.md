usb-rofi
========

[![usb-rofi check](https://github.com/carvalhudo/usb-rofi/workflows/usb-rofi%20check/badge.svg)](https://github.com/carvalhudo/usb-rofi/actions)

### Overview

**usb-rofi** is a simple tool for help the management of USB flash drives using the rofi app
launcher and udev. It's composed by the udev rule `usb_rofi.rules` and the script `usb_mgr`.
The rule is responsible for trigger the script when a new device is attached to the system,
who in turn will prompt the user for the action to be performed. The main usage for this tool is
for tiling window managers such as i3, dmw, bspwm, etc.

### Dependencies

- rofi
- notify-send

### Installation

```bash
$ git clone https://github.com/carvalhudo/usb-rofi.git && cd usb-rofi
$ sudo /bin/sh install
```

### Usage

After the installation, the `usb-rofi` is ready to detect and notify the user when a new flash
drive is attached to the system. In order to improve the usability, it’s recommended bind a hotkey
to unmount devices easily. In my case (i3), would be something like this:

```bash
bindsym $mod+u exec "qsudo ~/.local/usb-rofi/usb_mgr -u"
```

### Demo

![video](video.gif)
