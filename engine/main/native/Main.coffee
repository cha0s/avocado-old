# Subclass avo.Main. We add a window as a render destination, tracking of tick
# and render timings to implement CPU relief by sleeping between, and a hard
# loop where we manually update the time elapsed, since we need to invoke
# intervals and timeouts out-of-band.

Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

Logger = require 'core/Utility/Logger'

# Register a stderr logging strategy.
Logger.registerStrategy Logger.stderrStrategy

@console = log: Logger.info

# SPI proxies.
require 'core/proxySpiis'

GlobalConfig = require 'core/GlobalConfig'
GlobalConfig.CLIENT_PACKET_INTERVAL = 80
GlobalConfig.SERVER_PACKET_INTERVAL = 80

ipcSocket = require('core/Network/Ipc')()

Server = class extends (require 'core/Network/Server')
server = new Server
	
	type: 'ipc'
	ipcSocket: ipcSocket

server.begin()

# Log and exit on error.
server.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	Logger.error message
	
	server.quit()

timeCounter = new Timing.Counter()
		
Client = class extends (require 'core/Network/Client')

	constructor: ->
		
		super
		
		# Keep track of ticks and renders so we can calculate when the next one
		# will happen, and relieve the CPU between.
		@lastTickTime = 0
		@lastRenderTime = 0
	
	tick: ->
		
		super
		
		# Keep track of tick timings.
		@lastTickTime = timeCounter.current()
	
	render: (buffer) ->
		
		super buffer
		
		# Keep track of render timings.
		@lastRenderTime = timeCounter.current()

client = new Client
	
	url: 'ipc://'
	ipcSocket: ipcSocket

# Log and exit on error.
client.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	Logger.error message
	
	client.quit()

client.on 'quit', ->

	Sound.soundService.close()
	Timing.timingService.close()
	Graphics.graphicsService.close()
	Core.coreService.close()

# GO!	
client.begin()

# Run the hard loop until we receive the quit event.
running = true
client.on 'quit', -> running = false
while running
	
	# Update time and run intervals and timeouts.
	Timing.TimingService.setElapsed timeCounter.current() / 1000
	Timing.tickTimeouts()
	
	# Calculate the amount of time we can sleep and do so if we
	# have enough time.
	nextWake = Math.min(
		client.lastTickTime + client.tickFrequency
		client.lastRenderTime + client.renderFrequency
	) - timeCounter.current()
	Timing.timingService.sleep(
		nextWake * .8 if nextWake > 1
	)
