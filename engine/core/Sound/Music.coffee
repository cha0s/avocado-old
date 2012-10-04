# SPI proxy and constant definitions.

# avo.**Music** allows playing looped music and volume adjustment, timed
# fading, and more.

# Music playing constants.
# 
# * <code>avo.Music.LoopForever</code>: ***(default)*** Loops the music
# forever.
avo.Music.LoopForever = -1

# Load music at the specified URI.
avo.Music.load = (uri) ->
	return unless uri?
	
	@['%load'] uri
	
# Fade in the music for the specified number of milliseconds, and loop for the
# specified number of loops.
avo.Music::fadeIn = (loops = avo.Music.LoopForever, ms = 3000) ->
	
	@['%fadeIn'] loops, ms

# Fade out the music for the specified number of milliseconds.
avo.Music::fadeOut = (ms = 3000) -> @['%fadeOut'] ms

# Play the music for the specified number of loops.
avo.Music::play = (loops = avo.Music.LoopForever) ->
	
	@['%play'] loops

# Stop the music.
avo.Music::stop = @['%stop']
	