#!/bin/bash
# usage: run_one.sh <fedora-release>
# Runs the extension in a headless GNOME Shell inside a Fedora container, then removes
# the container and (only if this run pulled it) the image.
# Set ZIP to test a specific build; default is the newest jiggle_*.zip in the repo root.
F=$1
M=$(dirname "$(readlink -f "$0")")
ZIP=${ZIP:-$(ls -t "$M"/../../jiggle_*.zip 2>/dev/null | head -1)}
[ -f "$ZIP" ] || { echo "no zip found; build one or set ZIP=path"; exit 1; }
IMG=fedora:$F; NAME=jiggle-matrix-$F; OUT=$M/out/f$F
rm -rf "$OUT"; mkdir -p "$OUT"
HAD=0; docker image inspect "$IMG" >/dev/null 2>&1 && HAD=1
docker run --rm --name "$NAME" -v "$M":/work:ro -v "$(readlink -f "$ZIP")":/zip/extension.zip:ro -v "$OUT":/out "$IMG" bash /work/inside.sh "$F" > "$OUT/install.log" 2>&1
RC=$?
docker rm -f "$NAME" >/dev/null 2>&1
[ $HAD = 0 ] && docker rmi "$IMG" >/dev/null 2>&1
echo "fedora $F: container rc=$RC; image $([ $HAD = 0 ] && echo removed || echo kept-it-existed-before)"
"$M/verdict.sh" "$OUT"
