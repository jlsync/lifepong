
var Game = function( map ){
  this.events = new EventEmitter();
  this.map = map;
  this.center = [ 0, 0 ];
  this.players = [];
  this.started = false;
  this.maxPlayers = 2;
  this.reset();
}

Game.prototype.reset = function(){
  this.ready = {};
}

Game.prototype.addPlayer = function( player ){
  var self = this;
  player.events.on( 'location', function(){
    self.ready[ player.name ] = true;
    if( Object.keys( self.ready ).length >= self.maxPlayers ){
      self.start();
    }
  });
  self.players.push( player );
}

Game.prototype.start = function(){
  if( !this.started ){
    this.started = true;
    this.center = findCenter( this.players );
    this.map.setView( this.center, 18 );
    var border = new Border( this );
    var ball = new Ball( this );
    this.events.emit( 'start' );
  }
}

function findCenter( players ){
  
  var minLat = minLon = +360;
  var maxLat = maxLon = -360;

  players.forEach( function( player ){
    if( player.coords.latitude < minLat ) minLat = player.coords.latitude;
    if( player.coords.latitude > maxLat ) maxLat = player.coords.latitude;
    if( player.coords.longitude < minLon ) minLon = player.coords.longitude;
    if( player.coords.longitude > maxLon ) maxLon = player.coords.longitude;
  });

  var lat = minLat + (( maxLat - minLat ) / 2);
  var lon = minLon + (( maxLon - minLon ) / 2);
  
  return( [ lat, lon ] );
}