
express = require('express')
app = express.createServer()
global.io = require('socket.io').listen(app)
_ = require('underscore')._
Deck = require('./deck').Deck
StateMachine = require('./sm').StateMachine
Player = require('./player').Player

#app.register '.coffee', require('coffeekup')
app.register '.ejs', require('ejs')
#app.set 'view engine', 'coffee'


app.use express.logger()
#app.use express.profiler()
app.use express.cookieParser()
session_store  = new express.session.MemoryStore()
app.use express.session({ store: session_store, secret: 'somethingSecreT-lixDfs773', cookie: { path: '/', httpOnly: false, maxAge: 14400000 } })
app.use express.static(__dirname + '/public')

last_used_id = 1
next_free_id = ->
  last_used_id += 1

app.get '^/$', (req, res) ->
  req.session.user_id ?= next_free_id()
  res.render 'index.ejs', layout: 'bland_layout'

app.get '^/game$', (req, res) ->
  req.session.user_id ?= next_free_id()
  res.render 'game.ejs'

app.get '^/track', (req, res) ->
  req.session.user_id ?= next_free_id()
  res.render 'track.ejs', layout: 'track_layout'

app.get '^/plot', (req, res) ->
  res.render 'plot.ejs', layout: 'plot_layout'

port = process.env.PORT || 3456

app.listen(port)

client_worker = (client) ->
  #console.log 'client', client

  client.on 'session', (sid: sid) ->
    console.log "GOT SID: #{sid} from: #{client.id}"
    session_store.get sid, (error, session) ->
      console.log 'found session is ', session
      if !session?
        console.log 'Session not found. error', error
        client.emit 'broadcast', message: "your session not found. #{error}"
        return
      session.pings = (session.pings || 0 ) + 1
      client.emit 'broadcast', message: "You have made #{session.pings} pings."


      if session.player_id and Player.collection.get(session.player_id)
        client.player = Player.collection.get session.player_id
        console.log "Reconnected player_id #{session.player_id} user_id #{client.player.user_id}"
        client.player.new_client client
      else
        client.player = new Player(session.user_id, client)
        session.player_id = client.player.id
        console.log "Created new player_id #{session.player_id} user_id #{session.user_id}"
        session_store.set(sid, session) # save the session

      client.broadcast.emit 'broadcast', message: "#{client.player.user_id} has connected"
      client.emit 'broadcast', message: "You have connected"

  client.on 'mess', (message: message) ->
    console.log "got message: #{message} from: #{client.id}"
    client.broadcast.emit 'broadcast', message: "#{client.id} says #{message}"

  client.on 'trigger', (data) ->
    console.log "got #{client.id} trigger: ", data
    client.player.sm.trigger data.trigger, data

  client.on 'position', (data) ->
    console.log "position from #{client.id}: ", data

  client.on 'disconnect', ->
    #client.player.sm.trigger('logout') # really need to set a timer
    client.broadcast.emit 'broadcast', message: "#{client.player?.user_id} has disconnected"

# heroku apps:config HEROKU=true
# heroku apps:config NODE_ENV=production
if process.env.HEROKU
  true
  # io.configure 'production', ->
  #  io.set("transports", ["xhr-polling"])
  #  io.set("polling duration", 10)


io.sockets.on 'connection', client_worker

