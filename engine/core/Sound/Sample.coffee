# Proxy and constant definitions.

avo.Sample.LoopForever = -1
avo.Sample.AnyChannel = -1

avo.Sample.load = (uri, qualify = true) ->
	return unless uri?
	
	@['%load'] uri, qualify
	
avo.Sample::play = (loops = 0, channel = avo.Sample.AnyChannel) ->
	
	@['%play'] loops, channel