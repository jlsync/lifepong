
StateMachine ?= require('./sm').StateMachine
Game ?= require('./game').Game

states =
  start:
    full_name: 'Welcome'
    on_enter: (event) ->
      console.log "entering CSM start due to #{event.name}"
    on_exit: (event) ->
      console.log "exiting CSM start due to #{event.name}"
  in_game:
    full_name: 'In a Game'
  logged_out:
    full_name: 'Logged Out'


events =
  create_new_game:
    transitions:
      start: 'in_game'
    callback: (name: name) ->
      @game = new Game()
      @player.client.emit 'newgame', namespace: @game.namespace
      @game.trigger 'player_joined', @player
      true
  join_game:
    transitions:
      start: 'in_game'
    callback: (name: name) ->
      console.log 'Game collection is', Game.collection
      @game = Game.collection.get(name)
      console.log 'game id ', @game.id
      console.log 'game name ', @game.name
      console.log 'game is ', @game.namespace
      console.log 'game states ', @game.states
      if @game.current_state.name == 'start'
        @player.client.emit 'newgame', namespace: @game.namespace
        @game.trigger 'player_joined', @player
        return true
      else
        @player.client.emit 'mess', message: "Sorry game not accepting players"
        return false
  quit_game:
    transitions:
      in_game: 'start'
    callback: ->
      #already done client_side @player.client.emit 'quit_game', namespace: @game.namespace
      @game.trigger 'player_left', @player
      true
  game_over:
    transitions:
      in_game: 'start'
    callback: ->
      @game = null
      true
  logout:
    transitions:
      start: 'logged_out'
      in_game: 'logged_out'


class ClientStateMachine extends StateMachine
  @states = states
  @events = events
  constructor: (@player) ->
    super 'start', states, events
    @player.client.emit 'mess', message: "Welcome! current state is #{@current_state.name}."
    # todo move this next line to start state enter.
    @player.client.emit 'games_list', games_list: Game.start_collection.list()
    Game.start_collection.on 'change', =>
      @player.client.emit 'games_list', games_list: Game.start_collection.list()


    @on 'moved_state', (state_name = 'unknown!') => @player.client.emit 'mess', message: "moved state to #{state_name}"



(exports ? window).ClientStateMachine = ClientStateMachine

