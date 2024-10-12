/* main.vala
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
class VChecksum.CLI {
    static bool show_help = false;
    static bool show_version = false;
    static string? algorithm = null;
    static int threads = 0;

    const OptionEntry[] options = {
        { "help", 'h', OptionFlags.NONE, OptionArg.NONE, ref show_help, "Show help message", null },
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref show_version, "Display version number", null },
        { "algorithm", 'a', OptionFlags.NONE, OptionArg.STRING, ref algorithm, "The hash algorithm (Auto-detect if unspecified)", "'md5' 'sha1' 'sha256' 'sha384' or 'sha512'" },
        { "threads", 't', OptionFlags.NONE, OptionArg.INT, ref threads, "The number of threads to use", "NUM" },
        { null }
    };

    static int main (string[] original_args) {
        // Compatibility for Windows and Unix
        if (Intl.setlocale (LocaleCategory.ALL, ".UTF-8") == null) {
            Intl.setlocale ();
        }

#if WINDOWS
        var args = Win32.get_command_line ();
#else
        var args = strdupv (original_args);
#endif
        var opt_context = new OptionContext ("[Files...] - Calculate checksum of files");
        // DO NOT use the default help option provided by g_print
        // g_print will force to convert character set to windows's code page
        // which is imcompatible windows's bash, zsh, etc.
        opt_context.set_help_enabled (false);

        opt_context.add_main_entries (options, null);
        try {
            opt_context.parse_strv (ref args);
        } catch (OptionError e) {
            Reporter.error ("OptionError", e.message);
            stderr.printf ("\n%s", opt_context.get_help (true, null));
            return 1;
        }

        if (show_help) {
            stderr.puts (opt_context.get_help (true, null));
            return 0;
        }

        if (show_version) {
            Reporter.info ("VChecksum", VERSION);
            return 0;
        }

        ChecksumType algorithm_type;
        switch (algorithm) {
        case null:
            // Try to find algorithm from the name of the program
            var program_name = Path.get_basename (args[0]).ascii_down ();
            if (program_name.contains ("md5sum")) {
                algorithm_type = ChecksumType.MD5;
            } else if (program_name.contains ("sha1sum")) {
                algorithm_type = ChecksumType.SHA1;
            } else if (program_name.contains ("sha256sum")) {
                algorithm_type = ChecksumType.SHA256;
            } else if (program_name.contains ("sha384sum")) {
                algorithm_type = ChecksumType.SHA384;
            } else if (program_name.contains ("sha512sum")) {
                algorithm_type = ChecksumType.SHA512;
            } else {
                Reporter.warning ("AlgorithmWarning", "Algorithm not specified, use 'sha256' by default");
                algorithm_type = ChecksumType.SHA256;
            }
            break;
        case "md5":
            algorithm_type = ChecksumType.MD5;
            break;
        case "sha1":
            algorithm_type = ChecksumType.SHA1;
            break;
        case "sha256":
            algorithm_type = ChecksumType.SHA256;
            break;
        case "sha384":
            algorithm_type = ChecksumType.SHA384;
            break;
        case "sha512":
            algorithm_type = ChecksumType.SHA512;
            break;
        default:
            Reporter.error ("AlgorithmError", "Invalid algorithm");
            stderr.printf ("\n%s", opt_context.get_help (true, null));
            return 1;
        }

        if (threads == 0) {
            threads = (int) get_num_processors ();
        }

        var checksums = new Checksums (algorithm_type, threads);
        if (args.length == 1) {
            // Read from stdin
            checksums.checksum ("-");
            return checksums.exit_status;
        }

        for (var i = 1; i < args.length; i += 1) {
            checksums.checksum ((owned) args[i]);
        }

        return checksums.exit_status;
    }
}
