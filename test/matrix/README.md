# Version matrix test

Runs the packaged extension in a headless GNOME Shell inside Fedora containers and checks,
per version, that it loads without JS errors, that each of the four effects starts under a
scripted shake, and that the prefs window opens. Screenshots land in `out/`.

| Fedora | GNOME Shell |
|--------|-------------|
| 39 | 45 |
| 40 | 46 |
| 41 | 47 |
| 42 | 48 |
| 43 | 49 |
| 44 | 50 |

```
make build            # or any other way to produce jiggle_*.zip in the repo root
test/matrix/run_all.sh 39 40 41 42 43 44
ZIP=path/to/build.zip test/matrix/run_one.sh 44
```

Requires Docker. Each run installs gnome-shell in a fresh container (a few minutes, a few GB of
downloads), then removes its container and, if the run pulled it, the image. Nothing else is pruned.

How it works: `patch.py` modifies the *installed copy* inside the container (never the repo) to
drive a virtual pointer and take screenshots; `inside.sh` starts a mocked logind on a system bus,
and `as_tester.sh` runs the shell headless with software rendering.

Limits: headless, software rendering, mocked login service. It proves the code runs and draws
on each version; it does not judge how the effects look, and it does not exercise each prefs control.
