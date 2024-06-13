export class EarlGrey
  # init #####################
  (@dt = '', @name = '', @attrs = {}, @children = []) ->
    if @dt is '' then @dt = \html; @name = \html
    else if @dt is \html and @name is '' then @name = \html
  # statics ##################
  @compile = (arr) !->
    hdl = (name) ->
      (...opts) -> EarlGrey.tag name, ...opts
    for elt in arr then EarlGrey[elt] = hdl elt
  @from-json = (json) ->
    rec = {children: []}
    for key in <[dt name attrs children]>
      unless json.hasOwnProperty key
        throw new Error "Missing key in the json: \"#name\""
      else if key is \children
        for child, idx in json.children
          if typeof! child is \String then rec.children.push child
          else if typeof! child is \Object
            rec.children.push EarlGrey.from-json child
          else throw new Error "This child cannot be handled (#idx): #child"
      else
        expt = if key is \attrs then \Object else \String
        unless typeof! json[key] is expt
          throw new Error "Value's type unexpected: #key = #{json[key]}"
        else rec[key] = json[key]
    new EarlGrey rec.dt, rec.name, rec.attrs, rec.children
  @tag = (name, ...opts) ->
    attr-ok = no
    attrs = {}
    children = []
    check-opt = (opt) ->
      switch typeof! opt
        | \Object
          if opt instanceof EarlGrey then \earl else \attrs
        | \Array  => \arr
        | \String => \tea
        | otherwise => throw new Error "Invalid arg: #{opt}"
    for elt, idx in opts
      tp = check-opt elt
      if tp is \attrs and idx is 0 and not attr-ok
        attrs = elt
        attr-ok = yes
      else if tp is \arr and (idx is 0 or idx is 1)
        children = elt
      else if tp in <[earl tea]> then children.push elt
      else throw new Error "bad argument: arg #{idx + 2}"
    new EarlGrey \tag, name, attrs, children
  # attributes ###############
  # methods ##################
  clean: -> @children = []; @
  delete: (index) ->
    unless index < @children.length
      new Error 'Index bigger than the children length!'
    else @children.splice index, 1; @
  doctype: (@dt) -> @
  bag: (...children) ->
    for child, idx in children then @push child
    @
  insert: (index, tag) ->
    unless tag instanceof EarlGrey or typeof! tag is \String
      throw new Error "This is not a EarlGrey Object or a String!"
    else @children.splice index, 0, tag; @
  push: (tag) ->
    if tag instanceof EarlGrey or typeof! tag is \String
      @children.push tag
      @
    else
      console.error tag
      throw new Error 'This is not a EarlGrey Object or a String!'
  to-json: ->
    hdl = -> if typeof! it is \String then it else it.to-json!
    do
      dt: @dt
      name: @name
      attrs: @attrs
      children: @children.map hdl
  to-string: ->
    r =
      if @dt is \html then '<!DOCTYPE html>'
      else if @dt is \tag then ''
      else @dt
    r ++= "<#{@name}"
    hdl = (elt) ->
      if elt instanceof EarlGrey then elt.toString!
      else if (typeof! elt is \String) then elt
      else ''
    for key, val of @attrs then r ++= " #key=\"#val\""
    ed =
      if @children.length is 0 then '/>'
      else '>' ++ (@children.map hdl).join('') ++ "</#{@name}>"
    r ++ ed