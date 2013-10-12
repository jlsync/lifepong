
StateMachine ?= require('./sm').StateMachine
Card ?= require('./card').Card
Deck ?= require('./deck').Deck
Pile ?= require('./pile').Pile
Collection ?= require('./collection').Collection

states =
  start:
    full_name: 'Waiting for Players'
  shuffling:
    full_name: 'Shuffling Deck'
  dealing:
    full_name: 'Dealing cards'
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
      start: 'shuffling'
    callback: (data, player) ->
      @broadcast "game started by #{player.user_id}"
      @broademit "started"
      @deck.shuffle()
      for name, pile of @piles
        @broademit 'pile', pile: pile
      setTimeout =>
        @trigger('shuffled')
      , 1000
  shuffled:
    transitions:
      shuffling: 'dealing'
    callback: ->
      for p in @players
        hand = new Pile(name: "#{p.user_id}'s hand")
        @piles[hand.name] = hand
        hand.add @deck.deal()[0]
        hand.add @deck.deal()[0]
        hand.add @deck.deal()[0]
        hand.add @deck.deal()[0]
        p.hand = hand
        @playeremit p, 'pile', pile: p.hand
      setTimeout =>
        @trigger('delt')
      , 1000
  delt:
    transitions:
      dealing: 'playing'
    callback: ->
      @turn = @players[0]
      @broadcast "it's now #{@turn.id}'s turn!"
  played:
    transitions:
      playing: 'playing'
      playing: 'finished'
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

