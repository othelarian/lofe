export cfg =
  chok:
    'config.default.ls': {type: \cfg}
  projects:
    default:
      desc: 'default version of Lofe'
      #fonts:
      #  'src/default.ls': <[moon sun]>
      type: \mono
      src:
        'src/default.ls': {type: \core, out: 'default.html'}
        'src/style.sass': {type: \sass, link: 'src/default.ls'}
        #'a/lib.ls': {type: \lib, link: 'src/default.ls', id: 'an-id'}
    ghpages:
      desc: ''
      type: \mono
      src: {}