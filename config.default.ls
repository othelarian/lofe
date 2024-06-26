export cfg =
  server:
    port: 5001 # only value of server config
  chok: # can't be override
    'config.default.ls': { type: \cfg }
  projects: # 'config.ls' will add and override projects configs
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
      content: {}
        #
        # TODO: icons into content?
        #
    ghpages:
      desc: ''
      type: \mono
      src: {}