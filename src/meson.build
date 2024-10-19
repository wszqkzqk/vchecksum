version_file = vcs_tag(
   command: ['git', 'describe', '--tags'],
     input: 'version.vala.in',
    output: 'version.vala',
)

executable_sources = [
  'checksumitem.vala',
  'checksums.vala',
  'main.vala',
  'reporter.vala',
  version_file,
]

basic_deps = [
  gio,
]

executable('vchecksum', executable_sources,
  dependencies: basic_deps,
  install: true,
  include_directories: incdir,
)

hash_algorithms = ['md5', 'sha1', 'sha256', 'sha384', 'sha512']

foreach algorithm : hash_algorithms
  install_symlink('v' + algorithm + 'sum',
                  pointing_to: 'vchecksum',
                  install_dir: get_option('bindir'))
endforeach
