
var Paddle = function( game, style ){

  this.game = game;

  this.style = style || {
    weight: 15,
    color: 'black',
    opacity: 1,
    clickable: false,
    smoothFactor: 0.4,
    noClip: true
  }

  this.size = 0.0002; // paddle size (in degrees)
}

Paddle.prototype.setPlayer = function( player ){
  this.player = player;
  this.player.events.on( 'location', this.moveToLocation.bind( this ) );
}

Paddle.prototype.moveToLocation = function( location ){
  if( !this.line ) this.attachToMap( location );
  this.line.setLatLngs([
    [ location.latitude - ( this.size / 2 ), location.longitude ],
    [ location.latitude + ( this.size / 2 ), location.longitude ]
  ]);
}

Paddle.prototype.attachToMap = function( location ){
  this.line = L.polyline( [ [ 0, 0 ], [ 0, 0 ] ], this.style ).addTo( this.game.map );
}
