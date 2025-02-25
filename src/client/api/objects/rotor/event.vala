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


/**
 * TODO
 */
public class Cassette.Client.YaMAPI.Rotor.Event : YaMObject {

    public string timestamp { get; set; default = get_timestamp (); }

    /**
     * Feedback type.
     */
    public string type_ { get; set; }

    public string from { get; set; default = API_FROM; }

    public string? track_id { get; set; }

    public double total_played_seconds { get; set; }
}
