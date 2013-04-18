_ = require "underscore"
_.mixin
	omap: (obj, fn)->
		nobj = {}
		nobj[name] = fn(val) for name, val of obj
		nobj

nconf = require "nconf"
nconf.defaults
	level: 'info'
	logdir: '' # If empty, don't log to files, otherwise log to files in this directory
	logfile: 'sns'
	maxsize: 2097152 # 2MB files
	maxfiles: 20

config = 
	trace: [0,  "cyan"]
	debug: [10, "blue"]
	info:  [20, "green"]
	warn:  [30, "yellow"]
	error: [40, "red"]

levels = _(config).omap (config)-> config[0]
colors = _(config).omap (config)-> config[1]

winston = require "winston"
winston.addColors colors

level = nconf.get "level"
logdir = nconf.get "logdir"

logger = new winston.Logger levels: levels
logger.add winston.transports.Console, {level: level, colorize: true, timestamp: true}
logger.add winston.transports.File, {level: level, colorize: false, timestamp: true, maxsize: maxsize, maxFiles: maxfiles} unless not logdir

module.exports = logger
