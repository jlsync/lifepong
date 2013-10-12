
global.__root ?= "#{__dirname}/.."
siteConf = require(global.__root + '/siteConf.js')

exports.User = class User
  constructor: (@user_id, @client) ->
    @sm = new ClientStateMachine(@)
    @id = ( @constructor.last_used_id += 1 )
    @constructor.collection.add @

  toJSON: (viewer) ->
    # if view.admin
    # if view.id == @id
    id: @id
    name: @name
    image: @image


User.require_user = (req,res,next) ->
  next()
  #if Math.random() > 0.5
  #  res.end "hello jason"
  #else
  #  next()
    

User.connected = (client) ->
  user = client.handshake.session.user



