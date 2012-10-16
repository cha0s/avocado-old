class avo.Counter
	
	startMs = (new Date()).getTime()
	
	constructor: ->
	
	'%current': -> (new Date()).getTime() - startMs
