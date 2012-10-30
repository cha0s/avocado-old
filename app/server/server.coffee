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

consolidate = require 'consolidate'
express = require 'express'
http = require 'http'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

require('./lib/avocadoModules') app

app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.end html

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
	
	socket.on 'entityUpdated', (entity) ->
		
		socket.set 'position', entity.position, ->
			
			entity.id = socket.id
			socket.broadcast.emit 'entityUpdated', entity
