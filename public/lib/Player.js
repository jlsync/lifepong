
var Player = function( name ){
  this.name = name;
  this.events = new EventEmitter();
  this.coords = { latitude: 0, longitude: 0 };
}

Player.prototype.updateLocation = function(){
  var self = this;
  navigator.geolocation.getCurrentPosition(
    function( data ){ self.setCoords( data.coords ); },
    console.error.bind( console, 'location update failed',
                       { enableHighAccuracy: true , timeout: 10, maximumAge: 10 } )
  );
}

Player.prototype.setCoords = function( coords ){
  if( !this.coords || !this.coords.coords ||
      coords.latitude !== this.coords.latitude ||
      coords.longitude !== this.coords.longitude ) {
    this.coords = coords;
    this.events.emit( 'location', this.coords );
  }
}

Player.prototype.pollLocation = function( interval ){
  setInterval( this.updateLocation.bind( this ), interval || 500 );
}
