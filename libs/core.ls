# REQUIRES #######################################

EG = require './earl-grey' .EarlGrey

# INTERNALS ######################################

gen-head = (data) ->
  hd = EG.head!bag do
    EG.title!push 'Lofe'
    EG.meta charset: \utf-8
    EG.meta {name: \viewport, content: 'width=device-width,initial-scale=1'}
  for _, style of data.style then hd.push(EG.style!push style)
  #
  # TODO: add content
  #
  #for content in data.content then
  #
  for idx, script of data.script
    hd.push do
      EG.script {id: "lofe-scr-#idx", type: 'text/javascript'} .push script
  hd

# EXPORTS ########################################

export EG = EG

export generate = (cfg) ->
  if cfg.tags? then EG.compile cfg.tags
  new EG!bag do
    gen-head cfg
    cfg.gen-body cfg

export init-EG = (cfg) !->
  EG.compile cfg.tags
  window.EarlGrey = EG
