# Avocado State!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
		
		# Let's move around the avocado! In order to do that, we'll need to
		# keep track of its x, y location.
		[@x, @y] = [0, 0]
		
		# Register a player (0) to receive input using the keyboard arrow keys
		# and joystick index 0.
		avo.Input.registerPlayerMovement 0, [
			avo.Input.SpecialKeys.UpArrow
			avo.Input.SpecialKeys.RightArrow
			avo.Input.SpecialKeys.DownArrow
			avo.Input.SpecialKeys.LeftArrow
		], 0
		
		# Allow dragging the avocado around with the left mouse button. Keep
		# track of where the avocado was when we started dragging.
		@dragStartAvocadoLocation = []
		avo.Input.on 'mouseButtonDown.InitialState', (button) =>
			return unless button is avo.Input.LeftButton
			@dragStartAvocadoLocation = [@x, @y]
		avo.Input.on 'mouseDrag.InitialState', (position, button, relative) =>
			return unless button is avo.Input.LeftButton
			[@x, @y] = avo.Vector.add @dragStartAvocadoLocation, relative
		
		# Yum, an avocado!
		imagePromise = avo.Image.load('/image/avocado.png').then (@avocado) =>
		
		# Happy music!
		musicPromise = avo.Music.load('/music/smile.ogg').then (@music) =>
		
			# Start it as soon as it loads.
			@music.play()
		
		# When the image and music are done loading, then we're done
		# initializing. Remember - with CoffeeScript, the last statement in
		# a function is the return value. And upon.all returns a promise, just
		# as initialize requires. Elegant!
		upon.all([
			imagePromise
			musicPromise
		])
	
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on movement input.
	tick: ->
		
		# Move it 500px a second based on player 0's movement.
		[@x, @y] = avo.Vector.add(
			[@x, @y]
			avo.Vector.scale avo.Input.playerTickMovement(0), 500
		)
	
	# Called repeatedly while this state is loaded. You can render all of
	# your pretty pictures here!
	render: (buffer) ->
		
		# Fill the screen with white.
		buffer.fill 255, 255, 255
		
		# Show the avocado at its current x, y location.
		@avocado.render [@x, @y], buffer
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		# Remove our user input event handler(s).
		avo.Input.off '.InitialState'
