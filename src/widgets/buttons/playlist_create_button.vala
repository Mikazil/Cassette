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


using Cassette.Client;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/playlist_create_button.ui")]
    public class PlaylistCreateButton : Adw.Bin {
        [GtkChild]
        unowned Gtk.Button real_button;

        public PlaylistCreateButton () {
            Object ();
        }

        construct {
            real_button.clicked.connect (create_playlist_button_clicked_async);
            application.application_state_changed.connect (application_state_changed);
            application_state_changed (application.application_state);
        }

        async void create_playlist_button_clicked_async () {
            sensitive = false;

            threader.add (() => {
                yam_talker.create_playlist ();

                Idle.add (create_playlist_button_clicked_async.callback);
            });

            yield;
        }

        void application_state_changed (ApplicationState new_state) {
            switch (new_state) {
                case ApplicationState.ONLINE:
                    real_button.sensitive = true;
                    break;
                case ApplicationState.OFFLINE:
                    real_button.sensitive = false;
                    break;
                default:
                    break;
            }
        }
    }
}
