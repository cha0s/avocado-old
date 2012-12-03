# Subclass Main. We update the elapsed time manually, since we don't get
# a tight loop like on native platforms; everything is interval-based in a
# browser.

Core = require 'Core'
Logger = require 'core/Utility/Logger'
Timing = require 'Timing'

# Register a console logging strategy.
Logger.registerStrategy (message, type) ->
	
	# TYPE:
	Core.CoreService.writeStderr type.toUpperCase()
	
	# message
	Core.CoreService.writeStderr message

# SPI proxies.
require 'core/proxySpiis'

socket = io.connect(
	'http://192.168.1.2:13338'
#	'http://editor.avocado.cha0sb0x.ath.cx'
)

timeCounter = new Timing.Counter()
setInterval(
	-> Timing.TimingService.setElapsed timeCounter.current() / 1000
	100
)

$(document).ready ->
	
	document.title = 'Persea'
	
socket.on 'connect', ->

	Persea = require 'Persea'
	
	persea = new Persea.View el: $ '#persea'
	
	Backbone.history.start
#		pushState: true
		silent: true
	
	persea.render()
	
	persea.loadSubject '/environment/wb-forest.environment.json'
