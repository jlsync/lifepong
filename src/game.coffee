
window.StateMachine ?= require('./sm').StateMachine
window.Collection ?= require('./collection').Collection

states =
  start:
    full_name: 'Waiting for Players'
  starting:
    full_name: 'Starting Up'
  playing:
    full_name: 'Playing'
  finished:
    full_name: 'Finished'


events =
  player_joined:
    transitions:
      start: 'start'
    callback: (player) ->
      player.client.on "#{@namespace}:trigger", (data) =>
        console.log "from #{player.user_id} game trigger got:", data
        @trigger data.trigger, data, player
      # todo , regisiter a 'disconnect' handler?
      @players.push player
      @playeremit player, 'startup'
      @broadcast "new player! #{player.user_id}"
      @broademit "player_joined", players: (p.id for p in @players)
      true
  player_left:
    transitions:
      start: 'start'
      playing: 'playing'
    callback: (player) ->
      @players = (p for p in @players when p != player)
      @broadcast "player left! #{player.user_id}"
      @broademit "player_left", players: (p.id for p in @players)
      true
  start_game:
    transitions:
      start: 'starting'
    callback: (data, player) ->
      @broadcast "game started by #{player.user_id}"
      @broademit "started"
      for name, pile of @piles
        @broademit 'pile', pile: pile
      setTimeout =>
        @trigger('shuffled')
      , 1000
  played:
    transitions:
      playing: [ 'playing', 'finished' ]
    callback: (data, player) ->
      if @turn == player
        card = new Card(data.card)

        @piles[data.from.name].remove card
        @piles[data.to.name].add card

        @playeremit player, 'pile', pile: player.hand
        @broademit('pile', pile: pile) for pile in @shared_piles
        # game logic
        if (Math.floor(Math.random() * 10) % 7) == 0
        
          @broadcast "#{@turn.id} wins! Game Over"
          @playercast @turn, "YOU WIN! Game Over"
          @broademit "finished"  # todo: move to callback on finished state
          return 'finished'
        else
          @advance_turn()
          @broadcast "it's now #{@turn.id}'s turn!"
          @playercast @turn, "it's your turn!"
          return 'playing'
      else
        @playercast player, "It's not your turn. It's #{@turn.id}'s turn"
        @playeremit player, 'pile', pile: player.hand
        @playeremit( player, 'pile', pile: pile) for pile in @shared_piles
        return 'playing'
  play_timeout:
    transitions:
      playing: 'playing'


class Game extends StateMachine
  @states = states
  @events = events
  constructor: () ->
    super()
    @players = []
    @deck = new Deck()
    @piles = {}
    @piles['the pile'] = new Pile(name: 'the pile')
    @piles['the other pile'] = new Pile(name: 'the other pile')
    @shared_piles = (pile for name, pile of @piles)
    @turn = null
    @name = @id
    @name = "#{Math.floor(Math.random() * 1000000000000)}" #TODO make unique
    @namespace = "game:#{@name}"

    @on 'moved_state', (state_name) =>
      @broadcast "game moved to #{state_name}"

    @getState('finished').on 'enter', =>
      p.sm.trigger 'game_over' for p in @players
      # todo: move this cleanup to sm special 'finished' state or event
      Game.collection.remove @id
      Game.finished_collection.remove @id

   playeremit: (p, event, args...) ->
     console.log "game #{@namespace} playeremit: #{p.user_id} #{event}", args...
     p.client.emit("#{@namespace}:#{event}", args...)

   playercast: (p, message) ->
     console.log "game #{@namespace} playercast: #{p.user_id} #{message}"
     p.client.emit("#{@namespace}:broadcast", message: message)

   broademit: (event, args...) ->
     console.log "game #{@namespace} broademit: #{event}", args...
     p.client.emit("#{@namespace}:#{event}", args...) for p in @players

   broadcast: (message) ->
     console.log "game #{@namespace} broadcast: #{message}"
     p.client.emit("#{@namespace}:broadcast", message: message) for p in @players

   advance_turn: ->
     @turn = @players[(@players.indexOf(@turn) + 1) % @players.length]

# temp. create a game
new Game()

(exports ? window).Game = Game

{Connection} = require('./connection')

Connection.bindings['list_games'] = (data) ->
  c = @
  Game.all (err, all) =>
    console.log(err) if err?
    c.sio.emit "game_list", { games: g.toJSON() for g in all }
    #eqivalent: global.io.sockets.in(c.id).emit "game_list", { ....  }



