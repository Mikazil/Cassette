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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_info_panel.ui")]
public class Cassette.TrackInfoPanel : Adw.Bin {

    [GtkChild]
    unowned CoverImage cover_image;
    [GtkChild]
    unowned Gtk.Label position_label;
    [GtkChild]
    unowned PlayMarkTrack play_mark_track;
    [GtkChild]
    unowned Gtk.Box main_box;
    [GtkChild]
    unowned Gtk.Stack cover_stack;
    [GtkChild]
    unowned Gtk.Box title_box;
    [GtkChild]
    unowned Gtk.CenterBox title_and_marks_box;
    [GtkChild]
    unowned Gtk.Label track_name_label;
    [GtkChild]
    unowned Gtk.Label track_version_label;
    [GtkChild]
    unowned Gtk.Label track_authors_label;
    [GtkChild]
    unowned InfoMarks info_marks;

    YaMAPI.Track? _track_info = null;
    public YaMAPI.Track? track_info {
        get {
            return _track_info;
        }
        set {
            _track_info = value;

            if (_track_info == null) {
                track_name_label.label = "";
                track_version_label.label = "";
                track_authors_label.label = "";

                info_marks.is_exp = false;
                info_marks.is_child = false;
                info_marks.replaced_by = null;

                cover_image.clear ();

            } else {
                track_name_label.label = _track_info.title;
                track_version_label.label = _track_info.version;
                track_authors_label.label = _track_info.get_artists_names ();

                info_marks.is_exp = track_info.is_explicit;
                info_marks.is_child = track_info.is_suitable_for_children;
                info_marks.replaced_by = track_info.substituted;

                cover_image.init_content (track_info);
                cover_image.load_image.begin ();
                cover_image.visible = true;

                play_mark_track.init_content (_track_info.id);
            }
        }
    }

    public int position { get; set; }

    Gtk.Orientation _orientation = Gtk.Orientation.HORIZONTAL;
    public Gtk.Orientation orientation {
        get {
            return _orientation;
        }
        construct {
            _orientation = value;

            title_and_marks_box.start_widget = null;
            title_and_marks_box.center_widget = null;
            title_and_marks_box.end_widget = null;

            main_box.orientation = _orientation;

            switch (_orientation) {
                case Gtk.Orientation.HORIZONTAL:
                    track_name_label.add_css_class ("heading");
                    track_name_label.remove_css_class ("title-2");

                    track_name_label.halign = Gtk.Align.START;
                    track_version_label.halign = Gtk.Align.START;
                    track_authors_label.halign = Gtk.Align.START;

                    title_and_marks_box.halign = Gtk.Align.START;

                    title_and_marks_box.start_widget = title_box;
                    title_and_marks_box.center_widget = info_marks;
                    break;

                case Gtk.Orientation.VERTICAL:
                    track_name_label.remove_css_class ("heading");
                    track_name_label.add_css_class ("title-2");

                    track_name_label.halign = Gtk.Align.CENTER;
                    track_version_label.halign = Gtk.Align.CENTER;
                    track_authors_label.halign = Gtk.Align.CENTER;

                    title_and_marks_box.halign = Gtk.Align.CENTER;

                    title_and_marks_box.center_widget = title_box;
                    title_and_marks_box.end_widget = info_marks;
                    break;
            }
        }
    }

    public TrackInfoPanel (
        Gtk.Orientation orientation
    ) {
        Object (
            orientation: orientation
        );
    }

    construct {
        track_version_label.notify["label"].connect (() => {
            track_version_label.visible = track_version_label.label != "";
        });

        track_authors_label.notify["label"].connect (() => {
            track_authors_label.visible = track_authors_label.label != "";
        });

        notify["position"].connect (() => {
            position_label.label = position.to_string ();
        });

        cover_image.cover_size = orientation == Gtk.Orientation.HORIZONTAL? CoverSize.SMALL : CoverSize.BIG;
        cover_image.size = orientation == Gtk.Orientation.HORIZONTAL? 60 : 200;
    }

    public PlayMarkTrack get_play_mark_track () {
        return play_mark_track;
    }

    public void show_play_button () {
        cover_stack.visible_child_name = "play-mark";
    }

    public void show_cover () {
        cover_stack.visible_child_name = "cover";
    }

    public void show_position () {
        cover_stack.visible_child_name = "position";
    }
}
