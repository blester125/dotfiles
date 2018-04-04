#!/bin/bash

VAL=`gsettings get org.gnome.desktop.background show-desktop-icons`
if [ $VAL = "false" ]; then
    # i3
    export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pidof i3)/environ | cut -d= -f2-)
else
    # gnome
    eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
fi

notify-send -i face-crying Stand "Move your desk to the standing position."
