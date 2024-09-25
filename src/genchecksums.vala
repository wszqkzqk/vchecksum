/* genchecksums.vala
 *
 * Copyright 2024 Zhou Qiankang <wszqkzqk@qq.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
*/

namespace VChecksum {
    public void gen_checksums (ChecksumType algorithm, string[] files, int threads) {
        try {
            var pool = new ThreadPool<ChecksumItem>.with_owned_data (
                (item) => {
                    item.run (algorithm);
                },
                threads,
                false
            );

            foreach (unowned string file in files) {
                pool.add (new ChecksumItem (file));
            }
        } catch (ThreadError e) {
            Reporter.error ("ThreadError", e.message);
        }
    }
}
