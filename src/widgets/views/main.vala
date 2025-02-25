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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/main_view.ui")]
    public class MainView : BaseView {
        [GtkChild]
        unowned Adw.StatusPage status_page;

        public override bool can_refresh { get; default = false; }

        public MainView () {
            Object ();
        }

        construct {
            if (Cassette.application.is_devel) {
                status_page.icon_name = "io.github.Rirusha.Cassette-symbolic";
            }
        }

        void set_values () {
            show_ready ();
        }

        public async override void first_show () {
            set_values ();
        }

        public async override bool try_load_from_cache () {
            return true;
        }

        public async override int try_load_from_web () {
            return -1;
        }

        public async override void refresh () {

        }
    }
}
