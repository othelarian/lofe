# MODULES ########################################

modules =
  #admin: {}
  'feather-dl':
    name: \feather-dl
    src:
      'modules/common/feather-dl/feather-dl.ls': {type: 'ls'}
  #notifs: {}

# PROJECTS #######################################

projects =
  default:
    desc: 'default version of Lofe'
    type: \quine
    src:
      'src/default.ls':
        type: \core, out: 'default.html', title: 'Lofe - default'
        icons: <[Moon Sun]>
      'src/style.sass': {type: \sass, link: ['src/default.ls']}
      #'a/lib.ls': {type: \ls, link: 'src/default.ls', id: 'an-id'}
    modules:
      'feather-dl': ['src/default.ls']
    data:
      'src/default.ls': './data/default-data'
      #'src/default.ls': {...Oolong object, as a json...}
      #'src/default.ls': [array of Oolong objects and/or file path]
    requires: # this is just to add files to watch when working on core libs
      'libs/core.ls': ['src/default.ls']
  ghpages:
    desc: ''
    type: \quine
    src: {}
    data: 'data/ghpage-data.ls'

# EXPORT CFG #####################################

export cfg =
  server:
    port: 5001 # only value of server config
  chok: # can't be override
    'config.default.ls': { type: \cfg }
  projects: projects # 'config.ls' will add and override projects configs
  modules: modules