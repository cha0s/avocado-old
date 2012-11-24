_ = require 'core/Utility/underscore'
coffee = require 'coffee-script'
fs = require 'fs'
helpers = require './helpers'
mustache = require 'mustache'
path = require 'path'
upon = require 'core/Utility/upon'

rootPath = '../../..'

module.exports = (app) ->
	
	# Build the list of core files. We'll generate script tags for each to
	# send to the client.
	app.locals.coreFiles = _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/core", "/engine/core"
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
					res.type 'text/coffeescript'
					res.end code
					
				# Otherwise, process the coffeescript and continue the request.
				else
					
					res.type 'text/javascript'
					req.processedCode = coffee.compile code
					next()
	
	# Derive the module name from the filename. e.g.:
	#     avocado> moduleNameFromFilename '/foo/bar/engine/core/CoreService.coffee'
	#     'core/CoreService'
	moduleNameFromFilename = (filename) ->
	
		moduleName = filename.substr "#{rootPath}/engine/".length
		moduleName = "#{path.dirname moduleName}/#{path.basename moduleName, path.extname moduleName}"
		
	# Wrap core files so they can be require()'d.
	app.get /(^\/engine\/core\/.*|^\/engine\/main\/web\/Bindings\/.*)/, (req, res, next) ->
		
		defer = upon.defer()
		
		# Derive the module name from the filename.
		filename = "#{rootPath}#{req._parsedUrl.pathname}"
		moduleName = moduleNameFromFilename filename
		
		# If the code has already been processed, pass it right along.
		if req.processedCode
			defer.resolve req.processedCode
			
		# Otherwise, it still needs to be loaded; do so.
		else
		
			# First make sure it exists.
			fs.exists filename, (exists) ->
				return res.status(404).end 'File Not Found' unless exists
				
				# Pass along the code.
				fs.readFile "#{rootPath}#{req.url}", 'UTF-8', (error, code) ->
					throw error if error
					defer.resolve code
			
		# Wrap the code to make it accessible to the module system.
		defer.then (code) ->
			req.processedCode = "requires_['#{moduleName}'] = function(module, exports) {\n#{code}\n}\n"
			next()
			
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
			
	# Catch-all. Actually send any processed code we've handled.
	app.get /.*/, (req, res, next) ->
		
		if req.processedCode
			res.end req.processedCode
			
		else
			next()
		
	
