# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	initialize: ->
		
		defer = upon.defer()
		
		defer.resolve()
		
		defer.promise
		
	tick: ->
		
		# Once we're running... AVOCADO!!
		avo.main.changeState 'Avocado'
