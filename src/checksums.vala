/* checksums.vala
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

[Compact (opaque = true)]
public class VChecksum.Checksums {
    ChecksumType algorithm;
    int threads;
    ThreadPool<ChecksumItem>? pool = null;
    public int exit_status {get; private set; default = 0;}

    public Checksums (ChecksumType algorithm, int threads) {
        this.algorithm = algorithm;
        this.threads = threads;

        // Note: ownership of the lambda func is in this context
        // instead of the ThreadPool context, so we MUST use `this.algorithm` and `this.threads` here
        // any variables in this context will be freed so we cannot use them in the lambda func
        try {
            this.pool = new ThreadPool<ChecksumItem>.with_owned_data (
                (item) => {
                    if (unlikely (item.run (this.algorithm) != 0)) {
                        this.exit_status = 1;
                    }
                },
                this.threads,
                false
            );
        } catch (ThreadError e) {
            Reporter.warning ("ThreadWarning", "%s, fallback to single thread", e.message);
        }
    }

    public void checksum (string path) {
        if (unlikely (this.pool == null)) {
            var item = new ChecksumItem (path);
            if (unlikely (item.run (this.algorithm) != 0)) {
                this.exit_status = 1;
            }
            return;
        }

        try {
            pool.add (new ChecksumItem (path));
        } catch (ThreadError e) {
            Reporter.warning ("ThreadWarning", "%s, fallback to single thread", e.message);
            var item = new ChecksumItem (path);
            if (unlikely (item.run (this.algorithm) != 0)) {
                this.exit_status = 1;
            }
        }
    }
}
