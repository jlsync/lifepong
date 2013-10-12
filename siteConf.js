var settings = {
	'cookieSecret': 'lifePong_cookie_secret'
	, 'port': 8080
	, 'uri': 'http://local.host:8080' // Without trailing /
  , 'mongoUrl': 'mongodb://localhost/pbid'

	// You can add multiple recipiants for notifo notifications
	, 'notifoAuth': null /*[
		{
			'username': ''
			, 'secret': ''
		}
	]*/

	, 'external': {
		 'twitter': {
      // local.host:8080
			consumerKey: '9EVsAL0C8ktXRUebb5I5hw',
			consumerSecret: '8ZgpyOZAJuBDxqcLLS56Y6D94NS3Q4gk7A3H4Ttlo'
		}
	}

	, 'debug': (process.env.NODE_ENV !== 'production')

};

if (process.env.NODE_ENV == 'production') {
	settings.uri = 'http://www.lifepong.com';
	//settings.mongoUrl = 'mongodb://localhost/pbid_production'
	settings.port = process.env.PORT || 80; // Joyent SmartMachine uses process.env.PORT

  // xxxx.heroku.com
  settings.external.twitter.consumerKey = 'TODO';
  settings.external.twitter.consumerSecret =  'TODO';

	//settings.airbrakeApiKey = '0190e64f92da110c69673b244c862709'; // Error logging, Get free API key from https://airbrakeapp.com/account/new/Free
}

module.exports = settings;
