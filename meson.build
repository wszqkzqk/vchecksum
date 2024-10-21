project('vchecksum', ['c', 'vala'],
          version: run_command('git', 'describe', '--tags', check: true).stdout().strip(),
    meson_version: '>= 0.61.0',
)

gio = dependency('gio-2.0')

incdir = include_directories('include')

if target_machine.system() == 'windows'
  add_project_arguments('-D', 'WINDOWS', language: 'vala')
endif

subdir('src')
