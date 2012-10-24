require 'coffee-script'

Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

# Use SFML CoreService for now.
Core.CoreService.implementSpi 'sfml'
Core.coreService = new Core.CoreService()

# Use SFML GraphicsService for now.
Graphics.GraphicsService.implementSpi 'sfml'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing.TimingService.implementSpi 'sfml'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound.SoundService.implementSpi 'sfml'
Sound.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

Timing['%setTimeout'] = setTimeout
Timing['%setInterval'] = setInterval
Timing['%clearTimeout'] = clearTimeout
Timing['%clearInterval'] = clearInterval

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
Main = require 'core/Main'
main = new class extends Main

	constructor: ->
		
		super
		
		@stateChange = name: 'Initial', args: {}
	
	tick: ->
		
		Timing.TimingService.setElapsed @timeCounter.current() / 1000
		
		super
		
# Log and exit on error.
main.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	Logger.error message
	
	main.quit 1

main.on 'quit', (code = 0) ->
	
	Sound.soundService.close()
	Timing.timingService.close()
	Graphics.graphicsService.close()
	Core.coreService.close()
	
	process.exit code

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

# GO!	
main.begin()

http = require 'http'
server = http.createServer (req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end 'Hello World\n'

server.listen 1337, '127.0.0.1'
console.log 'Server running at http://127.0.0.1:1337/'
