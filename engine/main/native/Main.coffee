# Subclass avo.Main. We add a window as a render destination, tracking of tick
# and render timings to implement CPU relief by sleeping between, and a hard
# loop where we manually update the time elapsed, since we need to invoke
# intervals and timeouts out-of-band.
avo.main = new class extends avo.Main

	constructor: ->
		
		super
		
		# Instantiate a Window to receive render events.
		window = new avo.Window()
		window.set [320, 240]
		window.setWindowTitle 'Avocado - Fun Should Be Free'
		@on 'render', (buffer) -> window.render buffer
		
		# Keep track of ticks and renders so we can calculate when the next one
		# will happen, and relieve the CPU between.
		@timeCounter = new avo.Counter()
		@lastTickTime = 0
		@lastRenderTime = 0
	
	begin: ->
		
		super
		
		# Run the hard loop until we receive the quit event.
		running = true
		@on 'quit', -> running = false
		while running
			
			# Update time and run intervals and timeouts.
			avo.TimingService.setElapsed @timeCounter.current() / 1000
			avo.tickTimeouts()
			
			# Calculate the amount of time we can sleep and do so if we
			# have enough time.
			nextWake = Math.min(
				@lastTickTime + @tickFrequency
				@lastRenderTime + @renderFrequency
			) - @timeCounter.current()
			avo.timingService.sleep(
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
avo.main.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	avo.Logger.error message
	
	avo.main.quit()

# Register a stderr logging strategy.
avo.Logger.registerStrategy (message, type) ->
	
	# Colors for the console.
	colors =
	
		error : '\x1B[1;31m'
		warn  : '\x1B[1;33m'
		info  : '\x1B[1;32m'
		reset : '\x1B[0m'
		
	# TYPE:
	avo.CoreService.writeStderr "#{
		colors[type]
	}#{
		type.toUpperCase()
	}#{
		colors.reset
	}:"
	
	# message
	avo.CoreService.writeStderr message

# GO!	
avo.main.begin()
