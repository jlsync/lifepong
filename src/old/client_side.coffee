
$('button.create').live 'click', ->
  socket.emit 'trigger', { trigger: 'create_new_game' }

$ ->

  sid = unescape((c for c in document.cookie.split(';') when c.match(/connect.sid=/))[0].match(/connect.sid=(.*)/)[1])


  window.socket = io.connect()

  $controls = $('#controls')

  $flash = $('#flash')
  if !$flash[0]?
    $flash = $('<div id="flash"/>')
    $flash.appendTo('body')

  socket.on 'connect', ->
    socket.emit 'session', sid: sid
    $flash.text 'connected!'


  socket.on 'broadcast', (message: message) ->
    console.log "broadcast: #{message}"
    $flash.text "broadcast: #{message}"

  socket.on 'mess', (message: message) ->
    console.log "message: #{message}"
    $flash.text "message: #{message}"

  socket.on 'games_list', (games_list: games_list) ->
    console.log "games_list:", games_list
    $gl = $('#games_list')
    $gl.empty()
    for name in games_list
      $b = $("<button>join game #{name}</button><br/>")
      $b.bind 'click', -> socket.emit 'trigger', trigger: 'join_game', name: name
      $gl.append $b

  socket.on 'disconnect', ->
    $flash.text 'disconnected!'


  socket.on 'newgame', (namespace: namespace) ->
    console.log "got newgame with namespace: #{namespace}"
    #window.game_socket = io.connect(namespace)
    $game = $('<div class="game"/>')
    $('#games').append $game
    $controls.hide()

    piles = {}

    socket.on "#{namespace}:startup", ->
      $game.empty()
      @$players = $('<div class="players"/>')
      $game.prepend @$players
      @$s = $("<button>start game</button>")
      @$s.bind 'click', -> socket.emit "#{namespace}:trigger", trigger: 'start_game'
      $game.append @$s
      @$gameflash = $('<div class="gameflash"></div>')
      $game.append @$gameflash

    socket.on "#{namespace}:player_joined", (players: players) ->
      @$players.html ("player: #{player}<br/>" for player in players).join('')

    socket.on "#{namespace}:player_left", (players: players) ->
      @$players.html ("player: #{player}<br/>" for player in players).join('')
      
    socket.on "#{namespace}:started", ->
      @$s.remove()
      @$q = $("<button>quit game</button>")
      @$q.bind 'click', ->
        socket.emit "trigger", trigger: 'quit_game'
        $game.remove()
        $controls.show()
        for e_name in [ "startup", "started", "finished", "player_joined", "player_left", "broadcast", "mess", "card", "pile" ]
          socket.removeAllListeners "#{namespace}:#{e_name}"
      $game.append @$q

    socket.on "#{namespace}:finished", ->
      @$s.remove()
      @$q.remove()
      @$q = $("<button>game finsihed! close game</button>")
      @$q.bind 'click', ->
        $game.remove()
        $controls.show()
      $game.append @$q
      for e_name in [ "startup", "started", "finished", "player_joined", "player_left", "broadcast", "mess", "card", "pile" ]
        socket.removeAllListeners "#{namespace}:#{e_name}"

    socket.on "#{namespace}:broadcast", (message: message) ->
      console.log "broadcast: #{message}"
      @$gameflash.append "<span>broadcast: #{message}<span></br>"

    socket.on "#{namespace}:mess", (message: message) ->
      console.log "message: #{message}"
      @$gameflash.append "<span>message: #{message}<span></br>"

    socket.on '#{namsapce}:card', (card: data) ->
      card = new Card(data)
      console.log card
      console.log "TODO"

    socket.on "#{namespace}:pile", (pile: data) ->
      if (pile = piles[data.name])?
        pile.fromJSON(data)
        console.log 'updated pile', data
      else
        pile = new Pile(data)
        pile.$game = $game
        piles[pile.name] = pile
        console.log 'new pile', data
        # todo: better location for this callback.
        pile.on 'played', (card) ->
          console.log 'card dropped on pile', card
          socket.emit "#{namespace}:trigger", trigger: "played", card: card, to: pile , from: card.location
      pile.show()


