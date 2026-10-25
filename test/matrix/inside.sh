#!/bin/bash
# Runs inside the container as root: installs deps, then runs the test as user "tester".
set -u
VER=$1
dnf install -y --setopt=install_weak_deps=False gnome-shell mutter dbus-daemon dbus-tools mesa-dri-drivers mesa-libEGL python3 glib2-devel unzip procps-ng xorg-x11-server-Xwayland adwaita-icon-theme gnome-extensions-app python3-dbusmock >/tmp/dnf.log 2>&1 || dnf install -y --setopt=install_weak_deps=False gnome-shell mutter dbus-daemon dbus-tools mesa-dri-drivers python3 glib2-devel unzip procps-ng xorg-x11-server-Xwayland python3-dbusmock >>/tmp/dnf.log 2>&1 || { echo "MATRIX dnf-failed"; tail -5 /tmp/dnf.log; exit 1; }
echo "MATRIX gnome-shell $(gnome-shell --version)"
mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
id tester >/dev/null 2>&1 || useradd -m -u 1000 tester
mkdir -p /run/user/1000 && chown tester /run/user/1000 && chmod 700 /run/user/1000
chown -R tester /out
mkdir -p /run/dbus; dbus-uuidgen --ensure; dbus-daemon --system --fork; sleep 1
python3 -m dbusmock --system --template logind > /tmp/logind.log 2>&1 &
sleep 3
su tester -c "bash /work/as_tester.sh" 
