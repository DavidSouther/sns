logger = require "./logger"
fs = require "fs"
coffee = require "coffee-script"
stylus = require "stylus"
jade = require "jade"

# The router servers client assets, running certain asset classes (by extension) through compilers.
# @param {root} string base path (relative to program start root) to find files.
Router = (root = ".")->
	# Helper function to load the text of a file, passing it back to a callback.
	_get = (path, cb)->
		logger.debug "Looking for #{path}"
		try
			fs.readFile path, (err, file)->
				cb file.toString(), err # toString it, since many of the compilers don't like buffers.
		catch err # Something wrong with the read. Save the error for a tick, don't want to get both sync and async behavior.
			process.nextTick ->
				cb "", err

	# General error handler, returning the 404 image when there are problems.
	_404 = (res, err)->
		if err then logger.debug err
		res.status(404).sendfile("#{__dirname}/assets/errors/404.jpg")

	# The router middleware.
	router = (req, res, next)->
		types = router.types # shorthand convenience
		logger.info "Request for #{req.path}"

		# Examine the path, pulling off the extension from the rest of the full path
		[all, path, ext] = req.path.match(/^(.*)\.([^\.\/]+)$/) || ["bad/file.missing", "bad/file", "missing"]

		# If the request is of our rewrite types, and not a vendor file (anything with a vendor folder in its path)
		if types[ext] and not path.match /vendor\//
			# Rewrite the logical location to the actual file path (replace is to truncate multiple file separators.)
			localpath = "#{root}#{path}.#{types[ext].ext}".replace /\/+/, '/'

			_get localpath, (contents, err)->
				if err then return _404 res, err

				logger.debug "Rendering as #{types[ext].mime}"
				try
					# Pass the returned file text to appropriate trasnpiler
					types[ext].compile contents, localpath, (compiled)->
						res.set "Content-Type": types[ext].mime
						res.end compiled
				catch err # The transpiler failed.
					res.status(500).sendfile("#{__dirname}/assets/errors/500.jpg")
					logger.warn "Error compiling #{localpath}"
					logger.debug err
		else
			file = "#{root}/#{all}".replace /\/+/, '/'
			logger.debug "Sending #{file}"
			res.sendfile file, (err)->
				if err then _404 res, err

	router.types =
		js:
			ext: "coffee"
			mime: "text/javascript"
			render: yes
			compile: (file, path, cb)->
				cb coffee.compile file
		css:
			ext: "styl"
			mime: "text/css"
			render: yes
			compile: (file, path, cb)->
				# Pull the directory name out and pull the extension off.
				[all, directory, basename] = path.match(/^(.*)\/([^\/]+)\.[^\.\/]+$/) || ["bad/path.css", "bad", "path"]
				stylus(file)
					.set('filename', "#{directory}/${basename}.css")
					# Tell Stylus where to look for includes
					.set('paths', [root, directory])
					.render (err, css)-> cb css

		html:
			ext: "jade"
			mime: "text/html"
			render: yes
			compile: (file, path, cb)->
				cb jade.compile(file)()

	router

module.exports = Router
