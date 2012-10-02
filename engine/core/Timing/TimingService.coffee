
avo.TimingService::sleep = (ms) ->
	return unless ms?
	
	@['%sleep'] ms

@setTimeout = avo['%setTimeout']
@setInterval = avo['%setInterval']
@clearTimeout = avo['%clearTimeout']
@clearInterval = avo['%clearInterval']

elapsed = 0
lastElapsed = 0
tickElapsed = 0

avo.TimingService.elapsed = -> elapsed
avo.TimingService.setElapsed = (e) -> elapsed = e

avo.TimingService.tickElapsed = -> tickElapsed
avo.TimingService.tick = ->
	
	tickElapsed = elapsed - lastElapsed
	lastElapsed = elapsed
