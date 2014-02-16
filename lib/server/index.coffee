logger = require "./logger"
jade = require "jade"
fs = require "fs"

#TODO Replace with nconf
STAGE = 'planet'

module.exports = (app)->
    app.get /^\/([a-zA-Z]*)$/, (r, s)->
        stage = r.params[0] || STAGE
        logger.info "Starting game on stage #{STAGE}"
        fs.readFile "./lib/client/index.jade", (err, file)->
            index = jade.compile file
            html = index({stage})
            s.type 'html'
            s.send 200, html
