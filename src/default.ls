# REQUIRES #######################################

core = require '../libs/core'

# DEFS ###########################################

app-tags = <[
  body button defs div head meta script style textarea title
]>
EG = core.EG

# INTERNALS ######################################
# EXPORTS ########################################

export generate = (cfg = void) ->
  unless cfg? # if not first compilation, get data
    #
    # TODO
    #
    cfg = {}
    #
  else cfg.tags = app-tags
  cfg.gen-body = (data) ->
    #
    # TODO
    #
    EG.body onload: 'app.init()' .bag do
      #
      #
      EG.div {class: \lofe-menu } .bag do
        #
        # TODO: menu
        #
        EG.button!push 'DL'
        #
      EG.div {class: \lofe-body } .bag do
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
  init: !->
    #
    # TODO
    #
    core.init-EG {tags: app-tags}
    #
    console.log 'plop'
    #
