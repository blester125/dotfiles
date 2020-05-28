#!/bin/bash

readonly LOG_FILE="/tmp/xsetwacom.log"
touch $LOG_FILE
exec 1>$LOG_FILE
exec 2>&1

echo `date`

export XAUTHORITY=/home/brian/.Xauthority
export DISPLAY=:0

xsetwacom set "Wacom Intuos S Pen stylus" MapToOutput Head-0
xsetwacom set "Wacom Intuos S Pad pad" Button 1 "key ctrl z"
xsetwacom set "Wacom Intuos S Pad pad" Button 2 "key ctrl y"
xsetwacom set "Wacom Intuos S Pad pad" Button 3 "key ctrl s"
