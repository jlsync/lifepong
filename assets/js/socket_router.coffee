
$ ->

  window.socket = io.connect()

  socket_defaults(socket)

  socket.on "new_position", (data) ->
    # call some map_up_function(data ...)
    console?.log("got new_position with data", data)

  socket.on 'broadcast', (message: message) ->
    console.log "broadcast: #{message}"

  socket.on 'mess', (message: message) ->
    console.log "message: #{message}"



