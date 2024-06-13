# REQUIRES #######################################

EG = require '../libs/earl-grey' .EarlGrey

# CONFIG #########################################

app-tags = <[
  body defs div head meta script style title
]>

EG.compile app-tags

# INTERNALS ######################################

body = (data) ->
  #
  #
  # TODO
  #
  EG.body onload: 'App.init()' .bag do
    #
    #
    EG.div!push 'plop'
    #
  #

head = (data) ->
  EG.head!bag do
    EG.title:push 'Lofe'
    EG.meta charset: \utf-8
    EG.meta {name: \viewport, content: 'width=device-width,initial-scale=1'}
    #EG.style!push data.style
    #
    #EG.script {type: 'text/javascript'} .push data.script
    #
    # TODO
    #

# CORE ########################################### 

export generate = (data) ->
  #
  page = new EG!
  #
  page.bag do
    head data
    body data
  #
