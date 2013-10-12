
var center = {
  pos: [ 51.5002, -0.1267 ]
}

var style = {
  paddle: {
    weight: 20,
    color: 'black',
    opacity: 1,
    noClip: true,
    'stroke-linecap': 'butt'
  }
}

// var border = [
//   [ 51.50045, -0.12760 ],
//   [ 51.50045, -0.12580 ],
//   [ 51.49995, -0.12580 ],
//   [ 51.49995, -0.12760 ],
// ];

var players = {
  player1: {
    pos: [ 51.5002, -0.1272 ]
  },
  player2: {
    pos: [ 51.5002, -0.1262 ]
  }
}

// Nokia.normalDay
// Nokia.normalGreyDay
// Nokia.satelliteNoLabelsDay
// Nokia.satelliteYesLabelsDay
// Nokia.terrainDay

var map = L.map('map', { zoomControl:false, zoom: 18, maxZoom: 20 } );

// setTimeout( map.setView.bind( map, center.pos, 20 ), 1000 );

// nokia maps
L.tileLayer.provider('Nokia.terrainDay', {
  devID: 'pT52rESblK2luN6D0562LQ',
  appId: 'yKqVsh6qFoKdZQmFP2Cn'
}).addTo(map);

// player markers
// L.marker(players.player1.pos).addTo(map).bindPopup("Player1");
// L.marker(players.player2.pos).addTo(map).bindPopup("Player2");

// border
// L.polygon(border, {color: 'black', fill: false, opacity:1}).addTo(map);

// player 1 paddle
// var polyline = L.polyline([
//   [ players.player1.pos[0] - 0.00005, players.player1.pos[1] ],
//   [ players.player1.pos[0] + 0.00005, players.player1.pos[1] ]
// ], style.paddle ).addTo(map);

// player 2 paddle
// var polyline = L.polyline([
//   [ players.player2.pos[0] - 0.00005, players.player2.pos[1] ],
//   [ players.player2.pos[0] + 0.00005, players.player2.pos[1] ]
// ], style.paddle ).addTo(map);

// console.log( 'line', polyline );

// setInterval( function(){

//   var current = polyline.getLatLngs();

//   polyline.setLatLngs([
//     [ current[0].lat + 0.00001, current[0].lng ],
//     [ current[1].lat + 0.00001, current[1].lng ]
//   ]);

// }, 500 );

// console.log( polyline.getLatLngs() );


var popup = L.popup();

function onMapClick(e) {
  popup
    .setLatLng(e.latlng)
    .setContent("You clicked the map at " + e.latlng.toString())
    .openOn(map);
}

map.on('click', onMapClick);


// Start centered on london
this.map.setView( [ 51.5072, 0.1275 ], 10 );

var p1 = new Player( 'peter' );
var p2 = new Player( 'computer' );

var paddle1 = new Paddle( map, p1 );
var paddle2 = new Paddle( map, p2 );

var game = new Game( map );
game.addPlayer( p1 );
game.addPlayer( p2 );

// set player coords
// p1.pollLocation( 1000 );
p1.setCoords({
  latitude: 51.5045,
  longitude: -0.0225
});
p2.setCoords({
  latitude: 51.5045,
  longitude: -0.016
});

// p1.events.on( 'location', console.log.bind( console ) );