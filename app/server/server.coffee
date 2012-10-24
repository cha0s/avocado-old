coffee = require 'coffee-script'

# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml', '../..'
Core.coreService = new Core.CoreService()
Core.CoreService.setEngineRoot '../../engine'
Core.CoreService.setResourceRoot '../../resource'

# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml', '../..'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml', '../..'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml', '../..'
Sound.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

Logger = require 'core/Utility/Logger'

# Register a stderr logging strategy.
Logger.registerStrategy (message, type) ->
	
	# Colors for the console.
	colors =
	
		error : '\x1B[1;31m'
		warn  : '\x1B[1;33m'
		info  : '\x1B[1;32m'
		reset : '\x1B[0m'
		
	# TYPE:
	Core.CoreService.writeStderr "#{
		colors[type]
	}#{
		type.toUpperCase()
	}#{
		colors.reset
	}:"
	
	# message
	Core.CoreService.writeStderr message

_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
express = require 'express'
fs = require 'fs'
http = require 'http'
path = require 'path'
upon = require 'core/Utility/upon'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

gatherFilesRecursive = (abs, rel) ->
	
	coreFiles = []
	
	for candidate in fs.readdirSync abs
		
		absPath = "#{abs}/#{candidate}"
		relPath = "#{rel}/#{candidate}"
		
		stats = fs.statSync absPath
		
		if stats.isDirectory()
			
			coreFiles = coreFiles.concat gatherFilesRecursive(
				absPath
				relPath
			)
			
		else
			
			extension = path.extname absPath
			if _.contains ['.js', '.coffee'], extension
				
				coreFiles.push
					
					type: switch extension
						when '.coffee' then 'coffeescript'
						when '.js' then 'javascript'
					src: relPath
	
	coreFiles

app.locals.coreFiles = gatherFilesRecursive "../../engine/core", "/engine/core"

app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.send html

# Wrap core JS.
app.get /(^\/engine\/core\/.*|^\/engine\/main\/web\/Bindings\/.*)/, (req, res) ->
	
	fs.readFile "../..#{req.url}", 'UTF-8', (error, code) ->
		
		throw error if error
		
		key = req.url.substr 8
		
		if '.coffee' is path.extname req.url
			code = coffee.compile code
			module = path.basename key, '.coffee'
		else
			module = path.basename key, '.js'
			
		key = "#{path.dirname key}/#{module}"
		
		res.end "requires_['#{key}'] = function(module, exports) {\n#{code}\n}\n"

# Translate .coffee to .js
app.get /.*\.coffee/, (req, res) ->
	
	fs.readFile "../..#{req.url}", 'UTF-8', (error, code) ->
		
		throw error if error
		
		res.end coffee.compile code
		
app.use express.static '../..'

server = http.createServer app

server.listen 13337

io = require('socket.io').listen server

io.sockets.on 'connection', (socket) ->
	
	console.log socket.id
	
	for client in io.sockets.clients()
		continue if client is socket
		
		client.get 'position', (err, position) ->
			
			position ?= [150, 150]
			socket.emit 'entityAdded',
				id: client.id
				traits: [
					type: 'Existence'
					state:
						x: position[0]
						y: position[1]
				]
	
	socket.broadcast.emit 'entityAdded',
		id: socket.id
		traits: [
			type: 'Existence'
			state:
				x: 150
				y: 150
		]
	
#	setTimeout(
#		->
#			socket.emit 'entityAdded', traits: [
#				type: 'Existence'
#				state:
#					x: 150
#					y: 150
#			]
#			
#		5000
#	)

	socket.on 'entityUpdated', (entity) ->
		
		socket.set 'position', entity.position, ->
			
			entity.id = socket.id
			socket.broadcast.emit 'entityUpdated', entity
