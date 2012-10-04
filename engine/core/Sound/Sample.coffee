# SPI proxy and constant definitions.

# avo.**Sample** is the representation for a sound effect.

# Sample playing constants.
# 
# * <code>avo.Sample.LoopForever</code>: ***(default)*** Loops the sample
# forever.
avo.Sample.LoopForever = -1

# Load a sample at the specified URI.
avo.Sample.load = (uri) ->
	return unless uri?
	
	@['%load'] uri
	
# Play the sample for the specified number of loops.
avo.Sample::play = (loops = 0) ->
	
	@['%play'] loops