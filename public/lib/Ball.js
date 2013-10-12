
var Ball = function( game, style ){

  this.game = game;
  this.radius = 30;

  this.style = style || {
    fill: true,
    fillColor: 'black',
    fillOpacity: 1,
    stroke: false,
    clickable: false
  }
}

Ball.prototype.moveToLocation = function( location ){
  if( !this.ball ) this.attachToMap( location );
  this.ball.setLatLng([ location.latitude, location.longitude ]);
}

Ball.prototype.attachToMap = function( location ){
  console.log( 'attachToMap', this.game.center );
  this.ball = L.circleMarker( this.game.center, this.style ).setRadius( this.radius ).addTo( this.game.map );
}