# Subclass avo.Main. We add a window as a render destination, tracking of tick
# and render timings to implement CPU relief by sleeping between, and a hard
# loop where we manually update the time elapsed, since we need to invoke
# intervals and timeouts out-of-band.

Core = require 'Core'
Logger = require 'core/Utility/Logger'
Main = require 'core/Main'
Timing = require 'Timing'

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

main = new class extends Main

	constructor: ->
		
		super
		
		# Keep track of ticks and renders so we can calculate when the next one
		# will happen, and relieve the CPU between.
		@lastTickTime = 0
		@lastRenderTime = 0
		
		@stateChange = name: 'Initial', args: {}
	
	begin: ->
		
		super
		
		# Run the hard loop until we receive the quit event.
		running = true
		@on 'quit', -> running = false
		while running
			
			# Update time and run intervals and timeouts.
			Timing.TimingService.setElapsed @timeCounter.current() / 1000
			Timing.tickTimeouts()
			
			# Calculate the amount of time we can sleep and do so if we
			# have enough time.
			nextWake = Math.min(
				@lastTickTime + @tickFrequency
				@lastRenderTime + @renderFrequency
			) - @timeCounter.current()
			Timing.timingService.sleep(
				nextWake * .8 if nextWake > 1
			)
	
	tick: ->
		
		super
		
		# Keep track of tick timings.
		@lastTickTime = @timeCounter.current()
	
	render: (buffer) ->
		
		super buffer
	
		# Keep track of render timings.
		@lastRenderTime = @timeCounter.current()

# Log and exit on error.
main.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	Logger.error message
	
	main.quit()

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
