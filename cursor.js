import Gio from 'gi://Gio';
import Meta from 'gi://Meta';

let inhibited = false;

function tracker()
{
    // Meta.CursorTracker.get_for_display() was removed in newer shells
    return global.backend?.get_cursor_tracker?.() ?? Meta.CursorTracker.get_for_display(global.display);
}

export function setPointerVisible(toggle)
{
    const t = tracker();
    if (!toggle && !inhibited) {
        t.inhibit_cursor_visibility();
        inhibited = true;
    } else if (toggle && inhibited) {
        t.uninhibit_cursor_visibility();
        inhibited = false;
    }
}

/**
 * Size in pixels of the system cursor (Gdk is not available in the shell process).
 */
export function systemCursorSize()
{
    const settings = new Gio.Settings({schema_id: 'org.gnome.desktop.interface'});
    return settings.get_int('cursor-size') || 24;
}

/**
 * Hotspot of the current system cursor, in cursor pixels.
 */
export function systemCursorHotspot()
{
    try {
        const [x, y] = tracker().get_hot();
        return [x, y];
    } catch (e) {
        return [0, 0];
    }
}

export function screenSize()
{
    return [global.stage.width, global.stage.height];
}
