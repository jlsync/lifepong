
var Client = function( game ){
  this.socket = io.connect();
  this.game = game;
}

Client.prototype.bindPlayer = function( player ){

  var self = this;

  // send data upstream to server
  player.events.on( 'location', function( coords ){

    var data = {
      name: player.name,
      lat: coords.latitude,
      lng: coords.longitude
    }

    self.socket.emit( 'my_position', data );
    console.log( 'SEND', data );
  });

  // debugging
  debug( this );

  this.socket.on( 'new_position', console.log.bind( console, 'RECV' ) );

  this.socket.on('broadcast', function(data){console.log("broadcast: " + data.message); }); 
  this.socket.on('mess', function(data){console.log("mess: " + data.message); }); 

  this.socket.on('connect', function(data){console.log("socket:connect"); }); 
  this.socket.on('connecting', function(data){console.log("socket:connecting"); }); 
  this.socket.on('disconnect', function(data){console.log("socket:disconnect"); }); 
  this.socket.on('reconnect', function(data){console.log("socket:reconnect"); }); 
  this.socket.on('reconnecting', function(data){console.log("socket:reconnecting"); }); 
  this.socket.on('error', function(data){console.log("socket:error"); }); 
  this.socket.on('connect_failed', function(data){console.log("socket:connect_failed"); }); 
  this.socket.on('reconnect_failed', function(data){console.log("socket:reconnect_failed"); }); 
}

// h: 125
// id: 1
// kind: "bat"
// lat: "50.30"
// lng: "0.0"
// w: 40

var objects = {};

function debug( client ){
  client.socket.on( 'new_position', function( data ){
    if( !( data.id in objects ) ){
      console.log( 'create new ' + data.kind );
      var Model = ( data.kind == 'bat' ) ? Paddle : Ball;
      objects[ data.id ] = new Model( client.game );
    }
    objects[ data.id ].moveToLocation({ latitude: data.lat, longitude: data.lng });
  });
}
