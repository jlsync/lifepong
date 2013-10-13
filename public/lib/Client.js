
var Client = function( game ){
  this.game = game;
  this.socket = io.connect();
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
  debug( self );

  // self.socket.on( 'new_position', console.log.bind( console, 'RECV' ) );

  self.socket.on('broadcast', function(data){console.log("broadcast: " + data.message); }); 
  self.socket.on('mess', function(data){console.log("mess: " + data.message); }); 

  self.socket.on('connect', function(data){console.log("socket:connect"); }); 
  self.socket.on('connecting', function(data){console.log("socket:connecting"); }); 
  self.socket.on('disconnect', function(data){console.log("socket:disconnect"); }); 
  self.socket.on('reconnect', function(data){console.log("socket:reconnect"); }); 
  self.socket.on('reconnecting', function(data){console.log("socket:reconnecting"); }); 
  self.socket.on('error', function(data){console.log("socket:error"); }); 
  self.socket.on('connect_failed', function(data){console.log("socket:connect_failed"); }); 
  self.socket.on('reconnect_failed', function(data){console.log("socket:reconnect_failed"); }); 
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

    console.log( ('<'+data.kind+'>').toUpperCase(), data );
    
    if( !( data.id in objects ) ){
      var Model = ( data.kind == 'bat' ) ? Paddle : Ball;
      objects[ data.id ] = new Model( client.game );
    }
    objects[ data.id ].moveToLocation({
      latitude: parseFloat(data.lat),
      longitude: parseFloat(data.lng)
    });
  });
}
