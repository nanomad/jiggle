import Gio from 'gi://Gio';
import Meta from 'gi://Meta';

export function setPointerVisible(toggle)
{
    const tracker = Meta.CursorTracker.get_for_display(global.display);
    try {
        const seat = global.stage.context.get_backend().get_default_seat();
        if (!seat.is_unfocus_inhibited()) {
            seat.inhibit_unfocus();
        }
    } catch (e) {
        // not fatal, the pointer can still be toggled
    }
    tracker.set_pointer_visible(!!toggle);
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
        const [x, y] = Meta.CursorTracker.get_for_display(global.display).get_hot();
        return [x, y];
    } catch (e) {
        return [0, 0];
    }
}

export function screenSize()
{
    return [global.stage.width, global.stage.height];
}
