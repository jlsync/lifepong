
Player = require('./player').Player

module.exports = Server = (httpServer, sessionStore, cookieSecret ) ->
  parseSignedCookies = require("connect").utils.parseSignedCookies
  cookie = require('cookie')

  io = require("socket.io").listen(httpServer)
  io.configure ->
    io.set "log level", 0

  io.set "authorization", (handshakeData, ack) ->
    raw_cookies = cookie.parse(decodeURIComponent(handshakeData.headers.cookie))
    cookies = parseSignedCookies(raw_cookies, cookieSecret)

    handshakeData.sid = cookies["connect.sid"] or null

    sessionStore.get cookies["connect.sid"], (err, sessionData) ->
      handshakeData.session = sessionData or {}
      ack err, (if err then false else true)


  io.sockets.on "connection", (client) ->

    new Player(client.id, client)

    client.on 'disconnect', ->
      console.log "socket disconnect connection"



  io.sockets.on "error", ->
    console.log arguments_

  io

