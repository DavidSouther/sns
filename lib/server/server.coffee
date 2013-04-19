nconf = require "nconf"
nconf.defaults port: 8000

logger = require "./logger"
express = require "express"
assets = require "./assets"

app = express()

# Always get to a valid compilable file
app.get '/', (r, s)-> s.redirect 302, '/index.html'

# HACK for plugins.
app.get '/text.js', (r, s)-> s.sendfile './lib/client/vendor/text.js'

# Compile (or serve) any file
app.use assets "./lib/client"

module.exports =
	serve: ->
		port = nconf.get "port"
		app.listen port
		logger.info "SNS started at http://localhost:#{port}"
