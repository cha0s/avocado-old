# SPI proxy and constant definitions.

# **Music** allows playing looped music and volume adjustment, timed
# fading, and more.

Music = require('Sound').Music
upon = require 'core/Utility/upon'

# Music playing constants.
# 
# * <code>Music.LoopForever</code>: ***(default)*** Loops the music
# forever.
Music.LoopForever = -1

# Load music at the specified URI.
Music.load = (uri) ->

	defer = upon.defer()
	
	unless uri?
		
		defer.resolve()
		return defer.promise
	
	@['%load'] uri, defer.resolve
	
	defer.promise
	
# Fade in the music for the specified number of milliseconds, and loop for the
# specified number of loops.
Music::fadeIn = (loops = Music.LoopForever, ms = 3000) ->
	
	@['%fadeIn'] loops, ms

# Fade out the music for the specified number of milliseconds.
Music::fadeOut = (ms = 3000) -> @['%fadeOut'] ms

# Play the music for the specified number of loops.
Music::play = (loops = Music.LoopForever) ->
	
	@['%play'] loops

# Stop the music.
Music::stop = @['%stop']
	