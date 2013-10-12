
EE = if EventEmitter? then EventEmitter else require('events').EventEmitter
Collection = require('./collection').Collection

# connection maps to one browser tab.
# client re-connects are indentified.
exports.Connection = class Connection extends EE
  @collection = new Collection()

  @bindings = {}

  @bindings['disconnect'] = ->
    console.log "socket disconnect connection #{@id} socket #{@sio.id}"

  constructor: (id: id, sio: sio) ->
    @id = id
    @sio = sio
    @user = @sio.handshake.session.user
    @socket_bindings()
    @constructor.collection.add @

  reconnect: (sio) ->
    @sio = sio
    @user = @sio.handshake.session.user
    @socket_bindings()
    @sio.emit 'reconnected'
    console.log "socket  reconnect connection #{@id} socket #{@sio.id}"

  # bind all the bindings(listeners) to sio
  socket_bindings: ->
    for event, fn of Connection.bindings
      do (event, fn) =>
        @sio.on event, (args...) =>
          fn.apply(this, args)


User = require('./user').User

Connection.connection = (client) ->
  nuid = client.handshake.nuid
  unless nuid?
    console.log "Dropping connection, No NUID found for", client.handshake
    return

  if user = client.handshake.session.user
    if not user.id?
      User.findOrCreate user, (muser) ->
        user.id = muser.id

        # Join user to specific user channel/room, 
        # this is good so content is send across user browsers & devices.
        client.join "user_#{client.handshake.session.user.id}"
    else
      # Join user to specific user channel/room, 
      # this is good so content is send across user browsers & devices.
      client.join "user_#{client.handshake.session.user.id}"


  user_name = (if user then user.name else "UID: " + (client.handshake.session.uid or "has no UID"))

  
  # Join user to specific page/connection channel/room, 
  # this is to keep state accross socket restarts
  client.join nuid
  
  # Join user to specific session channel/room, 
  # this is good so content is send across user tabs.
  client.join client.handshake.sid

  if (existing = @collection.get(nuid))?
    existing.reconnect(client)
  else
    new Connection({id: nuid, sio: client})


