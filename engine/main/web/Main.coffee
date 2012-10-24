# Subclass Main. We update the elapsed time manually, since we don't get
# a tight loop like on native platforms; everything is interval-based in a
# browser.

Core = require 'Core'
Graphics = require 'Graphics'
Logger = require 'core/Utility/Logger'
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

Main = require 'core/Main'
main = new class extends Main
	
	constructor: ->
		
		super
		
		@stateChange = name: 'Initial', args: {}
	
	tick: ->
		
		Timing.TimingService.setElapsed @timeCounter.current() / 1000
		
		super
		
main.on 'stateInitialized', (name) ->
	
	if name is 'Initial'
		
		document.body.appendChild Graphics.window.window_.Canvas
		Graphics.window.window_.calculateOffset()

# Log and exit on error.
main.on 'error', (error) ->
	
	Logger.error error
	
	main.quit()

# Register a stderr logging strategy.
Logger.registerStrategy (message, type) ->
	
	# TYPE:
	Core.CoreService.writeStderr type.toUpperCase()
	
	# message
	Core.CoreService.writeStderr message

# GO!	
main.begin()
