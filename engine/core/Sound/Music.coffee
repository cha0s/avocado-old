# SPI proxy and constant definitions.

avo.Music.LoopForever = -1
avo.Music.AnyChannel = -1

avo.Music.load = (uri, qualify = true) ->
	return unless uri?
	
	@['%load'] uri, qualify
	
avo.Music::fadeIn = (loops = avo.Music.LoopForever, ms = 3000) -> @['%fadeIn'] loops, ms

avo.Music::fadeOut = (ms = 3000) -> @['%fadeOut'] ms

avo.Music::play = (loops = avo.Music.LoopForever) ->
	
	@['%play'] loops

avo.Music::stop = @['%stop']
	