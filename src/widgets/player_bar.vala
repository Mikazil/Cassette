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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/player_bar.ui")]
    public class PlayerBar : Adw.Bin {
        [GtkChild]
        unowned Gtk.Label current_time_mark;
        [GtkChild]
        unowned Gtk.Label total_time_mark;
        [GtkChild]
        unowned Gtk.Scale slider;
        [GtkChild]
        unowned Gtk.Button flow_settings_button;
        [GtkChild]
        unowned Gtk.Button prev_track_button;
        [GtkChild]
        unowned Gtk.Button next_track_button;
        [GtkChild]
        unowned Gtk.Button track_detailed_button;
        [GtkChild]
        unowned DislikeButton dislike_button;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned Gtk.Button queue_show_button;
        [GtkChild]
        unowned SaveStack save_stack;
        [GtkChild]
        unowned Gtk.Button shuffle_button;
        [GtkChild]
        unowned Gtk.Button repeat_button;
        [GtkChild]
        unowned VolumeButton volume_button;
        [GtkChild]
        unowned Gtk.Button fullscreen_button;
        [GtkChild]
        unowned TrackOptionsButton track_options_button;

        public MainWindow window { get; construct set; }

        public YaMAPI.Track? current_track_info { get; private set; default = null; }

        public PlayerBar (MainWindow window) {
            Object (window: window);
        }

        construct {
            player.stopped.connect (() => {
                slider.set_value (0.0d);
            });

            player.ready_play_next.connect ((repeat) => {
                update_current_track_controls (player.mode.get_current_track_info ());
            });

            player.ready_play_prev.connect (() => {
                update_current_track_controls (player.mode.get_current_track_info ());
            });

            bind_property ("current-track-info", track_options_button, "track-info", BindingFlags.DEFAULT);

            Cassette.Client.settings.bind ("volume", volume_button, "volume", SettingsBindFlags.DEFAULT);
            Cassette.Client.settings.bind ("mute", volume_button, "mute", SettingsBindFlags.DEFAULT);

            slider.change_value.connect ((scroll_type, new_value) => {
                player.seek ((int) (new_value * 1000));
                on_playback_callback (new_value);
            });

            player.playback_callback.connect (on_playback_callback);

            player.bind_property ("can-go-prev", prev_track_button, "sensitive", BindingFlags.DEFAULT);
            player.bind_property ("can-go-next", next_track_button, "sensitive", BindingFlags.DEFAULT);

            player.current_track_start_loading.connect (() => {
                sensitive = false;
            });
            player.current_track_finish_loading.connect (() => {
                sensitive = true;
            });

            player.mode_inited.connect (on_player_mode_inited);

            var playerbar_actions = new SimpleActionGroup ();

            SimpleAction prev_action = new SimpleAction ("prev", null);
            prev_action.activate.connect (() => {
                player.prev ();
            });
            playerbar_actions.add_action (prev_action);

            SimpleAction next_action = new SimpleAction ("next", null);
            next_action.activate.connect (() => {
                player.next ();
            });
            playerbar_actions.add_action (next_action);

            insert_action_group ("playerbar", playerbar_actions);

            var track_actions = new SimpleActionGroup ();

            SimpleAction share_action = new SimpleAction ("share", null);
            share_action.activate.connect (() => {
                activate_action ("app.share-current-track", null);
            });
            track_actions.add_action (share_action);

            SimpleAction add_next_action = new SimpleAction ("add-next", null);
            add_next_action.activate.connect (() => {
                if (current_track_info != null) {
                    player.add_track (current_track_info, true);
                }
            });
            track_actions.add_action (add_next_action);

            SimpleAction add_end_action = new SimpleAction ("add-end", null);
            add_end_action.activate.connect (() => {
                if (current_track_info != null) {
                    player.add_track (current_track_info, false);
                }
            });
            track_actions.add_action (add_end_action);

            SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
            add_to_playlist_action.activate.connect (() => {
                if (current_track_info != null) {
                    add_track_to_playlist (current_track_info);
                }
            });
            track_actions.add_action (add_to_playlist_action);

            insert_action_group ("track", track_actions);

            track_detailed_button.clicked.connect (() => {
                if (track_detailed_button.has_css_class ("flat")) {
                    window.window_sidebar.show_track_info (current_track_info);
                } else {
                    window.window_sidebar.close ();
                }
            });

            queue_show_button.clicked.connect (() => {
                if (queue_show_button.has_css_class ("flat")) {
                    window.window_sidebar.show_queue ();
                } else {
                    window.window_sidebar.close ();
                }
            });

            player.notify["repeat-mode"].connect (on_repeat_mode_changed);
            on_repeat_mode_changed ();
            player.notify["shuffle-mode"].connect (on_shuffle_mode_changed);
            on_shuffle_mode_changed ();

            Idle.add_once (() => {
                window.window_sidebar.notify["track-detailed"].connect (() => {
                    if (window.window_sidebar.track_detailed != null && current_track_info != null) {
                        if (window.window_sidebar.track_detailed.track_info.id == current_track_info.id) {
                            track_detailed_button.remove_css_class ("flat");
                            return;
                        }
                    }

                    track_detailed_button.add_css_class ("flat");
                });

                window.window_sidebar.notify["is-shown"].connect (() => {
                    if (window.window_sidebar.is_shown == false) {
                        queue_show_button.add_css_class ("flat");
                        track_detailed_button.add_css_class ("flat");
                    }
                });

                window.window_sidebar.notify["track-list"].connect (() => {
                    if (window.window_sidebar.track_list == null) {
                        queue_show_button.add_css_class ("flat");
                    } else {
                        queue_show_button.remove_css_class ("flat");
                    }
                });
            });

            block_widget (fullscreen_button, BlockReason.NOT_IMPLEMENTED);
        }

        void on_playback_callback (double pos) {
            current_time_mark.label = sec2str ((int) pos, true);
            slider.set_value (pos);
        }

        void on_player_mode_inited () {
            current_track_info = player.mode.get_current_track_info ();

            update_current_track_controls (current_track_info);

            if (player.mode is Player.Flow) {
                to_flow ();

            } else if (player.mode is Player.TrackList) {
                to_track_list ();

            } else {
                clear ();
            }
        }

        void update_current_track_controls (YaMAPI.Track? new_track) {
            if (new_track == null) {
                clear ();
                return;
            }

            current_track_info = new_track;

            if (window.window_sidebar.track_detailed != null) {
                if (current_track_info.id == window.window_sidebar.track_detailed.track_info.id) {
                    track_detailed_button.remove_css_class ("flat");
                } else {
                    track_detailed_button.add_css_class ("flat");
                }
            }

            var adjustment = slider.get_adjustment ();
            adjustment.set_upper (ms2sec (current_track_info.duration_ms));

            if (current_track_info.is_ugc) {
                action_set_enabled ("track.share", false);
                dislike_button.visible = false;
            } else {
                action_set_enabled ("track.share", true);
                dislike_button.visible = true;
            }

            total_time_mark.label = ms2str (current_track_info.duration_ms, true);

            like_button.init_content (current_track_info.id);
            dislike_button.init_content (current_track_info.id);
            save_stack.init_content (current_track_info.id);

            window.show_player_bar ();
        }

        void to_flow () {
            repeat_button.visible = false;
            shuffle_button.visible = false;
            flow_settings_button.visible = true;
            queue_show_button.visible = false;
        }

        void to_track_list () {
            repeat_button.visible = true;
            shuffle_button.visible = true;
            flow_settings_button.visible = false;
            queue_show_button.visible = true;
        }

        void clear () {
            current_track_info = null;

            sensitive = false;

            dislike_button.visible = true;
            queue_show_button.visible = false;
            total_time_mark.label = "";

            window.hide_player_bar ();

            save_stack.clear ();
        }

        void on_shuffle_mode_changed () {
            switch (player.shuffle_mode) {
                case Player.ShuffleMode.ON:
                    shuffle_button.remove_css_class ("flat");
                    break;

                case Player.ShuffleMode.OFF:
                    shuffle_button.add_css_class ("flat");
                    break;
            }
        }

        void on_repeat_mode_changed () {
            switch (player.repeat_mode) {
                case Player.RepeatMode.REPEAT_ALL:
                    repeat_button.set_icon_name ("adwaita-media-playlist-repeat-symbolic");
                    repeat_button.remove_css_class ("flat");
                    break;

                case Player.RepeatMode.REPEAT_ONE:
                    repeat_button.set_icon_name ("adwaita-media-playlist-repeat-song-symbolic");
                    repeat_button.remove_css_class ("flat");
                    break;

                case Player.RepeatMode.OFF:
                    repeat_button.set_icon_name ("adwaita-media-playlist-repeat-symbolic");
                    repeat_button.add_css_class ("flat");
                    break;
            }
        }
    }
}
