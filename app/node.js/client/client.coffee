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

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

Logger = require 'core/Utility/Logger'

Client = class extends (require 'core/Network/Client')

	constructor: ->
		
		super
		
		@timeCounter = new Timing.Counter()
		
	tick: ->
		
		Timing.TimingService.setElapsed @timeCounter.current() / 1000
		
		super
		
client = new Client
	
#	url: 'http://engine.bridgeunitorzo.com'
#	url: 'http://avocado.cha0sb0x.ath.cx'
#	url: 'unix:///tmp/foobar.sock'
	url: 'http://localhost:13337'

# Log and exit on error.
client.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	Logger.error message
	
	client.quit 1

client.on 'quit', (code = 0) ->
	
	client.disconnect()
	
	Sound.soundService.close()
	Timing.timingService.close()
	Graphics.graphicsService.close()
	Core.coreService.close()
	
	process.exit code

# Register a stderr logging strategy.
Logger.registerStrategy Logger.stderrStrategy

Logger.info 'hi hi'

# GO!	
client.begin()

process.on 'SIGINT', ->
	
	client.quit()
