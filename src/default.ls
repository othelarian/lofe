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
    #
    # TODO: get the data and modules
    #
    console.log cfg
    #
    return
    #
    cfg.icons = q-sel '#lofe-icons defs' .innerHTML
  else cfg.tags = app-tags
  icons-attrs =
    xmlns: \http://www.w3.org/2000/svg width: 0, height: 0, id: \lofe-icons
  cfg.gen-body = (data) ->
    EG.body onload: 'Lofe.init()' .bag do
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

# LOFE APP #######################################

App =
  dl: !-> core.dl generate!
  init: !->
    #
    # TODO: add the module init
    #
    #
    core.init-EG {tags: app-tags}
    try
      #
      # TODO: load modules here
      #
      Lofe.data = core.get-data!
    catch
      #
      # TODO: handle if something is corrupted
      #
      console.log e
      #
    #

# LOFE SET UP ####################################

if window.Lofe is void then void
else for k, v of App then window.Lofe[k] = v