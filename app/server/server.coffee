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

httpServer = http.createServer app

httpServer.listen 13337

Server = class extends (require 'core/Network/Server')

	constructor: ->
		
		super
		
		@timeCounter = new Timing.Counter()
		
	tick: ->
		
		Timing.TimingService.setElapsed @timeCounter.current() / 1000
		
		super
		
server = new Server
	
	type: 'socketIo'
	server: httpServer

server.begin()
