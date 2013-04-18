nconf = require("nconf")

defaults =
	replify: false
	livereload: false

nconf.file("./ini.json").defaults(defaults)

logger = require("./logger")

if nconf.get "replify"
	try
		require("replify")(name: 'debugger', path: './.replify')
	catch err
		logger.warn "Couldn't start replify (did you install dev-dependencies?)."
		logger.debug err

if nconf.get "livereload"
	try
		lr = require("livereload")
		lrs = lr.createServer debug: yes, exts: ['jade', 'coffee', 'styl', 'png']
		lrs.watch "#{__dirname}/../client"
	catch err
		logger.warn "Couldn't start livereload (did you install dev-dependencies?)."
		logger.debug err