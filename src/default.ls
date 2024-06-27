# REQUIRES #######################################

core = require '../libs/core'

# DEFS ###########################################

app-tags = <[
  body button defs div head meta script style svg textarea title
]>
EG = core.EG
q-sel = core.q-sel

# INTERNALS ######################################
# EXPORTS ########################################

export generate = (cfg = void) ->
  unless cfg? # if not first compilation, get data
    cfg = core.retrieve-head!
    cfg.icons = q-sel '#lofe-icons defs' .innerHTML
  else cfg.tags = app-tags
  icons-attrs =
    xmlns: \http://www.w3.org/2000/svg width: 0, height: 0, id: \lofe-icons
  cfg.gen-body = (data) ->
    EG.body onload: 'app.init()' .bag do
      EG.svg icons-attrs .bag do
        EG.defs!push cfg.icons
      EG.div class: \lofe-menu .bag do
        EG.button onclick: 'app.dl()' .push 'DL'
      EG.div class: \lofe-body .bag do
        #
        # TODO: saving zone
        #
        EG.textarea!
        #
  core.generate cfg

# APP ############################################

window.app =
  dl: !->
    a = generate!to-string! |> encodeURIComponent
    attrs =
      href: 'data:text/html;charset:utf-8,' + a
      download: 'lofe-default.html'
    e = EG.c-elt \a , attrs
    document.body.appendChild e
    e.click!
    document.body.removeChild e
  init: !->
    core.init-EG {tags: app-tags}