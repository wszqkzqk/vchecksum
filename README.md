# VChecksum

VChecksum is a simple tool to calculate the checksum of **files or urls**. It supports MD5, SHA1, SHA256, SHA384, SHA512 (using GLib's GChecksum).

## Features

* Calculate checksum of a local file
* Calculate checksum of a remote file (url)
* Supports MD5, SHA1, SHA256, SHA512
* Supports multiple files/urls
* Supports multiple threads

## Build

### Dependencies

#### Runtimes

* GLib
* GVFS (optional, for remote file support)

On Arch Linux:

```bash
sudo pacman -S glib2 gvfs --needed
```

On Windows (MSYS2):

```bash
pacman -S mingw-w64-ucrt-x86_64-glib2 mingw-w64-ucrt-x86_64-gvfs --needed
```

#### Development

* GLib
* Meson
* Vala

On Arch Linux:

```bash
sudo pacman -S glib2 meson vala --needed
```

On Windows (MSYS2):

```bash
pacman -S mingw-w64-ucrt-x86_64-glib2 mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-vala --needed
```

### Build

```bash
meson setup builddir --buildtype=release
meson compile -C builddir
```

### Install

```bash
meson install -C builddir
```

## Usage

```log
Usage:
  vchecksum [OPTION…] [Files...] - Calculate checksum of files

Options:
  -h, --help                                                     Show help message
  -v, --version                                                  Display version number
  -a, --algorithm='md5' 'sha1' 'sha256' 'sha384' or 'sha512'     The hash algorithm (Auto-detect if unspecified)
  -t, --threads=NUM                                              The number of threads to use
```

If the executable is named as following:

* `vmd5sum` - It will default to MD5
* `vsha1sum` - It will default to SHA1
* `vsha256sum` - It will default to SHA256
* `vsha384sum` - It will default to SHA384
* `vsha512sum` - It will default to SHA512

If the executable is named as `vchecksum` and no algorithm is specified by `-a`, it will default to **SHA256**.

* Tips:
  * `-` can be used to read from stdin.
  * If no files are specified, it will also read from stdin.
    * Use `Ctrl+D` (Linux) or `Ctrl+Z and Enter` (Windows) to end input.
  * If you need to keep the order of multiple files, you can use the `--threads=1` option.

## Why do I develop this?

I'm maintaining [an unoffical Arch Linux port for loong64](https://loongarchlinux.lcpu.dev/). This project uses [patch set](https://github.com/lcpu-club/loongarch-packages) to fix some packages and let them work on loong64.

Sometimes we need to not only patch the `PKGBUILD` but also the source code. Arch Linux needs checksums for each file in `source` array. To avoid patch failure as much as possible, we don't use Arch Linux's `updpkgsums` script to update checksums. Instead, we use `source+=` and `sha256sums+=`, etc., to add new files and checksums.

Sometimes the source file is not a local file but a remote url, and I usually don't want to download it to my own x86_64 machine. So I developed this tool that can **calculate the checksum of remote files**.

Because GLib integrates a powerful thread pool function, I also support multithreading for this program.
