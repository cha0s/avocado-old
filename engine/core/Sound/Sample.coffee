# SPI proxy and constant definitions.

# **Sample** is the representation for a sound effect.

Sample = require('Sound').Sample

# Sample playing constants.
# 
# * <code>Sample.LoopForever</code>: ***(default)*** Loops the sample
# forever.
Sample.LoopForever = -1

# Load a sample at the specified URI.
Sample.load = (uri) ->
	return unless uri?
	
	@['%load'] uri
	
# Play the sample for the specified number of loops.
Sample::play = (loops = 0) ->
	
	@['%play'] loops
