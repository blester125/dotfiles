#!/bin/bash

VAL=`gsettings get org.gnome.desktop.background show-desktop-icons`
if [ $VAL = "false" ]; then
    # i3
    export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pidof i3)/environ | cut -d= -f2-)
else
    # gnome
    eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
fi

/usr/bin/notify-send -i face-tired Sit "Move your desk to a sitting position."
