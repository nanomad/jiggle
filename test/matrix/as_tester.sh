#!/bin/bash
export WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 MATRIX_OUT=/out LIBGL_ALWAYS_SOFTWARE=1 HOME=/home/tester
cd $HOME
exec dbus-run-session -- bash -c '
  U=jiggle-fork@nanomad
  gsettings set org.gnome.shell disable-user-extensions false
  gnome-extensions install --force /zip/extension.zip
  python3 /work/patch.py $HOME/.local/share/gnome-shell/extensions/$U/extension.js
  gnome-shell --headless --wayland --virtual-monitor 1280x720 > /out/shell.log 2>&1 &
  SH=$!
  sleep 8
  gnome-extensions enable $U
  sleep 20
  timeout 25 gnome-extensions prefs $U > /out/prefs.log 2>&1 &
  sleep 18
  echo "MATRIX info: $(gnome-extensions info $U | grep -E "State|Enabled" | tr "\n" " ")" >> /out/shell.log
  kill $SH 2>/dev/null
  sleep 2
'
