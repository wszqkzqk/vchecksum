/* Copyright 2024 Zhou Qiankang <wszqkzqk@qq.com>
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
    public const int BUFFER_SIZE = 1 << 17; // 128 KiB
}

[Compact (opaque = true)]
public class VChecksum.ChecksumItem {
    string path;

    public ChecksumItem (owned string path) {
        this.path = (owned) path;
    }

    public int run (ChecksumType algorithm) {
        var checksum = new Checksum (algorithm);
        uint8 buffer[VChecksum.BUFFER_SIZE];
        size_t bytes_read = 0;

        if (path == "-") {
            // Read from stdin
            // Add `stdin.eof () == false` to avoid to require twice EOF to finish
            while ((stdin.eof () == false) && (bytes_read = stdin.read (buffer)) > 0) {
                checksum.update (buffer, bytes_read);
            }

            stdout.printf ("%s  -\n", checksum.get_string ());
            return 0;
        }

        var file = File.new_for_commandline_arg (path);

        try {
            FileInputStream file_stream = file.read ();

            while ((bytes_read = file_stream.read (buffer)) > 0) {
                checksum.update (buffer, bytes_read);
            }
        } catch (IOError e) {
            Reporter.error ("IOError", e.message);
            return 1;
        } catch (Error e) {
            Reporter.error ("Error", e.message);
            return 1;
        }

        stdout.printf ("%s  %s\n", checksum.get_string (), path);

        return 0;
    }
}
