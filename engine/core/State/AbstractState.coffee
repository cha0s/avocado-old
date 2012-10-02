class avo.AbstractState

	onExit: ->
	
	initialize: (args) ->
		
		defer = upon.defer()
		
		defer.resolve()
		
		defer.promise
	
	tick: ->
	
	render: (buffer) ->
