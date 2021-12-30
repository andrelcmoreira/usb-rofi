#!/bin/sh

APP="usb-rofi"
ICON="/usr/share/usb-rofi/usb-icon.png"
USER=USERNAME

export DISPLAY=:0

do_umount() {
  local daemon_init=$(ps -p 1 -o comm=)

  if [ "$daemon_init" = "systemd" ]; then
    systemd-umount "$1"
  else
    umount "$1"
  fi
}

do_mount() {
  local daemon_init=$(ps -p 1 -o comm=)

  if [ "$daemon_init" = "systemd" ]; then
    systemd-mount --no-block --automount=yes --collect "$1" "$2"
  else
    mount "$1" "$2"
  fi
}

umount_device() {
  local selected_row=$(df -h | rofi -dmenu -p "Select the device to umount")
  local mount_point=$(awk '{print $6}' <<< "$selected_row")

  if [ -s "$mount_point" ]; then
    if do_umount "$mount_point" ; then
      rmdir "$mount_point"
      notify_cmd="notify-send \"$APP\" \"Device umounted, now you can remove it safely\" -i \"$ICON\""
      su -c "$notify_cmd" "$USER"
    fi
  fi
}

mount_device() {
  local rofi_cmd="rofi -dmenu -p \"Device '$2 $1' detected. Select the action\""
  local answer=$(printf "mount\nignore" | su -c "$rofi_cmd" "$USER")

  if [ "$answer" = "mount" ]; then
    mount_point="/mnt/$2"

    mkdir "$mount_point"
    if do_mount "$1" "$mount_point" ; then
      notify_cmd="notify-send \"$APP\" \"Device $1 mounted at $mount_point\" -i \"$ICON\""
      su -c "$notify_cmd" "$USER"
    fi
  fi
}

main() {
  while getopts 'd:u' op ; do
    case $op in
      d) local dev_part=$(cut -f1 -d":" <<< "$OPTARG")
         local dev_desc=$(cut -f2 -d":" <<< "$OPTARG")

         mount_device "$dev_part" "$dev_desc" ;;

      u) umount_device ;;
      *) ;;
    esac
  done
}

main "$@"
