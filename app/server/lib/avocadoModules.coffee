_ = require 'core/Utility/underscore'
coffee = require 'coffee-script'
fs = require 'fs'
helpers = require './helpers'
mustache = require 'mustache'
path = require 'path'
upon = require 'core/Utility/upon'

module.exports = (app) ->
	
	# Build the list of core files. We'll generate script tags for each to
	# send to the client.
	app.locals.coreFiles = _.map(
		helpers.gatherFilesRecursive "../../engine/core", "/engine/core"
		(filename) -> src: filename.replace '../..', ''
	)
	
	# Automatically stream any coffeescript files requested as JS.
	app.get /\/[^/]*\.coffee$/, (req, res, next) ->
		
		filename = "../..#{req._parsedUrl.pathname}"
		
		next() unless filename.match /\/[^/]*\.coffee$/
		
		res.type 'text/javascript'
		
		fs.exists filename, (exists) ->
			
			return res.status(404).end 'File Not Found' unless exists
				
			fs.readFile filename, 'UTF-8', (error, code) ->
				throw error if error
				
				if req.query.original?
					
					res.end code
					
				else
					
					req.processedCode = coffee.compile code
					next()
	
	# Wrap core files so they can be require()'d.
	app.get /(^\/engine\/core\/.*|^\/engine\/main\/web\/Bindings\/.*)/, (req, res, next) ->
		
		filename = "../..#{req._parsedUrl.pathname}"
		key = filename.substr 13
		key = "#{path.dirname key}/#{path.basename key, path.extname key}"
		
		defer = upon.defer()
		
		if req.processedCode
			
			defer.resolve req.processedCode
			
		else
		
			fs.exists filename, (exists) ->
				
				return res.status(404).end 'File Not Found' unless exists
				
				fs.readFile "../..#{req.url}", 'UTF-8', (error, code) ->
					throw error if error
					
					defer.resolve code
			
		defer.then (code) ->
		
			req.processedCode = "requires_['#{key}'] = function(module, exports) {\n#{code}\n}\n"
			
			next()
			
	config =
		'Network.coffee': {}
			
	# Write configuration variables.
	app.get /^\/engine\/core\/Config\/.*/, (req, res, next) ->
		
		filename = "#{req._parsedUrl.pathname}"
		
		key = filename.split('/')[4]
		switch key
			
			when 'Network.coffee'
				
				config[key].hostname = "http://#{req.headers.host}"
				
			else
				
				return next()
				
		req.processedCode = mustache.to_html req.processedCode, config[key]
		
		return next()
		
		key = filename.substr 13
		key = "#{path.dirname key}/#{path.basename key, path.extname key}"
		
		defer = upon.defer()
		
		if req.processedCode
			
			defer.resolve req.processedCode
			
		else
		
			fs.exists filename, (exists) ->
				
				return res.status(404).end 'File Not Found' unless exists
				
				fs.readFile "../..#{req.url}", 'UTF-8', (error, code) ->
					throw error if error
					
					defer.resolve code
			
		defer.then (code) ->
		
			req.processedCode = "requires_['#{key}'] = function(module, exports) {\n#{code}\n}\n"
			
			next()
			
	# Catch-all. Actually send any processed code we've handled.
	app.get /.*/, (req, res, next) ->
		
		if req.processedCode
			
			res.end req.processedCode
			
		else
			
			next()
		
	
