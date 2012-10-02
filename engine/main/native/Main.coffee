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

avo.main = new class extends avo.Main

	constructor: ->
		
		window = new avo.Window()
		window.set [320, 240]
		window.setWindowTitle 'Avocado - Fun Should Be Free'
		
		# Keep track of ticks and renders so we can calculate when the next one
		# will happen, and relieve the CPU between.
		@timeCounter = new avo.Counter()
		@lastTickTime = 0
		@lastRenderTime = 0
		
		super
		
		@on 'render', (buffer) -> window?.render buffer
	
	begin: ->
		
		super
		
		running = true
			
		@on 'quit', ->
			
			running = false
		
		while running
			
			avo.TimingService.setElapsed @timeCounter.current() / 1000
			
			avo.tickTimeouts()
				
			nextWake = Math.min(
				@lastTickTime + @tickFrequency
				@lastRenderTime + @renderFrequency
			) - @timeCounter.current()
			
			avo.timingService.sleep(
				nextWake / 2 if nextWake > 1 and Math.random() > .5
			)
	
	tick: ->
		
		super
		
		@lastTickTime = @timeCounter.current()
	
	render: (buffer) ->
		
		super buffer
	
		@lastRenderTime = @timeCounter.current()
	
avo.main.on 'error', (error) ->

	message = if error.stack?
		error.stack
	else
		error.toString()
	avo.Logger.error message
	
	avo.main.quit()
	
avo.main.begin()
