
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
}
