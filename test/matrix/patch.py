# Test harness: patches the INSTALLED copy of the extension (never the repo) to run a scripted test.
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("import GLib from 'gi://GLib';", "import Clutter from 'gi://Clutter';\nimport Gio from 'gi://Gio';\nimport GLib from 'gi://GLib';\nimport Shell from 'gi://Shell';", 1)
hook = """
            {
                const ctx = global.stage.context;
                const backend = (ctx && ctx.get_backend) ? ctx.get_backend() : Clutter.get_default_backend();
                const dev = backend.get_default_seat().create_virtual_device(Clutter.InputDeviceType.POINTER_DEVICE);
                const out = GLib.getenv('MATRIX_OUT');
                const shot = (name) => {
                    const stream = Gio.File.new_for_path(out + '/' + name + '.png').replace(null, false, Gio.FileCreateFlags.NONE, null);
                    new Shell.Screenshot().screenshot(true, stream, (o, res) => {
                        try { o.screenshot_finish(res); } catch (e) { log('MATRIX shot-error ' + name + ' ' + e); }
                        stream.close(null);
                    });
                };
                const shake = (ms) => {
                    let t = 0;
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 8, () => {
                        t += 8;
                        dev.notify_absolute_motion(GLib.get_monotonic_time(), 500 + 250 * Math.sin(2 * Math.PI * 5 * t / 1000), 300);
                        return t < ms ? GLib.SOURCE_CONTINUE : GLib.SOURCE_REMOVE;
                    });
                };
                this._settings.set_int('log-level', 4);
                let step = 0;
                const effects = [0, 1, 2, 3];
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
                    if (step >= effects.length) { log('MATRIX sequence-done'); GLib.timeout_add(GLib.PRIORITY_DEFAULT, 14000, () => { shot('prefs'); return GLib.SOURCE_REMOVE; }); return GLib.SOURCE_REMOVE; }
                    const e = effects[step++];
                    log('MATRIX effect=' + e + ' begin');
                    this._settings.set_int('effect', e);
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => { shake(2500); return GLib.SOURCE_REMOVE; });
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1700, () => { shot('effect' + e); return GLib.SOURCE_REMOVE; });
                    return GLib.SOURCE_CONTINUE;
                });
            }
"""
marker = "            this._renderId = GLib.timeout_add("
assert marker in s
s = s.replace(marker, hook + marker, 1)
open(p, 'w').write(s)
