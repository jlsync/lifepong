
var Ball = function( game, style ){

  this.game = game;
  this.radius = 30;

  this.style = style || {
    fill: true,
    fillColor: 'black',
    fillOpacity: 1,
    stroke: false
  }

  this.attachToMap();
}

Ball.prototype.attachToMap = function( location ){
  this.ball = L.circleMarker( this.game.center, this.style ).setRadius( this.radius ).addTo( this.game.map );
}