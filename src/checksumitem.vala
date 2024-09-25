/* checksumitem.vala
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
    public const int BUFFER_SIZE = 1 << 17; // 128 KiB
}

[Compact (opaque = true)]
public class VChecksum.ChecksumItem {
    string path;

    public ChecksumItem (string path) {
        this.path = path;
    }

    public bool run (ChecksumType algorithm) {
        var file = File.new_for_commandline_arg (path);

        FileInputStream file_stream;
        try {
            file_stream = file.read ();
        } catch (IOError e) {
            Reporter.error ("IOError", e.message);
            return false;
        } catch (Error e) {
            Reporter.error ("Error", e.message);
            return false;
        }

        var checksum = new Checksum (algorithm);
        uint8 buffer[VChecksum.BUFFER_SIZE];
        size_t bytes_read;
        try {
            while ((bytes_read = file_stream.read (buffer)) > 0) {
                checksum.update (buffer, bytes_read);
            }
        } catch (IOError e) {
            Reporter.error ("IOError", e.message);
            return false;
        }

        stdout.printf ("%s  %s\n", checksum.get_string (), path);

        return true;
    }
}
