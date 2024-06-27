# MODULES ########################################

modules =
  admin: {} # TODO: admin module
  feather-dl: {}
    #
    # TODO: feather-dl plugin
    #

# PROJECTS #######################################

projects =
  default:
    desc: 'default version of Lofe'
    type: \mono
    src:
      'src/default.ls':
        type: \core, out: 'default.html', title: 'Lofe - default'
        #externals: []
        icons: <[Moon Sun]>
      'src/style.sass': {type: \sass, link: ['src/default.ls']}
      #'a/lib.ls': {type: \lib, link: 'src/default.ls', id: 'an-id'}
    modules: {}
      #
      #
      #
      # TODO: icons into content?
      #
    data: 'its/a/file' # {zip: 'test data'}
  ghpages:
    desc: ''
    type: \mono
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