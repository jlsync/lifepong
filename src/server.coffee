

siteConf = require(global.__root + '/siteConf.js')
express = require("express")
routes = require("./routes")
#cons = require 'consolidate' 
http = require("http")
path = require("path")
moment = require('moment')
app = express()
httpServer = http.createServer(app)
authentication = new require("./authentication")(app, siteConf)

#RedisStore = require("connect-redis")(express)
#sessionStore = new RedisStore
sessionStore = new express.session.MemoryStore()



global.io = new require("./socket-io-server")(httpServer, sessionStore, siteConf.cookieSecret)


{pong, Bat, PongApp, Ball} = require("./pong")

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", global.__root + "/views"
  app.set 'view engine', 'jade'
  #app.set 'view engine', 'haml'
  #app.engine '.haml', cons['haml-coffee']
  #app.engine '.haml', require('haml-coffee').__express
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser(siteConf.cookieSecret)
  app.use express.session({store: sessionStore})
  app.use require('connect-assets')()
  app.use authentication.middleware.auth(app)  # pass in app to get helpers
  app.use authentication.middleware.normalizeUserData()
  app.use app.router
  app.use require("less-middleware")(src: global.__root + "/public")
  app.use express.static(path.join(global.__root, "public"))

app.configure "development", ->
  app.use express.errorHandler()
  app.set "port", siteConf.port

app.use '/', express.static app.get('baseDir') + '/public'
app.get "/app", routes.app
app.use '/*', express.static app.get('baseDir') + '/public'

pid = setInterval ->
    io.sockets.emit('ping', packet: "ping at #{moment().toString()}")
  , 30 * 1000


httpServer.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")




