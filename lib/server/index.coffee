logger = require "./logger"
jade = require "jade"

index = jade.compile "./lib/client/index.jade"

require("fs").readFile "./lib/client/index.jade", (err, file)->
	index = jade.compile file

#TODO Replace with nconf
STAGE = 'planet'

module.exports = (app)->
	app.get /^\/([a-zA-Z]*)$/, (r, s)->
		stage = r.params[0] || STAGE
		logger.info "Starting game on stage #{STAGE}"
		html = index({stage})
		s.type 'html'
		s.send 200, html
