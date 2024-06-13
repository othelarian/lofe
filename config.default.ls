export cfg =
  chok:
    'config.default.ls': {type: \cfg}
  projects:
    default:
      desc: 'default version of Lofe'
      fonts: <[moon sun]>
      out:
        'default.html': 'default.ls'
      src:
        'default.ls': {type: \core, out: 'default.html'}