# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml', '../../..'
Core.coreService = new Core.CoreService()
Core.CoreService.setEngineRoot '../../../engine'
Core.CoreService.setResourceRoot '../../../resource'

# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml', '../../..'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml', '../../..'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml', '../../..'
Sound.soundService = new Sound.SoundService()

GlobalConfig = require 'core/GlobalConfig'

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = GlobalConfig.SERVER_PACKET_INTERVAL
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

Logger = require 'core/Utility/Logger'

# Register a stderr logging strategy.
Logger.registerStrategy Logger.stderrStrategy

consolidate = require 'consolidate'
express = require 'express'
http = require 'http'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

require('../common/avocadoModules') app

app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.end html

app.use express.static __dirname + '/../../..'

httpServer = http.createServer app
httpServer.listen 13338

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
