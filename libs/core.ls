# REQUIRES #######################################

EG = require './earl-grey' .EarlGrey

# INTERNALS ######################################

gen-head = (data) ->
  hd = EG.head!bag do
    EG.title!push data.title
    EG.meta charset: \utf-8
    EG.meta {name: \viewport, content: 'width=device-width,initial-scale=1'}
    EG.script {type: 'text/javascript'} .push 'Lofe = {};'
  for _, style of data.style
    hd.push(EG.style class: \lofe-style .push style)
  #
  # TODO: add content
  #
  #for content in data.content then
  #
  for idx, script of data.script
    attrs = id: "lofe-src-#idx", type: \text/javascript, class: \lofe-script
    hd.push(EG.script attrs .push script)
  hd

# EXPORTS ########################################

export EG = EG

export generate = (cfg) ->
  if cfg.tags? then EG.compile cfg.tags
  new EG!bag do
    gen-head cfg
    cfg.gen-body cfg

export q-sel = (s, a = no) ->
  if a then document.querySelectorAll s else document.querySelector s

export retrieve-head = ->
  src-red = (acc, elt) ->
    acc[elt.getAttribute \id .substring 9] = elt.textContent
    acc
  do
    title: q-sel \title .textContent
    style: for e in q-sel('head .lofe-style' yes) then e.textContent
    #
    # TODO: retrieving content schard
    #
    #content: []
    #
    script: (q-sel 'head .lofe-script' yes .values!).reduce src-red, {}

export init-EG = (cfg) !->
  EG.compile cfg.tags
  window.EarlGrey = EG
