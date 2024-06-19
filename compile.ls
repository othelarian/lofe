# REQUIRES #######################################

require! {
  fs, path, sass
  '@othelarian/livescript': ls
}

# INTERNALS ######################################

brew-ls = (file) ->
  require! through
  if path.extname(file) is \.ls
    data = ''
    end = !->
      @queue(ls.compile data, {bare: yes, header: no})
      @queue null
    through ((buf) !-> data += buf), end
  else through!

compile-ls = (pth) ->>
  require! browserify
  b = browserify pth, {extensions: [ \.ls ], transform: brew-ls}
    .plugin \@browserify/uglifyify
    .plugin \common-shakeify
    .plugin \browser-pack-flat/plugin
  if config.release
    o = b.bundle!pipe(require('minify-stream')(sourceMap: no))
    p = new Promise (res) ->
      data = ''
      o.on \data, (buf) !-> data ++= buf
      o.on \finish, !->
        res data
    await p
  else
    handler = (res, rej) !->
      bcb = (err, buf) !-> if err isnt null then rej err else res buf
      b.bundle bcb
    (await (new Promise handler)).toString!

create-dir = (dir, cb) !-->
  er <- fs.mkdir dir
  if er?
    unless er.code is \EEXIST then cb er else cb void 1

execute = (project, target, cfg, cb) !-->>
  try
    out = switch cfg.type
      | \sass => sass.compile target, { stype: \compress } .css
      | \core => compile-ls target
      | _
        msg = "[ERROR]: missing type in '#target' in project '#project'"
        throw new Error msg
    switch config.projects[project].type
      | \mono
        if cfg.type is \core # only core type can generate an output
          global.window = app: void # workaround to avoid window.app error
          config.projects[project].cfg[target].script['core'] = out
          core-cfg = config.projects[project].cfg[target]
          require "./#target" .generate core-cfg .to-string!
            |> fs.writeFileSync "./dist/#{cfg.out}", _
        else # if not core, update the project 'out' config
          switch cfg.type
            | \content
              #
              #config.projects[project].cfg[cfg.link].content
              #
              # TODO
              #
              void
              #
            | \lib
              config.projects[project].cfg[cfg.link].script[cfg.id] = out
            | \sass
              config.projects[project].cfg[cfg.link].style[target] = out
      | _
        msg = "[ERROR]: missing type in project '#project'"
        throw new Error msg
    cb void 7
  catch
    cb e

get-font = (project, cb) !-->
  #
  # TODO
  #
  console.log 'font process (not ready)'
  #
  cb void 2
  #

setup-prj = (prj) ->
  console.log "setup project '#prj'"
  config.projects[prj].out = {}
  config.projects[prj].cfg = {}
  prep = []
  out = []
  if config.projects[prj].fonts?
    #prep.push(get-font project)
    #
    # TODO: move to out selector
    #
    void
    #
    # TODO: watch
    #
  for fl, cfg of config.projects[prj].src
    p = execute prj, fl, cfg
    if cfg.type is \core
      config.projects[prj].cfg[fl] = script: {}, style: {}, content: {}
      out.push p
    else prep.push p
    #
    # TODO: watch
    #
    #
  prep.concat out

watch = (cb) !->
  console.log 'start watching'
  watch = require \chokidar .watch
  config.watcher = watch (Object.keys config.chok), awaitWriteFinish: yes
  config.watcher.on \change, (pth) !->
    #
    # TODO
    #
    console.log "Changing: #pth"
    #
    # TODO: if type is \cfg then reload all projects
    #
  cb void 3

# EXPORTS ########################################

export compile = !->
  actions = [ create-dir \./dist ]
  for prj of config.projects then actions = actions.concat(setup-prj prj)
  if config.dev
    #
    # TODO: prepare config
    #
    config.chok = {}
    #
    actions.push watch; actions.push serve
  (err) <- (require 'bach' .series actions)
  if err? then console.log err

export serve = !->
  require! express
  srv = express!
  srv.use express.static \./dist
  console.log 'starting to serve'
  srv.listen 5001
