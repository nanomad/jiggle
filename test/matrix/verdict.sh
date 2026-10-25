#!/bin/bash
# usage: verdict.sh <outdir>
D=$1; L=$D/shell.log
IGN='Could not get a proxy for user|DBus.Python.TypeError|dbus.UInt32'
echo "shell:        $(grep -m1 'MATRIX gnome-shell' $D/install.log 2>/dev/null)"
echo "jiggle errs:  $(grep -E 'JS ERROR|Could not load|ImportError|TypeError|ReferenceError|shot-error' $L | grep -v -E "$IGN" | grep -c .)"
for e in 0 1 2 3; do echo "effect$e:      starts=$(awk "/effect=$e begin/{f=1} /effect=$((e+1)) begin|sequence-done/{f=0} f&&/Starting jiggle/" $L | wc -l) shot=$([ -s $D/effect$e.png ] && echo yes || echo NO)"; done
echo "stops total:  $(grep -c 'Stopping jiggle' $L)"
echo "prefs:        shot=$([ -s $D/prefs.png ] && echo yes || echo NO) errs=$(grep -c -E 'JS ERROR|TypeError|ReferenceError' $D/prefs.log 2>/dev/null)"
