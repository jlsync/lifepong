{Connection} = require('./connection')

module.exports = Server = (httpServer, sessionStore, cookieSecret ) ->
  parseSignedCookies = require("connect").utils.parseSignedCookies
  cookie = require('cookie')

  io = require("socket.io").listen(httpServer)
  io.configure ->
    io.set "log level", 0

  io.set "authorization", (handshakeData, ack) ->
    raw_cookies = cookie.parse(decodeURIComponent(handshakeData.headers.cookie))
    cookies = parseSignedCookies(raw_cookies, cookieSecret)

    handshakeData.nuid = raw_cookies["nuid"] or null
    handshakeData.sid = cookies["connect.sid"] or null

    sessionStore.get cookies["connect.sid"], (err, sessionData) ->
      handshakeData.session = sessionData or {}
      ack err, (if err then false else true)


  io.sockets.on "connection", (client) ->
    Connection.connection(client)


  io.sockets.on "error", ->
    console.log arguments_

  io

