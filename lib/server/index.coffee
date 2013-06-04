logger = require "./logger"
jade = require "jade"

fs = require("fs")

#TODO Replace with nconf
STAGE = 'planet'

module.exports = (app)->
	app.get /^\/([a-zA-Z]*)$/, (r, s)->
		stage = r.params[0] || STAGE
		logger.info "Starting game on stage #{STAGE}"
		# Recompile on every request, since we edit it.
		fs.readFile "./lib/client/index.jade", (err, file)->
			html = jade.compile(file)({stage})
			s.type 'html'
			s.send 200, html
