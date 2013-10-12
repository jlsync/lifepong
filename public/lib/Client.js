
var Client = function(){
  this.socket = io.connect( 'http://localhost' );
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
