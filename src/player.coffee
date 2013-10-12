
EE = if EventEmitter? then EventEmitter else require('events').EventEmitter
Collection = require('./collection').Collection
{pong, Bat, PongApp, Ball} = require("./pong")

class Player extends EE
  @last_used_id = 0
  @collection = new Collection()
  @old_lat = null
  @old_lng = null

  constructor: (@user_id, @client) ->
    @id = ( @constructor.last_used_id += 1 )
    @constructor.collection.add @
    @client.emit 'mess', message: 'hello from new Player'
    pong.newPlayer(@user_id)

    player = @

    @client.on 'my_position', (data ) -> player.new_my_position(data)

  new_my_position: (data) ->
    @new_lat = parseFloat(data.latitude)
    @new_lng = parseFloat(data.longitude)
    if @last_lat and @last_lat <  @new_lat
      pong.move(from: @user_id, dir: "up")
    if @last_lat and @last_lat >  @new_lat
      pong.move(from: @user_id, dir: "down")

    @old_lat = @new_lat
    @old_lng = @new_lng

(exports ? window).Player = Player

