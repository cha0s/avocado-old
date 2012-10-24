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
require 'core/CoreService'

require 'core/Graphics/GraphicsService'
require 'core/Graphics/Font'
require 'core/Graphics/Image'
require 'core/Graphics/Window'

require 'core/Sound/Music'
require 'core/Sound/Sample'

require 'core/Timing/TimingService'
require 'core/Timing/Counter'

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

express = require 'express'
http = require 'http'

app = express()

app.get '/', (req, res) ->
	res.send 'Hello!<script src="/socket.io/socket.io.js"></script>'
  
server = http.createServer app

server.listen 1337

io = require('socket.io').listen server

io.sockets.on 'connection', (socket) ->

	socket.emit 'greeting', hello: 'world'
	
	socket.on 'load environment', ({uri}) ->
		console.log uri
