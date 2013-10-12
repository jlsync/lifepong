
#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    title: "LifePong", user: req.session?.user


# * GET app page.
exports.app = (req, res) ->
  #if req.session?.user?
  #  res.render "app",
  #    title: "LifePong App"
  #else
  #  res.render "login",
  #    title: "LifePong Login"
  res.render "app",
    title: "LifePong App"

