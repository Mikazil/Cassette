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


public abstract class Cassette.TrackRow : Reactable {

    public Client.YaMAPI.Track track_info { get; construct; }

    protected abstract PlayMarkTrack play_mark_track { owned get; }

    protected override string css_class_name_hover {
        owned get {
            return "track-row-hover";
        }
    }

    protected override string css_class_name_active {
        owned get {
            return "track-row-active";
        }
    }

    protected override string css_class_name_playing_default {
        owned get {
            return "track-row-playing";
        }
    }

    protected override string css_class_name_playing_hover {
        owned get {
            return "track-row-playing-hover";
        }
    }

    protected override string css_class_name_playing_active {
        owned get {
            return "track-row-playing-active";
        }
    }

    public void trigger () {
        play_mark_track.trigger ();
    }
}
