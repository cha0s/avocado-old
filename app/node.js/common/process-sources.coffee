_ = require 'core/Utility/underscore'
coffee = require 'coffee-script'
fs = require 'fs'
helpers = require './helpers'
less = require 'less'
mustache = require 'mustache'
util = require 'util'

module.exports = (
	app
	rootPath = '../../..'
) ->
	
	# Build the list of core files. We'll generate script tags for each to
	# send to the client.
	app.locals.coreFiles = _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/core", "/engine/core"
		(filename) -> src: filename.replace rootPath, ''
	)
	
	# Build the list of bindings. We'll generate script tags for each to
	# send to the client.
	app.locals.bindingFiles = _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/main/web/Bindings", "/engine/main/web/Bindings"
		(filename) -> src: filename.replace rootPath, ''
	)
	
	helpers.preprocessFiles(
		app
		/\/[^/]*\.coffee$/
		rootPath
		{
			original: 'text/coffeescript'
			processed: 'text/javascript'
		}
		(req, res, next, code, pathname) ->
			
			try
				
				req.processedCode = coffee.compile code
				
			catch e
				
				req.processedCode = "
				console.log('Coffee compiler couldn\\'t compile #{pathname}! Reason given: #{(util.inspect e).replace /'/g, "\\'"}');
				"
				
			next()
	)
	
	helpers.preprocessFiles(
		app
		/\/[^/]*\.less$/
		rootPath
		{
			original: 'text/less'
			processed: 'text/css'
		}
		(req, res, next, code) ->
			less.render code, (e, css) ->
				req.processedCode = css
				next()
	)
	
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
	
