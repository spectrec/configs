#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

ulimit -c unlimited

/usr/bin/setxkbmap -option 'caps:ctrl_modifier'
/usr/bin/xcape -e 'Caps_Lock=Control_L'

/usr/bin/setxkbmap -layout "us,ru(winkeys)" -option grp:alt_shift_toggle
/usr/bin/xscreensaver -no-splash &
/usr/bin/nm-applet &
/usr/bin/tilda &
/usr/bin/kbdd

exec /usr/bin/awesome
