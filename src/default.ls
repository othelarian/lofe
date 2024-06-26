# REQUIRES #######################################

core = require '../libs/core'

# DEFS ###########################################

app-tags = <[
  body button defs div head meta script style svg textarea title
]>
EG = core.EG

# INTERNALS ######################################
# EXPORTS ########################################

export generate = (cfg = void) ->
  unless cfg? # if not first compilation, get data
    #
    # TODO: retrieve config data from the page
    #
    core.retrieve-head!
    #
    cfg = {}
    #
  else cfg.tags = app-tags
  icons-attrs =
    xmlns: \http://www.w3.org/2000/svg
    width: 0, height: 0, id: \lofe-icons
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
      #
    #
  core.generate cfg

# APP ############################################

window.app =
  dl: !->
    #
    # TODO: trigger the download of the modify version
    #
    console.log 'launch dl'
    #
    # TODO: retrieve-head is already in generate
    #
    console.log core.retrieve-head!
    #
    #
    #generate!
    #
  init: !->
    core.init-EG {tags: app-tags}