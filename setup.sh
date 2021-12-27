#!/bin/sh

if [ "$USER" != "root" ]; then
    echo "you must to be root to continue"
    exit 1
fi

script_path="/usr/bin/usb-rofi"
resources_path="/usr/share/usb-rofi"

mkdir -p "$resources_path"

cp src/usb-rofi.sh "$script_path"
cp src/resources/usb-icon.png "$resources_path"
cp src/rules/usb-rofi.rules /lib/udev/rules.d

udevadm control --reload-rules

sed -i "s|USERNAME|$1|g" "$script_path"
chmod +x "$script_path"