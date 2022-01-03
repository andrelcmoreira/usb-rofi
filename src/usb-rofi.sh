#!/bin/sh

export DISPLAY=:0

do_umount() {
  selected_row=$(df -h | rofi -dmenu -p "Select the device to umount")
  mount_point=$(echo "$selected_row" | awk '{print $6}')

  if [ -s "$mount_point" ]; then
    if eval "$UMOUNT $mount_point" ; then
      rmdir "$mount_point"
      notify_cmd="notify-send $APP Device umounted, now you can remove it safely -i $ICON"
      su -c "$notify_cmd" "$USER"
    fi
  fi
}

do_mount() {
  rofi_cmd="rofi -dmenu -p \"Device '$2 $1' detected. Select the action\""
  answer=$(printf "mount\nignore" | su -c "$rofi_cmd" "$USER")

  if [ "$answer" = "mount" ]; then
    mount_point="/mnt/$2"

    mkdir "$mount_point"
    if eval "$MOUNT $1 $mount_point" ; then
      notify_cmd="notify-send $APP Device $1 mounted at $mount_point -i $ICON"
      su -c "$notify_cmd" "$USER"
    fi
  fi
}

do_clean() {
  mount_point="$1"

  if [ -s "$mount_point" ]; then
    if eval "$UMOUNT $mount_point" ; then
      rmdir "$mount_point"
    fi
  fi
}

set_variables() {
  pid_1=$(cat /proc/1/comm)

  case $pid_1 in
    # TODO: put a comment here explaining the difference between systemd-mount and mount
    systemd)
      MOUNT="systemd-mount --no-block --automount=yes --collect"
      UMOUNT="systemd-umount" ;;
    *)
      MOUNT="mount"
      UMOUNT="umount" ;;
  esac

  APP="usb-rofi"
  ICON="/usr/share/$APP/usb-icon.png"
  USER=USERNAME
}

main() {
  set_variables

  while getopts 'd:c:u' op ; do
    case $op in
      d)
        dev_part=$(echo "$OPTARG" | cut -f1 -d":")
        dev_desc=$(echo "$OPTARG" | cut -f2 -d":")

        do_mount "$dev_part" "$dev_desc" ;;
      c) do_clean "$OPTARG" ;;
      u) do_umount ;;
      *) ;;
    esac
  done
}

main "$@"
