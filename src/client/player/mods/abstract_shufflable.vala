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


using Gee;

/**
 *
 */
public abstract class Cassette.Client.Player.Shufflable : Mode {
    ArrayList<YaMAPI.Track> original_queue { get; set; default = new ArrayList<YaMAPI.Track> (); }

    construct {
        original_queue.add_all (queue);

        if (player.shuffle_mode == ShuffleMode.ON) {
            shuffle ();
        }
    }

    public void shuffle () {
        var type_utils = new TypeUtils<YaMAPI.Track> ();

        var current_track = get_current_track_info ();

        ArrayList<YaMAPI.Track> shuffled_queue = new ArrayList<YaMAPI.Track> ();

        shuffled_queue.add_all (queue);
        queue.clear ();

        type_utils.shuffle (ref shuffled_queue);

        var new_index = shuffled_queue.index_of (current_track);

        queue.add_all (shuffled_queue[new_index:shuffled_queue.size]);
        queue.add_all (shuffled_queue[0:new_index]);

        current_index = 0;
    }

    public void unshuffle () {
        var current_track = get_current_track_info ();

        queue.clear ();
        queue.add_all (original_queue);
        current_index = queue.index_of (current_track);
    }

    public void add_track_next (YaMAPI.Track track_info) {
        if (queue.size == 0) {
            add_track_end (track_info);
            return;
        }

        queue.insert (current_index + 1, track_info);
        original_queue.insert (original_queue.index_of (get_current_track_info ()) + 1, track_info);
    }

    public void remove_track_by_pos (int position) {
        var track_info = queue[position];
        remove_track (track_info);
    }

    public void remove_track (YaMAPI.Track track_info) {
        int track_pos = queue.index_of (track_info);

        if (track_pos == -1) {
            return;
        }

        queue.remove_at (track_pos);
        original_queue.remove (track_info);

        if (queue.size != 0) {
            if (track_pos == current_index) {
                player.change_track (get_current_track_info ());

            } else if (track_pos < current_index) {
                current_index--;
            }
        } else {
            player.stop (true);
        }
    }

    public void remove_all_tracks () {
        queue.clear ();
        original_queue.clear ();
        current_index = -1;

        context_type = "various";
    }

    public void add_track_end (YaMAPI.Track track_info) {
        bool should_change_track_state = queue.size == 0;

        queue.add (track_info);
        original_queue.add (track_info);

        if (should_change_track_state) {
            player.start_current_track.begin (() => {
                player.stop (true);
            });
        }
    }

    public void add_many_end (ArrayList<YaMAPI.Track> track_list) {
        bool should_change_track_state = queue.size == 0;

        queue.add_all (track_list);
        original_queue.add_all (track_list);

        if (should_change_track_state) {
            player.start_current_track.begin (() => {
                player.stop (true);
            });
        }
    }
}
