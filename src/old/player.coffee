
EE = if EventEmitter? then EventEmitter else require('events').EventEmitter
Collection = require('./collection').Collection
ClientStateMachine = require('./client_state_machine').ClientStateMachine


class Player extends EE
  @last_used_id = 0
  @collection = new Collection()

  constructor: (@user_id, @client) ->
    @sm = new ClientStateMachine(@)
    @id = ( @constructor.last_used_id += 1 )
    @constructor.collection.add @

  new_client: (new_client) ->
    # copy bindings...
    console.log "player #{@id} removing client #{@client.id}"
    new_client._events = @client._events
    @client = new_client
    console.log "player #{@id} added client #{@client.id}"



(exports ? window).Player = Player

