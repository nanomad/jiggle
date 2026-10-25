#!/bin/bash
# usage: run_all.sh 39 40 41 42 43 44   (Fedora 39-44 ship GNOME 45-50)
M=$(dirname "$(readlink -f "$0")")
mkdir -p "$M/out"
for F in "$@"; do "$M/run_one.sh" "$F" | tee "$M/out/f$F.verdict"; done
