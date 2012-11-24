# Subclass Main. We update the elapsed time manually, since we don't get
# a tight loop like on native platforms; everything is interval-based in a
# browser.

Core = require 'Core'
Graphics = require 'Graphics'
Logger = require 'core/Utility/Logger'
Timing = require 'Timing'

# SPI proxies.
require 'core/proxySpiis'

Client = class extends (require 'core/Network/Client')

	constructor: ->
		
		super
		
		@timeCounter = new Timing.Counter()
	
	tick: ->
		
		Timing.TimingService.setElapsed @timeCounter.current() / 1000
		
		super
		
client = new Client
	
#	url: 'http://avocado.cha0sb0x.ath.cx'
	url: 'http://engine.bridgeunitorzo.com'

client.on 'stateInitialized', (name) ->
	
	if name is 'Client/Initial'
		
		document.body.appendChild Graphics.window.window_.Canvas
		Graphics.window.window_.calculateOffset()

# Log and exit on error.
client.on 'error', (error) ->
	
	Logger.error error
	
	client.quit()

# Register a console logging strategy.
Logger.registerStrategy (message, type) ->
	
	# TYPE:
	Core.CoreService.writeStderr type.toUpperCase()
	
	# message
	Core.CoreService.writeStderr message

# GO!	
client.begin()
