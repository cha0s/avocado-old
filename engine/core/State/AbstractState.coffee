# **AbstractState** is the abstract class which all states in the Avocado
# engine extend.
#
# Avocado is always in a State, except during the initialization phase, and
# shortly before exiting the engine.
#
# States will never be destroyed during the lifecycle of the engine. Remember
# this, as it means that no child objects will be garbage collected unless
# you delete them!

upon = require 'core/Utility/upon'

module.exports = class
	
	# When the state is first loaded, initialize is called. This is used to
	# initialize the State. You can load resources that are to remain as
	# persistent for the life of the application.
	initialize: (args) ->
		
		# By default, a State just immediately resolves its initialization
		# promise.
		defer = upon.defer()
		defer.resolve()
		defer.promise
	
	# When the State is entered by the engine, enter is called. You can use
	# this to register input handlers and load resources that should be loaded
	# every time this State is entered by the engine. After this State is
	# entered, it becomes the active State.
	enter: (args, previousStateName) ->
		
		# By default, a State just immediately resolves its enter promise.
		defer = upon.defer()
		defer.resolve()
		defer.promise
	
	# Tick is called repeatedly by the engine while this State is the active
	# State. This is where the game is updated. You might run your enemy
	# behavior logic here, for instance.
	tick: ->
	
	# Render is called repeatedly by the engine while this State is the active
	# State. This is where the game is displayed. Render graphics to the buffer
	# so they will appear in the game window.
	render: (buffer) ->

	# Called when the engine loads another State. This gives the State an
	# opportunity to clean up any resources loaded or input handlers loaded
	# or registered in enter().
	leave: ->
