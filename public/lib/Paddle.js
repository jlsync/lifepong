
var Paddle = function( map, player, style ){

  this.map = map;
  this.setPlayer( player );

  this.style = style || {
    weight: 40,
    color: 'black',
    opacity: 1,
    clickable: false
  }

  this.size = 0.0008; // paddle size (in degrees)
  this.attachToMap();
}

Paddle.prototype.setPlayer = function( player ){
  this.player = player;
  this.player.events.on( 'location', this.moveToPlayerLocation.bind( this ) );
}

Paddle.prototype.moveToPlayerLocation = function( location ){
  if( !this.line ) this.attachToMap( location );
  // console.log( 'this.line', this.line );
  this.line.setLatLngs([
    [ location.latitude - ( this.size / 2 ), location.longitude ],
    [ location.latitude + ( this.size / 2 ), location.longitude ]
  ]);
}

Paddle.prototype.attachToMap = function( location ){
  this.line = L.polyline( [ [ 0, 0 ], [ 0, 0 ] ], this.style ).addTo( this.map );
}