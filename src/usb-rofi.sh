#!/bin/sh

APP="usb-rofi"
NOTIFY="notify-send"
ICON_PATH="/usr/share/usb-rofi/usb-icon.png"
USER=USERNAME

do_umount()
{
    daemon_init=$(ps -p 1 -o comm=)

    if [ "$daemon_init" = "systemd" ]; then
        systemd-umount "$1"
    else
        umount "$1"
    fi
}

do_mount()
{
    daemon_init=$(ps -p 1 -o comm=)

    if [ "$daemon_init" = "systemd" ]; then
        systemd-mount --no-block --automount=yes --collect "$1" "$2"
    else
        mount "$1" "$2"
    fi
}

umount_device()
{
    selected_row=$(df -h | rofi -dmenu -p "Select the device to umount")
    mount_point=$(echo "$selected_row" | awk '{print $6}')

    if [ -s "$mount_point" ]; then
        if do_umount "$mount_point" ; then
            rmdir "$mount_point"
            notify_cmd="$NOTIFY \"$APP\" \"Device umounted, now you can remove it safely\" -i \"$ICON_PATH\""
            su -c "$notify_cmd" "$USER"
        fi
    fi
}

mount_device()
{
    rofi_cmd="rofi -dmenu -p \"Device '$2 $1' detected. Select the action\""
    answer=$(printf "mount\nignore" | su -c "$rofi_cmd" "$USER")

    if [ "$answer" = "mount" ]; then
        mount_point="/mnt/$2"

        mkdir "$mount_point"
        if do_mount "$1" "$mount_point" ; then
            notify_cmd="$NOTIFY \"$APP\" \"Device $1 mounted at $mount_point\" -i \"$ICON_PATH\""
            su -c "$notify_cmd" "$USER"
        fi
    fi
}

export DISPLAY=:0

while getopts 'd:u' op ; do
    case $op in
        d) dev_part=$(echo "$OPTARG" | cut -f1 -d":")
           dev_desc=$(echo "$OPTARG" | cut -f2 -d":")

           mount_device "$dev_part" "$dev_desc" ;;

        u) umount_device ;;
        *) ;;
    esac
done