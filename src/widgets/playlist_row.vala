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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/playlist_row.ui")]
    public class PlaylistRow : Gtk.Frame {
        [GtkChild]
        unowned CoverImage cover_image;
        [GtkChild]
        unowned Gtk.Label playlist_title;
        [GtkChild]
        unowned Gtk.Label track_num_label;
        [GtkChild]
        unowned Gtk.Button add_button;

        public YaMAPI.Playlist playlist_info { get; construct; }
        public YaMAPI.Track track_info { get; construct; }

        public PlaylistRow (YaMAPI.Playlist playlist_info, YaMAPI.Track track_info) {
            Object (playlist_info: playlist_info, track_info: track_info);
        }

        construct {
            playlist_title.label = playlist_info.title;
            if (playlist_info.track_count != 0) {
                set_track_count ();
            }

            add_button.clicked.connect (() => {
                add_button_clicked_async.begin ();
            });

            cover_image.init_content (playlist_info);
            cover_image.load_image.begin ();
        }

        async void add_button_clicked_async () {
            add_button.sensitive = false;

            YaMAPI.Playlist? new_playlist = null;

            threader.add (() => {
                new_playlist = yam_talker.add_track_to_playlist (
                    track_info,
                    playlist_info
                );

                Idle.add (add_button_clicked_async.callback);
            });

            yield;

            playlist_info.track_count = new_playlist.track_count;

            if (new_playlist == null) {
                unsuccess ();
            }

            if (new_playlist.revision != playlist_info.revision) {
                success ();
            } else {
                unsuccess ();
            }
        }

        void set_track_count () {
            track_num_label.label = _("Track count: %s").printf (playlist_info.track_count.to_string ());
        }

        public void success () {
            add_button.icon_name = "adwaita-emblem-ok-symbolic";

            set_track_count ();
        }

        public void unsuccess () {
            add_button.sensitive = true;
        }
    }
}
