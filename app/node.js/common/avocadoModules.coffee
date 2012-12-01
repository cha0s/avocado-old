_ = require 'core/Utility/underscore'
coffee = require 'coffee-script'
fs = require 'fs'
helpers = require './helpers'
mustache = require 'mustache'

rootPath = '../../..'

module.exports = (app) ->
	
	# Build the list of core files. We'll generate script tags for each to
	# send to the client.
	app.locals.coreFiles = _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/core", "/engine/core"
		(filename) -> src: filename.replace '../../..', ''
	)
	
	# Build the list of bindings. We'll generate script tags for each to
	# send to the client.
	app.locals.bindingFiles = _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/main/web/Bindings", "/engine/main/web/Bindings"
		(filename) -> src: filename.replace '../../..', ''
	)
	
	# Automatically stream any coffeescript files requested as JS.
	app.get /\/[^/]*\.coffee$/, (req, res, next) ->
		
		# Make sure the file exists.
		filename = "#{rootPath}#{req._parsedUrl.pathname}"
		fs.exists filename, (exists) ->
			return res.status(404).end 'File Not Found' unless exists
			
			# Read it.
			fs.readFile filename, 'UTF-8', (error, code) ->
				throw error if error
				
				# If the original coffeescript was requested, end the request
				# with its return.
				if req.query.original?
					res.type 'application/coffeescript'
					res.end code
					
				# Otherwise, process the coffeescript and continue the request.
				else
					
					res.type 'application/javascript'
					
					try
						req.processedCode = coffee.compile code
					catch e
						throw new Error "Failed compiling #{filename}: #{e.stack}"
					
					next()
	
	helpers.serveModuleFiles(
		app
		resourcePath
		rootPath
		'/engine/'
	) for resourcePath in [
		/^\/engine\/core\/.*/
		/^\/engine\/main\/web\/Bindings\/.*/
	]
	
	config =
		'Network.coffee': {}
			
	# Write configuration variables.
	app.get /^\/engine\/core\/Config\/:filename/, (req, res, next) ->
		
		switch filename = req.params.filename
			
			when 'Network.coffee'
				config[filename].hostname = "http://#{req.headers.host}"
				
			else
				return next()
				
		req.processedCode = mustache.to_html(
			req.processedCode
			config[filename]
		)
		
		next()
	
