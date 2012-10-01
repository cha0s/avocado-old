
avo.TimingService::sleep = (ms) ->
	return unless ms?
	
	@['%sleep'] ms

@setTimeout = avo['%setTimeout']
@setInterval = avo['%setInterval']
@clearTimeout = avo['%clearTimeout']
@clearInterval = avo['%clearInterval']

timeElapsed = 0
lastTimeElapsed = 0
tickTimeElapsed = 0

avo.timeElapsed = -> timeElapsed
avo.setTimeElapsed = (elapsed) -> timeElapsed = elapsed

avo.tickTimeElapsed = -> tickTimeElapsed
avo.setTickTimeElapsed = ->
	
	tickTimeElapsed = timeElapsed - lastTimeElapsed
	lastTimeElapsed = timeElapsed
