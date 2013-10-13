BAT_ACCELERATION = 10 # 0.40
BAT_TERMINAL_VELOCITY = 50
BAT_FRICTION = 0.10
BALL_ACCELERATION = 5
BALL_TERMINAL_VELOCITY = 5
BALL_FRICTION = 0
LEFT = 0
RIGHT = 1

class Canvas

  constructor: (width, height) ->
    @width = width
    @height = height

  new_position: (id, x, y, w, h, kind, side ) ->
    global.io.sockets.emit('new_position',
      id: id
      lat: "#{51.50449 - ( y / 1000000.0)}"
      lng: "#{0.0 - 0.01853 + ( x / 1000000.0 )}"
      w: w
      h: h
      kind: kind
      side: side
    )
    #todo global emit or emit to players
    
  undraw: (id, kind ) ->
    global.io.sockets.emit('undraw', id: id, kind: kind)


class Entity
  @next_id = 0

  x: 0, y: 0, vx: 0, vy: 0, r: 0, g: 0, b: 0
  constructor: (@canvas, @maxX, @maxY, @minX, @minY, @offsetX, @offsetY, @a, @tv, @f) ->
    @score = 0
    @id = Entity.next_id
    Entity.next_id += 1

  score_plus_one: -> @score += 1

  getScore: -> @score

  update: ->
    # Apply friction
    @vx -= @f if @vx > 0
    @vx += @f if @vx < 0
    @vy -= @f if @vy > 0
    @vy += @f if @vy < 0

    # Make sure we dont go faster than terminal velocity
    @vx = @tv if @vx > @tv
    @vx = -@tv if @vx < -@tv
    @vy = @tv if @vy > @tv
    @vy = -@tv if @vy < -@tv

    # Update the entitys co-ordinates
    @x += @vx
    @y += @vy

    @checkBoundary()
  
  checkBoundary: ->
    @x = @maxX-@w if @x+@w > @maxX
    @x = @minX if @x < @minX
    @y = @maxY-@h if @y+@h > @maxY
    @y = @minY if @y < @minY

  draw: ->
    @canvas.new_position(@id, @x+@offsetX, @y+@offsetY, @w, @h, @kind, @side )

  undraw: ->
    @canvas.undraw(@id, @kind )

  accelX: -> @vx += @a
  accelY: -> @vy += @a
  decelX: -> @vx -= @a
  decelY: -> @vy -= @a

  #up: -> @vy -= @a
  #down: -> @vy += @a
  
  up: -> @y -= @a
  down: -> @y += @a

class Bat extends Entity
  w: 40
  h: 175
  side: LEFT
  kind: 'bat'

  randColor: ->
    @r = "#{parseInt((Math.random() * 240),10)}"
    @g = "#{parseInt((Math.random() * 240),10)}"
    @b = "#{parseInt((Math.random() * 240),10)}"

  setName: (name) -> @name = name
  getName:  -> @name || "unknown"
  getNameXX:  -> @namexx ||= @getName().replace(/\d\d$/, "XX")
  setSide: (side) ->
    @side = side
    if side is LEFT
      @offsetX = 0
    else
      @offsetX = @maxX

  getSide: -> @side

  draw: ->
    global.io.sockets.emit('mess', message: "drawing bat with id #{@id}")
    super()


class Ball extends Entity
  w: 4, h: 4, x: 20, y: 20, game_over: false
  kind: 'ball'

  checkGameOver: -> @game_over

  checkBoundary: ->
    if @x+@w > @maxX
      @game_over = true
    if @x < @minX
      @game_over = true

    # If we hit the top or the bottom we need to bounce
    @vy = -@vy if @y+@h > @maxY or @y < @minY
  
  checkCollision: (e ) ->
    x = @x + @offsetX
    y = @y + @offsetY
    ex = e.x + e.offsetX
    ey = e.y + e.offsetY
    if y >= ey and y <= ey+e.h
      if e.side is LEFT and x < ex+e.w
        @x += BAT_TERMINAL_VELOCITY / 2
        @vx = -@vx
        e.score_plus_one()
      if e.side is RIGHT and x+@w > ex
        @x -= BAT_TERMINAL_VELOCITY / 2
        @vx = -@vx
        e.score_plus_one()

class PongApp
  main: ->
    @createCanvas()
    @startNewGame()

    @players = {}
    console.log("pong started!")


  move: (from: from, dir: dir) ->
    @newPlayer(from) if not @players[from]
    if dir is "up"
      console.log("moving #{from} up")
      @players[from].up()
    else if dir is "down"
      console.log("moving #{from} down")
      @players[from].down()
    @players[from].draw()

  player_leave: (from: from) ->
    @players[from].undraw()
    delete @players[from]

  newPlayer: (name) ->
    np =  new Bat @canvas, @canvas.width, @canvas.height, 0, 0, 0 , @canvas.height / 2 , BAT_ACCELERATION, BAT_TERMINAL_VELOCITY, BAT_FRICTION
    np.setName(name)
    np.randColor()
    lc = 0
    rc = 0
    count = 0
    for name, p of @players
      count += 1
      if p.getSide() is LEFT then lc += 1 else rc += 1
    if lc > rc
      console.log("setting side RIGHT for #{np.getName()}")
      np.setSide(RIGHT)
    else
      console.log("setting side LEFT for #{np.getName()}")
      np.setSide(LEFT)
    @addPlayer(np)
    height = if count < 3
              @canvas.height / 4
             else if  count < 5
              @canvas.height / 5
             else
              @canvas.height / 6

    for iname, ip of @players
      ip.h = parseInt(height,10)
      ip.draw() # redraw all players

    np

  addPlayer: (player) ->
    @players[player.getName()] = player

  startNewGame: ->

    @ball = new Ball @canvas, @canvas.width, @canvas.height, 0, 0, 0, 0, BALL_ACCELERATION, BALL_TERMINAL_VELOCITY, BALL_FRICTION
    
    @ball.vx = 5
    @ball.vy = 5

    
    @run_game()
  
  run_game: ->
    @interval_id = setInterval =>

      # Update position of players
      p.update() for name,p of @players
      # Update position of ball
      @ball.update()

      # Check for ball collsions with bats
      @ball.checkCollision(p) for name,p of @players
      @ball.draw()

      # Check for winner
      if @ball.checkGameOver()
        @ball.undraw()
        @terminateRunLoop = true
        @notifyCurrentUser "Game Over! Scores:<br/>#{("#{p.getNameXX()}: #{p.getScore()}<br/>" for name, p of @players).join("")}<br/> New game starting in 3 seconds."
        setTimeout =>
          @notifyCurrentUser ''
          @terminateRunLoop = false
          @startNewGame()
        , 3000

      # Run again unless we have been killed
      clearInterval(@interval_id) if @terminateRunLoop
    , 400

  notifyCurrentUser: (message) ->
    # NODE TODO
    #document.getElementById('message').innerHTML = message

  # Run when the game is quit to clean up everything we create
  cleanup: ->
    @terminateRunLoop = true

  # Creates an overlay for the sceen and a canvas to draw the game on
  createCanvas: ->
    @canvas = new Canvas(1000, 1000)



exports.Bat = Bat
exports.PongApp = PongApp
exports.Ball = Ball

# default game
exports.pong = pong = new PongApp
pong.main()


