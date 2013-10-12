
var Border = function( game, style ){

  this.game = game;
  this.padding = 0.0001;
  this.style = style || {
    color: 'black',
    fill: false,
    opacity: 1
  }

  this.attachToMap();
}

Border.prototype.getCoords = function(){
  var bounds = this.game.map.getBounds();
  // console.log( 'bounds', bounds );
  return [
    [ bounds.getNorth() - this.padding, bounds.getWest() + this.padding ],
    [ bounds.getSouth() + this.padding, bounds.getWest() + this.padding ],
    [ bounds.getSouth() + this.padding, bounds.getEast() - this.padding ],
    [ bounds.getNorth() - this.padding, bounds.getEast() - this.padding ],
  ];
}

Border.prototype.attachToMap = function(){
  this.poly = L.polygon( this.getCoords(), this.style ).addTo( this.game.map );
}