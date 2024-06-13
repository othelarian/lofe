# REQUIRES #######################################

require! fs

# INTERNALS ######################################

create-dir = (dir, cb) !-->
  er <- fs.mkdir dir
  if er?
    unless er.code is \EEXIST then cb er else cb void 1

execute = (target, cb) !-->
  #
  #
  # TODO
  #
  cb 'not ready'
  #

serve = !->
  require! express
  srv = express!
  srv.use express.static \./dist
  console.log 'starting to serve'
  srv.listen 5001

watch = (cb) !->
  console.log 'start watching'
  watch = require \chokidar .watch
  watcher = watch (Object.keys config.chok), awaitWriteFinish: yes
  watcher.on \change, (pth) !->
    #
    # TODO
    #
    console.log "Changing: #pth"
    #
    # TODO: if type is \cfg then reload all projects
    #
  cb void 3

# EXPORTS ########################################

export compile = (opts) !->
  #
  # TODO
  #
  #
  actions = [ create-dir \./dist ]
  #
  console.log config
  #
  if opts.dev? then actions.push watch; actions.push serve
  #
  console.log actions
  #
  (err) <- (require 'bach' .series actions)
  if err? then console.log err
