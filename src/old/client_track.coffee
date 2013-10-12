
$ ->

  $positions = $('<div id="positions"/>').appendTo('body')

  reportSuccess = (position) ->
    socket.emit 'position', position
    $positions.prepend("<p> timenow: #{(new Date()).toString()} timestamp: #{(new Date(position.timestamp)).toString()}<br/>
      position: lat: #{position.coords.latitude} , lng: #{position.coords.longitude}, accuracy: #{position.coords.accuracy}m , heading: #{position.coords.heading}degrees , speed: #{position.coords.speed}m/s </p>")

   reportError = (error) ->
    $positions.prepend("<p> timenow: #{(new Date()).toString()} error  code: #{error.code}, message: #{error.message}<p/>")

  reportLocation = ->
    navigator.geolocation.getCurrentPosition(reportSuccess, reportError, enableHighAccuracy: true , timeout: 10, maximumAge: 10 )

  window.socket = io.connect()

  #setInterval reportLocation, 10000
  watchid = navigator.geolocation.watchPosition(reportSuccess, reportError, enableHighAccuracy: true , timeout: 10, maximumAge: 10 )

  setTimeout ->
    navigator.geolocation.clearWatch watchid
  , 1000 * 60 * 2

  $flash = $('#flash')
  if !$flash[0]?
    $flash = $('<div id="flash"/>')
    $flash.appendTo('body')

  socket.on 'connect', -> $flash.text 'connected!'

  socket.on 'broadcast', (message: message) ->
    console.log "broadcast: #{message}"
    $flash.text "broadcast: #{message}"

  socket.on 'mess', (message: message) ->
    console.log "message: #{message}"
    $flash.text "message: #{message}"

