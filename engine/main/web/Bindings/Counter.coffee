module.exports = class
	
	startMs = (new Date()).getTime()
	
	constructor: ->
	
	'%current': -> (new Date()).getTime() - startMs
