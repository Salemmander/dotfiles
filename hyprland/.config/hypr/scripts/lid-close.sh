#!/bin/bash
INTERNAL='eDP-1'
NUM_MONITORS=$(hyprctl monitors | grep -c "^Monitor")
if [ $NUM_MONITORS -gt 1 ]; then
  hyprctl keyword monitor "$INTERNAL,disable"
else
  systemctl suspend
fi
