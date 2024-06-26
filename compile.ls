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

clear-cache = (file) !->
  pth = path.resolve file
  if require.cache[pth]? then delete require.cache[pth]

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
      | \sass => sass.compile target, { style: \compressed } .css
      | \core
        if cfg.icons?
          config.projects[project].cfg[target].icons = get-icons cfg.icons
        fallthrough
      | \lib => compile-ls target
      | \content
        #
        # TODO: if there's some icons for a content, load them here?
        #
        # TODO: handle content compilation
        #
        ...
        #
      | _
        msg = "[ERROR]: missing type in '#target' in project '#project'"
        throw new Error msg
    switch config.projects[project].type
      | \mono
        if cfg.type is \core # only core type can generate an output
          global.window = app: void # workaround to avoid window.app error
          config.projects[project].cfg[target].script['core'] = out
          core-cfg = config.projects[project].cfg[target]
          #
          # TODO: if there is icons key in config, then load icons
          #
          #
          clear-cache "./#target"
          require "./#target" .generate core-cfg .to-string!
            |> fs.writeFileSync "./dist/#{cfg.out}", _
        else # if not core, update the project 'out' config
          switch cfg.type
            | \content
              #
              #config.projects[project].cfg[cfg.link].content
              #
              # TODO: handle compiling content
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

get-icons = (list) ->
  require! { 'lucide-static': lucide }
  clip = (h, s) ->
    s = s.substring s.search('>') + 2
    s = s.split '\n'
    while s[s.length - 1] is '</svg>' or s[s.length - 1] is '' then s.pop()
    s = s.map (e) -> e.trim()
    "<symbol id=\"#{h}\">" + (s * '') + '</symbol>'
  (list.map (elt) -> clip elt, lucide[elt]) * ''

setup-prj = (prj) ->
  console.log "setup project '#prj'"
  config.projects[prj].out = {}
  config.projects[prj].cfg = {}
  prep = []
  out = []
  for fl, cfg of config.projects[prj].src
    p = execute prj, fl, cfg
    if cfg.type is \core
      config.projects[prj].cfg[fl] =
        script: {}, style: {}, content: {}, title: cfg.title ? 'No title'
      out.push p
    else prep.push p
    config.chok[fl] = type: cfg.type
  prep.concat out

watch = (cb) !->
  console.log 'start watching'
  watch = require \chokidar .watch
  watchlist = Object.keys config.chok
  config.watcher = watch watchlist, awaitWriteFinish: yes
  config.watcher.on \change, (pth) !->
    pth = pth.replaceAll '\\', '/'
    if pth in <[config.default.ls config.ls]>
      #
      # TODO: handle config reload
      #
      console.log 'altering config (not implemented)'
      #
      #
    else if pth in watchlist
      #
      # TODO: launch the appropriate process
      #
      console.log "reload #pth"
      #
      #
    else console.log "[ERROR]: WATCHER => #pth not find in watchlist!"
  cb void 3

# EXPORTS ########################################

export compile = !->
  actions = [ create-dir \./dist ]
  for prj of config.projects then actions = actions.concat(setup-prj prj)
  if config.dev
    #
    # TODO: get back the server after getting watcher ok
    #
    actions.push watch#; actions.push serve
    #
  (err) <- (require 'bach' .series actions)
  if err? then console.log err

export serve = !->
  require! express
  srv = express!
  srv.use express.static \./dist
  #
  #
  #srv.options
  srv.put '*', (req, res) ->
    #
    # TODO: feather system
    #
    /*
      cwd = process.cwd!
      data = ''
      req.on 'data', (chunk) -> data += chunk
      req.on 'end', ->
        savePath = path.resolve cwd, 'builds', 'put-save.html'
        fse.writeFile savePath, data, (err) ->
          if err then throw err
          outKb = (Uint8Array.from Buffer.from(data)).byteLength
          outKb = ((outKb * 0.000977).toFixed 3) + 'kB'
          console.info savePath, outKb
    */
    res.ok!
    #
  #
  console.log "starting to serve (on http://localhost:#{config.server.port})"
  srv.listen config.server.port