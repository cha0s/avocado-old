# Avocado loads the 'Initial' state, and from there it's all up to you!

AbstractState = require 'core/State/AbstractState'
Graphics = require 'Graphics'
upon = require 'core/Utility/upon'

module.exports = class extends AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
		
		defer = upon.defer()
		
		# Register a player 'Awesome player' to receive input using the
		# keyboard arrow keys and joystick index 0.
		Graphics.graphicsService.registerPlayerMovement 'Awesome player', [
			Graphics.graphicsService.SpecialKeyCodes.UpArrow
			Graphics.graphicsService.SpecialKeyCodes.RightArrow
			Graphics.graphicsService.SpecialKeyCodes.DownArrow
			Graphics.graphicsService.SpecialKeyCodes.LeftArrow
		], 0
	
		# Last, we'll open the window where we show all of the graphics
		# stuff. We'll wait so that there isn't a black screen sitting
		# there while everything loads.
		# Instantiate a Window to receive render events.
		Graphics.window = new Graphics.graphicsService.newWindow [720, 450]
		Graphics.window.setWindowTitle 'Avocado - Fun Should Be Free'
		Graphics.window.originalSize = [720, 450]
		
		# @main lets us know when it has something to render, so we'll
		# put it on our window.
		@main.on 'render', (buffer, rectangle) =>
			
			# Render and display the changes to the window.
			Graphics.window.render buffer, rectangle
			Graphics.window.display()
			
		# Catch the quit event (window close event).
		Graphics.window.on 'quit.InitialState', => @main.quit()
		
		defer.resolve()
		defer.promise
				
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on movement input.
	tick: ->
		
		@main.changeState(
			'Environment/2DPlatformerEnvironment'
			environmentUri: '/environment/platforms.environment.json'
			roomIndex: 0
		)
		
	# Called repeatedly to allow the state to render graphics.
	render: (buffer) ->
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
