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

namespace Cassette {
    public abstract class BaseView : Adw.Bin {

        public abstract bool can_refresh { get; default = true; }

        public signal void show_ready ();

        public async abstract int try_load_from_web ();

        public async abstract bool try_load_from_cache ();

        public PageRoot root_view { get; set; }

        public async virtual void first_show () {
            bool cache_is_success = yield try_load_from_cache ();
            int soup_code = yield try_load_from_web ();
            if (!cache_is_success) {
                if (soup_code != -1) {
                    root_view.show_error (this, soup_code);
                }
            }
        }

        public async virtual void refresh () {
            int soup_code = yield try_load_from_web ();
            if (soup_code != -1) {
                bool cache_is_success = yield try_load_from_cache ();
                if (!cache_is_success) {
                    root_view.show_error (this, soup_code);
                }
            }
        }
    }
}
