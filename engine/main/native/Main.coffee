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

class MainCpp extends avo.Main

	constructor: ->
		
		@window = new avo.Window()
		
		@window.set [640, 480]
		
		@window.setWindowTitle 'Avocado - collaborative, libre, gratis game development'
	
		super
		
	relieveCpu: ->
	
		nextWake = Math.min(
			@lastTickTime + @tickFrequency
			@lastRenderTime + @renderFrequency
		) - @timeCounter.current()
		
		avo.timingService.sleep nextWake / 2 if nextWake > 1 and Math.random() > .5
	
try
	
	main = new MainCpp()

	running = true
	waiting = true
	
	tick = new avo.Ticker main.tickFrequency
	render = new avo.Ticker main.renderFrequency
	
	main.initialize().then ->
	
		avo.state = state: 'Initial' 
	
	avo.Input.on 'quit.Engine', ->
		
		running = false
		waiting = false
	
	while running
		
		avo.setTimeElapsed main.timeCounter.current() / 1000
		
		if tick.ticks()
			
			avo.Input.poll()
		
			main.tick()
			
			avo.tickTimeouts()
			
		if render.ticks()
			
			main.render()
			
		main.handleStateChange()
		
		main.relieveCpu()
		
catch error

	message = if error.stack?
		error.stack
	else
		error.toString()
	avo.Logger.error message
