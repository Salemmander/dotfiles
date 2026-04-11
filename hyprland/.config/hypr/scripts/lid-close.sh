#!/bin/bash
# Disable the internal panel when the lid is closed and externals are connected.
# Safe to call from anywhere (lid switch, Hyprland startup) -- checks the actual
# lid state from /proc instead of trusting the trigger.
INTERNAL='eDP-1'
LID_STATE_FILE=$(echo /proc/acpi/button/lid/*/state)

if [ ! -r "$LID_STATE_FILE" ]; then
	exit 0
fi

if ! grep -q closed "$LID_STATE_FILE"; then
	exit 0
fi

NUM_MONITORS=$(hyprctl monitors | grep -c "^Monitor")
if [ "$NUM_MONITORS" -gt 1 ]; then
	hyprctl keyword monitor "$INTERNAL,disable"
else
	systemctl suspend
fi
