# avo.**AbstractState** is the abstract class which all states in the Avocado
# engine.
#
# Avocado is always in a State, except during the initialization phase, and
# shotly before exiting.
class avo.AbstractState
	
	# When the state is first loaded, initialize is called. This is used to
	# initialize the state. You can load resources that are to remain as
	# persistent for the life of the application.
	initialize: (args) ->
		
		defer = upon.defer()
		
		defer.resolve()
		
		defer.promise
	
	enter: (args) ->
		
		defer = upon.defer()
		
		defer.resolve()
		
		defer.promise
	
	tick: ->
	
	render: (buffer) ->

	leave: ->
