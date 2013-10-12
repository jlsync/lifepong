
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

var border = [
  [ 51.50045, -0.12760 ],
  [ 51.50045, -0.12580 ],
  [ 51.49995, -0.12580 ],
  [ 51.49995, -0.12760 ],
];

var players = {
  player1: {
    pos: [ 51.5002, -0.1272 ]
  },
  player2: {
    pos: [ 51.5002, -0.1262 ]
  }
}

var map = L.map('map').setView( center.pos, 20 );
L.marker(players.player1.pos).addTo(map).bindPopup("Player1");
L.marker(players.player2.pos).addTo(map).bindPopup("Player2");

L.polygon(border, {color: 'black', fill: false, opacity:1}).addTo(map);

// player 1 paddle
var polyline = L.polyline([
  [ players.player1.pos[0] - 0.00005, players.player1.pos[1] ],
  [ players.player1.pos[0] + 0.00005, players.player1.pos[1] ]
], style.paddle ).addTo(map);

// player 2 paddle
var polyline = L.polyline([
  [ players.player2.pos[0] - 0.00005, players.player2.pos[1] ],
  [ players.player2.pos[0] + 0.00005, players.player2.pos[1] ]
], style.paddle ).addTo(map);


var popup = L.popup();

function onMapClick(e) {
  popup
    .setLatLng(e.latlng)
    .setContent("You clicked the map at " + e.latlng.toString())
    .openOn(map);
}

map.on('click', onMapClick);
