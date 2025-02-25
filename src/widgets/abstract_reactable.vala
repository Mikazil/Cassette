/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


// Why this exist?
// Look: https://t.me/CassetteGNOME_Discussion/10666
public abstract class Cassette.Reactable : Gtk.Frame {

    protected virtual string css_class_name_hover {
        owned get {
            assert_not_reached ();
        }
    }

    protected virtual string css_class_name_active {
        owned get {
            assert_not_reached ();
        }
    }

    protected virtual string css_class_name_playing_default {
        owned get {
            assert_not_reached ();
        }
    }

    protected virtual string css_class_name_playing_hover {
        owned get {
            assert_not_reached ();
        }
    }

    protected virtual string css_class_name_playing_active {
        owned get {
            assert_not_reached ();
        }
    }

    bool _is_current_playing = false;
    public bool is_current_playing {
        get {
            return _is_current_playing;
        }
        set {
            _is_current_playing = value;

            if (value) {
                add_css_class (css_class_name_playing_default);

            } else {
                remove_css_class (css_class_name_playing_default);
                remove_css_class (css_class_name_playing_hover);
                remove_css_class (css_class_name_playing_active);
            }
        }
    }

    construct {
        var gs_hover = new Gtk.EventControllerMotion ();
        gs_hover.enter.connect (() => {
            add_css_class (css_class_name_hover);
        });
        gs_hover.leave.connect (() => {
            remove_css_class (css_class_name_hover);
        });
        add_controller (gs_hover);

        var gs_active = new Gtk.GestureClick ();
        gs_active.pressed.connect (() => {
            add_css_class (css_class_name_active);
        });
        gs_active.stopped.connect (() => {
            remove_css_class (css_class_name_active);
        });
        add_controller (gs_active);

        var gs_playing_hover = new Gtk.EventControllerMotion ();
        gs_playing_hover.enter.connect (() => {
            if (is_current_playing) {
                add_css_class (css_class_name_playing_hover);
            }
        });
        gs_playing_hover.leave.connect (() => {
            if (is_current_playing) {
                remove_css_class (css_class_name_playing_hover);
            }
        });
        add_controller (gs_playing_hover);

        var gs_playing_active = new Gtk.GestureClick ();
        gs_playing_active.pressed.connect (() => {
            if (is_current_playing) {
                add_css_class (css_class_name_playing_active);
            }
        });
        gs_playing_active.stopped.connect (() => {
            if (is_current_playing) {
                remove_css_class (css_class_name_playing_active);
            }
        });
        add_controller (gs_playing_active);
    }
}
