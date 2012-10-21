# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
		
		# Register a player 'Awesome player' to receive input using the
		# keyboard arrow keys and joystick index 0.
		avo.graphicsService.registerPlayerMovement 'Awesome player', [
			avo.graphicsService.SpecialKeyCodes.UpArrow
			avo.graphicsService.SpecialKeyCodes.RightArrow
			avo.graphicsService.SpecialKeyCodes.DownArrow
			avo.graphicsService.SpecialKeyCodes.LeftArrow
		], 0
		
		# Last, we'll open the window where we show all of the graphics
		# stuff. We'll wait so that there isn't a black screen sitting
		# there while everything loads.
		# Instantiate a Window to receive render events.
		avo.window = new avo.graphicsService.newWindow [720, 450]
		avo.window.setWindowTitle 'Avocado - Fun Should Be Free'
		avo.window.originalSize = [720, 450]
		
		# @main lets us know when it has something to render, so we'll
		# put it on our window.
		@main.on 'render', (buffer, rectangle) =>
			
			# Render and display the changes to the window.
			avo.window.render buffer, rectangle
			avo.window.display()
			
		# Catch the quit event (window close event).
		avo.window.on 'quit.InitialState', => @main.quit()
		
		defer = upon.defer()
		defer.resolve()
		defer.promise
				
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on movement input.
	tick: ->
		
		@main.changeState(
			'2DTopdownEnvironment'
			environmentUri: '/environment/wb-forest.environment.json'
			roomIndex: 0
		)
		
	# Called repeatedly to allow the state to render graphics.
	render: (buffer) ->
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
