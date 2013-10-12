
#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    title: "LifePong", user: req.session?.user


# * GET app page.
exports.app = (req, res) ->
  res.render "app",
    title: "LifePong App"

