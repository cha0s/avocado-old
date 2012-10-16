# Subclass avo.Main. We update the elapsed time manually, since we don't get
# a tight loop like on native platforms; everything is interval-based in a
# browser.
avo.main = new class extends avo.Main

	tick: ->
		
		avo.TimingService.setElapsed @timeCounter.current() / 1000
		
		super

avo.main.on 'stateInitialized', (name) ->
	
	if name is 'Initial'
		
		document.body.appendChild avo.window.Canvas
		avo.window.calculateOffset()

# Log and exit on error.
avo.main.on 'error', (error) ->
	
	avo.Logger.error error
	
	avo.main.quit()

# Register a stderr logging strategy.
avo.Logger.registerStrategy (message, type) ->
	
	# TYPE:
	avo.CoreService.writeStderr type.toUpperCase()
	
	# message
	avo.CoreService.writeStderr message

# GO!	
avo.main.begin()
