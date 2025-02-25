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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_default_content.ui")]
    public class TrackDefault : YATrackRowContent {

        [GtkChild]
        unowned TrackInfoPanel info_panel;
        [GtkChild]
        unowned SaveStack save_stack;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned DislikeButton dislike_button;
        [GtkChild]
        unowned Gtk.Label duration_label;
        [GtkChild]
        unowned TrackOptionsButton track_options_button;

        public bool show_dislike_button { get; construct; default = false; }

        protected override PlayMarkTrack play_mark_track {
            owned get {
                return info_panel.get_play_mark_track ();
            }
        }

        public TrackDefault (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
        }

        // ! Не стоит использовать конструктор with_dislike_button со списком, в котором есть пользовательские треки
        public TrackDefault.with_dislike_button (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object, show_dislike_button: true);
        }

        construct {
            if (show_dislike_button) {
                assert (!track_info.is_ugc);
                dislike_button.visible = true;
            }

            play_mark_track.triggered_not_playing.connect (form_queue);

            play_mark_track.notify["is-current-playing"].connect (() => {
                is_current_playing = play_mark_track.is_current_playing;

                if (play_mark_track.is_current_playing) {
                    info_panel.show_play_button ();

                } else {
                    info_panel.show_cover ();
                }
            });

            track_options_button.track_info = track_info;
            //  setup_options_button ();
            set_values ();
        }

        void set_values () {
            var motion_controller = new Gtk.EventControllerMotion ();
            add_controller (motion_controller);

            info_panel.track_info = track_info;

            if (track_info.available) {
                duration_label.label = ms2str (track_info.duration_ms, true);
                motion_controller.enter.connect ((mc, x, y) => {
                    info_panel.show_play_button ();
                });
                motion_controller.leave.connect ((mc) => {
                    if (!play_mark_track.is_current_playing) {
                        info_panel.show_cover ();
                    }
                });

            } else {
                add_css_class ("not-available");

                info_panel.sensitive = false;
                duration_label.label = "";
                track_options_button.sensitive = false;

                this.tooltip_text = _("Track is not available");
            }

            like_button.init_content (track_info.id);
            dislike_button.init_content (track_info.id);
            play_mark_track.init_content (track_info.id);

            save_stack.init_content (track_info.id);
        }

        void form_queue () {
            var track_list = yam_object.get_filtered_track_list (
                Cassette.settings.get_boolean ("explicit-visible"),
                Cassette.settings.get_boolean ("child-visible"),
                track_info.id
            );

            player.start_track_list (
                track_list,
                get_context_type (yam_object),
                yam_object.oid,
                track_list.index_of (track_info),
                get_context_description (yam_object)
            );
        }

        void setup_options_button () {
            var actions = new SimpleActionGroup ();

            var playlist_info = yam_object as YaMAPI.Playlist;
            if (playlist_info != null) {
                if (playlist_info.kind != "3") {
                    //  track_options_button.add_remove_from_playlist_action ();

                    SimpleAction remove_from_playlist_action = new SimpleAction ("remove-from-playlist", null);
                    remove_from_playlist_action.activate.connect (() => {
                        remove_from_playlist_async.begin ();
                    });
                    actions.add_action (remove_from_playlist_action);
                }
            }

            if (track_info.is_ugc == false) {
                SimpleAction share_action = new SimpleAction ("share", null);
                share_action.activate.connect (() => {
                    track_share (track_info);
                });
                actions.add_action (share_action);
            }

            SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
            add_to_playlist_action.activate.connect (() => {
                add_track_to_playlist (track_info);
            });
            actions.add_action (add_to_playlist_action);

            SimpleAction add_next_action = new SimpleAction ("add-next", null);
            add_next_action.activate.connect (() => {
                player.add_track (track_info, true);
            });
            actions.add_action (add_next_action);

            SimpleAction add_end_action = new SimpleAction ("add-end", null);
            add_end_action.activate.connect (() => {
                player.add_track (track_info, false);
            });
            actions.add_action (add_end_action);

            //  track_options_button.add_save_action ();
            SimpleAction save_action = new SimpleAction ("save", null);
            save_action.activate.connect (() => {
                Cachier.save_track.begin (track_info);
            });
            actions.add_action (save_action);

            insert_action_group ("track", actions);
        }
    }
}
