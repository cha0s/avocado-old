
avo.TimingService::sleep = (ms) ->
	return unless ms?
	
	@['%sleep'] ms

avo.TimingService::close = ->
	
	@['%close']()

avo.setTimeout = avo['%setTimeout']
avo.setInterval = avo['%setInterval']
avo.clearTimeout = avo['%clearTimeout']
avo.clearInterval = avo['%clearInterval']
