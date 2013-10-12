everyauth = require("everyauth")
https = require("https")
module.exports = Server = (expressInstance, siteConf) ->
  
  
  # Fetch and format data so we have an easy object with user data to work with.
  normalizeUserData = ->
    handler = (req, res, next) ->
      if req.session and not req.session.user and req.session.auth and req.session.auth.loggedIn
        user = {}
        if req.session.auth.github
          user.image = "http://1.gravatar.com/avatar/" + req.session.auth.github.user.gravatar_id + "?s=48"
          user.name = req.session.auth.github.user.name
          user.auth_id = "github-" + req.session.auth.github.user.id
        if req.session.auth.twitter
          user.image = req.session.auth.twitter.user.profile_image_url
          user.name = req.session.auth.twitter.user.name
          user.auth_id = "twitter-" + req.session.auth.twitter.user.id_str
        if req.session.auth.facebook
          user.image = req.session.auth.facebook.user.picture
          user.name = req.session.auth.facebook.user.name
          user.auth_id = "facebook-" + req.session.auth.facebook.user.id
          
          # Need to fetch the users image...
          https.get(
            host: "graph.facebook.com"
            path: "/me/picture?access_token=" + req.session.auth.facebook.accessToken
          , (response) ->
            user.image = response.headers.location
            req.session.user = user
            next()
          ).on "error", (e) ->
            req.session.user = user
            next()

          return
        req.session.user = user
      next()
    handler

  everyauth.debug = siteConf.debug

  everyauth.everymodule.handleLogout (req, res) ->
    delete req.session.user

    req.logout()
    res.writeHead 303,
      Location: @logoutRedirectPath()

    res.end()

  # Facebook
  if siteConf.external and siteConf.external.facebook
    everyauth.facebook.appId(siteConf.external.facebook.appId).appSecret(siteConf.external.facebook.appSecret).findOrCreateUser((session, accessToken, accessTokenExtra, facebookUserMetaData) ->
      true
    ).redirectPath "/app"
  # Twitter
  if siteConf.external and siteConf.external.twitter
    everyauth.twitter
    .myHostname(siteConf.uri)
    .callbackPath("/auth/twitter/callback")
    .consumerKey(siteConf.external.twitter.consumerKey)
    .consumerSecret(siteConf.external.twitter.consumerSecret)
    .findOrCreateUser((session, accessToken, accessSecret, twitterUser) ->
      true
    ).redirectPath "/app"
  # Github
  if siteConf.external and siteConf.external.github
    everyauth.github.myHostname(siteConf.uri).appId(siteConf.external.github.appId).appSecret(siteConf.external.github.appSecret).findOrCreateUser((session, accessToken, accessTokenExtra, githubUser) ->
      true
    ).redirectPath "/app"
  
  


  everyauth: everyauth
  middleware:
    auth: everyauth.middleware
    normalizeUserData: normalizeUserData
