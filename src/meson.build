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
