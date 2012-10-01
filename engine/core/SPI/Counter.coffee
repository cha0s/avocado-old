
avo.Counter::current = @['%current']

avo.Counter::since = @['%since']

avo.Counter::secondsSince = @['%secondsSince']

timeElapsed = 0
lastTimeElapsed = 0
tickTimeElapsed = 0

avo.timeElapsed = -> timeElapsed
avo.setTimeElapsed = (elapsed) -> timeElapsed = elapsed

avo.tickTimeElapsed = -> tickTimeElapsed
avo.setTickTimeElapsed = ->
	
	tickTimeElapsed = timeElapsed - lastTimeElapsed
	lastTimeElapsed = timeElapsed
