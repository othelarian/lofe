# REQUIRES #######################################

require! {
  './earl-grey': {EarlGrey: EG}
  #'./oolong': {Oolong}
}

# INTERNALS ######################################

gen-head = (data) ->
  data-attrs =
    type: \application/json
    class: \lofe-data
  hd = EG.head!bag do
    EG.title!push data.title
    EG.meta charset: \utf-8
    EG.meta {name: \viewport, content: 'width=device-width,initial-scale=1'}
    # adding data
    EG.script {type: 'text/javascript'} .push 'Lofe = {};'
    # adding Lofe global (for some modules)
    EG.script data-attrs .push(JSON.stringify data.data)
  # adding styles
  for _, style of data.style
    hd.push(EG.style class: \lofe-style .push style)
  #
  # TODO: add modules
  #
  #for module in data.modules then
  #
  for idx, script of data.script
    attrs = id: "lofe-src-#idx", type: \text/javascript, class: \lofe-script
    hd.push(EG.script attrs .push script)
  hd

# EXPORTS ########################################

export EG = EG

export dl = (eg) !->
  a = eg.tostring! |> encodeURIComponent
  attrs =
    href: 'data:text/html;charset:utf-8,' + a
    download: 'lofe-default.html'
  e = EG.c-elt \a , attrs
  document.body.appendChild e
  e.click!
  document.body.removeChild e

export generate = (cfg) ->
  if cfg.tags? then EG.compile cfg.tags
  new EG!bag do
    gen-head cfg
    cfg.gen-body cfg

export q-sel = (s, a = no) ->
  if a then document.querySelectorAll s else document.querySelector s

export retrieve-head = ->
  # note: there's an issue with chrome 119-121 on reduce
  script = {}
  for elt in q-sel 'head .lofe-script' yes
    script[elt.getAttribute \id .substring 9] = elt.textContent
  do
    title: q-sel \title .textContent
    style: for e in q-sel('head .lofe-style' yes) then e.textContent
    data: for e in q-sel('head .lofe-data' yes) then e.textContent
    #
    # TODO: retrieving module
    #
    #
    script: script

export init-EG = (cfg) !->
  EG.compile cfg.tags
  window.EarlGrey = EG
