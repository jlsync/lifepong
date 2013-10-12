
PB = window.PB ||= {}

# set the unique 'connection' cookie  used to identify re-connects
unless $.cookie('nuid')?
  $.cookie('nuid', window.nuid() , { path: '/' })

window.socket ?= io.connect()

socket_defaults(socket)

socket.on "user_entered", (data) ->
  #TODO add to model/collection
  # bind UI to model/collection events
  console?.log("got user_entered", data)

socket.on "user_left", (data) ->
  console?.log("got user_left", data)

socket.on "viewer_entered", (data) ->
  console?.log("got viewer_entered", data)

socket.on "viewer_left", (data) ->
  console?.log("got viewer_left", data)


socket.on "ping", (data) ->
  console?.log("got ping at #{(new Date()).toString()}: #{data.packet}")


socket.on "new_position", (data) ->
  # call some map_up_function(data ...)
  console?.log("got new_position with data", data)

socket.on "connect", ->
  socket.emit('list_games')

  $("#status").removeClass("offline").addClass("online").text "You are online and can play."

socket.on "disconnect", ->
  $("#status").removeClass("online").addClass("offline").text "You are offline. please wait..."


