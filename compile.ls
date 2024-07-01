# REQUIRES #######################################

require! {
  bach, fs, path, sass
  '@othelarian/livescript': ls
  './libs/oolong': {Oolong}
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

data-handler =
  check-array: (arr, rec = yes, ctx = void) ->
    arr.flatMap (data) -> switch typeof! data
      | \String
        unless rec then data-handler.throw-error \rec, ctx
        data-handler.get-from-file data
      | \Object => Oolong.check data
      | _       => data-handler.throw-error \format that
  throw-error: (tp, ctx) !->
    msg = switch tp
      | \file   => "file \"#ctx\" contains invalid data"
      | \format => "data format not valid! (type: #ctx)"
      | \rec    => "trying to recursively load file into file \"#ctx\""
    throw new Error "DATA: #msg"
  get-from-file: (pth) ->
    clear-cache pth # if in dev mode, needed for reloading
    data = require pth .data
    switch typeof! data
      | \Array  => data-handler.check-array data, no, pth
      | \Object => [Oolong.check data]
      | _       => data-handler.throw-error \file pth
  read-data: (data) ->
    switch typeof! data
      | \String => data-handler.get-from-file data
      | \Array  => data-handler.check-array data
      | \Object => [Oolong.check data]
      | _       => fb that

err-cb = (err) !-> if err? then console.log err

execute = (prj, target, cfg, cb) !-->>
  console.log "Compiling \"#target\" ..."
  project = config.projects[prj]
  try
    out = switch cfg.type
      | \sass => sass.compile target, { style: \compressed } .css
      | \core
        if cfg.icons? then project.cfg[target]icons = get-icons cfg.icons
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
    switch project.type
      | \quine
        if cfg.type is \core # only core type can generate an output
          global.window = app: void # workaround to avoid window.app error
          project.cfg[target]script['core'] = out
          core-cfg = project.cfg[target]
          #
          # TODO: check here for modules
          #
          #
          clear-cache "./#target"
          require "./#target" .generate core-cfg .to-string!
            |> fs.writeFileSync "./dist/#{cfg.out}", _
          console.log "[OUT](#{new Date!toLocaleString!}): #{cfg.out}"
        else # if not core, update the project 'out' config
          switch cfg.type
            | \content
              #
              #project..cfg[cfg.link].content
              #
              # TODO: handle compiling content
              #
              void
              #
            | \lib
              for lk in cfg.link then project.cfg[lk].script[cfg.id] = out
            | \sass
              for lk in cfg.link then project.cfg[lk].style[target] = out
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
  project = config.projects[prj]
  project.out = {}
  project.cfg = {}
  prep = []
  out = []
  for fl, cfg of project.src
    p = execute prj, fl, cfg
    if cfg.type is \core
      project.cfg[fl] =
        script: {}, style: {}, data: [], modules: {}
        title: cfg.title ? 'No title'
      out.push p
    else prep.push p
    if config.dev then config.chok[fl] = type: cfg.type, project: prj
  if \data of project then for fl, data of project.data
    project.cfg[fl]data = data-handler.read-data data
  if config.dev and \requires of project
    for fl, cfg of project.requires
      config.chok[fl] = type: \req, project: prj, link: cfg
  prep ++ out

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
    else if pth in watchlist
      console.log "reload #pth"
      m = []
      prj = config.chok[pth]project
      if config.chok[pth]type is \req
        clear-cache "./#pth"
        for lk in config.chok[pth]link
          m.push(execute prj, lk, config.projects[prj]src[lk])
      else
        cfg = config.projects[prj]src[pth]
        m.push(execute prj, pth, cfg)
        unless config.chok[pth]type is \core
          console.log "=> link: #{cfg.link}"
          for lk in cfg.link
            m.push(execute prj, lk, config.projects[prj]src[lk])
      (bach.series m) err-cb
    else console.log "[ERROR]: WATCHER => #pth not find in watchlist!"
  cb void 3

# EXPORTS ########################################

export compile = !->
  actions = [ create-dir \./dist ]
  for prj of config.projects then actions = actions.concat(setup-prj prj)
  if config.dev then actions.push watch; actions.push serve
  (bach.series actions) err-cb

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