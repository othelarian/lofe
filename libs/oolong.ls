export class Oolong
  # init  ####################
  (
    @id = void, @name = 'Unnamed', @tags = [], @props = {},
    @created = void, @mod = '', @content = ''
  ) ->
    unless @id? then @id = crypto.randomUUID!
    unless @created? then @created = Oolong.gen-date!
  # static methods ###########
  @check = (data, res = void) ->
    dte-reg = /^\d{4}(-\d{2}){2} (\d{2}:){2}\d{2}$/
    for key in <[id name tags props created mod content]>
      unless key of data
        if key is \id
          if res? then res.push void
        else throw new Error "OOLONG: Missing key in the json: \"#key\""
      else
        v = data[key]
        c = switch key
          | \id
            typeof! v is \String and
              /^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$/.test v
          | \name => typeof! v is \String
          | \tags
            unless typeof! v is \Array then no
            else
              r = yes
              for t in v then if typeof! t isnt \String then r = no; break
              r
          | \props => typeof! v is \Object
          | \created => typeof! v is \String and dte-reg.test v
          | \mod => typeof! v is \String and (v.length is 0 or dte-reg.test v)
          | \content => yes
          | _ => throw new Error "OOLONG: Unexpected key in the json: \"#key\""
        unless c then throw new Error "OOLONG: Bad input in \"#key\""
        else if res? then res.push v
    if res? then res else data
  @from-json = (json) -> new Oolong ...(Oolong.check json, [])
  @from-string = Oolong.from-json << JSON.parse
  @gen-date = ->
    dte = new Date!toLocaleString! |> /^(\d{2})\/(\d{2})\/(\d{4})(.{9})$/.exec
    "#{dte.3}-#{dte.2}-#{dte.1}#{dte.4}"
  # static attributes ########
  # methods ##################
  to-json: ->
    do
      id: @id
      name: @name
      tags: @tags
      props: @props
      created: @created
      mod: @mod
      content: @content
  to-string: -> @to-json! |> JSON.stringify
  # attributes ###############