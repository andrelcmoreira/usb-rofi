
.PHONY: install udev usb-rofi

usb-rofi: src/usb-rofi.in
	sed -e "s/@@USERNAME@@/${LOGNAME}/g" $< >$@
	chmod +x $@

udev: src/udev/usb-rofi.rules
	install -Dm 644 src/udev/usb-rofi.rules -t /lib/udev/rules.d
	udevadm control --reload-rules

install: udev
	install -Dm 755 usb-rofi -t /usr/bin
	install -Dm 666 resources/usb-icon.png /usr/share/usb-rofi/usb-icon.png
