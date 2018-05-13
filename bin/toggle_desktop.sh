VAL=`gsettings get org.gnome.desktop.background show-desktop-icons`
if [ $VAL = "false" ]; then
    `gsettings set org.gnome.desktop.background show-desktop-icons true`
else
    `gsettings set org.gnome.desktop.background show-desktop-icons false`
fi
