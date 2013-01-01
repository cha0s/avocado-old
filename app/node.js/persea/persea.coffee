
_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
express = require 'express'
helpers = require '../common/helpers'
http = require 'http'
Models = require './lib/server/Models'
mongoose = require 'mongoose'
path = require 'path'
somber = require './lib/server/somber'

mongoose.connect 'mongodb://localhost/persea'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

require('../common/process-sources') app, "../../.."

helpers.serveModuleFiles(
	app
	resourcePath
	'../../..'
	'/app/node.js/persea/lib/client/'
) for resourcePath in [
	/^\/app\/node.js\/persea\/lib\/client\/.*/
]

somber.express app, Models

# Catch-all. Actually send any processed code we've handled.
app.get /.*/, (req, res, next) ->
	
	if req.processedCode
		type = express.mime.lookup req._parsedUrl.pathname
		unless res.getHeader 'content-type'
			charset = express.mime.charsets.lookup type
			res.setHeader(
				'Content-Type'
				type + (if charset then "; charset=#{charset}" else '')
			)
	
		res.end req.processedCode
		
	else
		next()
	
app.get '/', (req, res) ->
	
	fileLists = require('../common/file-lists')()
	
	locals =
		perseaFiles: helpers.gatherFilesRecursiveSync('./lib/client').map (filename) ->
			src: filename.replace './lib/client', '/app/node.js/persea/lib/client'
		coreFiles: fileLists.coreFiles
		bindingFiles: fileLists.bindingFiles
	
	res.render 'index', locals, (error, html) ->
		
		res.end html

app.use express.static '../../..'

httpServer = http.createServer app
httpServer.listen 13338

db = mongoose.connection

db.on 'error', console.error.bind console, 'connection error:'

db.once 'open', ->

	io = require('socket.io').listen httpServer
	
	ioSettings =
		
		'log level': 1
		'transports': [
			'websocket'
			'flashsocket'
			'htmlfile'
			'xhr-polling'
			'jsonp-polling'
		]
	
	io.set key, value for key, value of ioSettings
	
	io.sockets.on 'connection', (socket) ->
		
		somber.socket socket, Models
