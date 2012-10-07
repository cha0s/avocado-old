# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
	
		# Let's move the avocado! In order to do that, we'll need to keep track
		# of its x, y location.
		[@x, @y] = [0, 0]
		
		# Register a player 'Awesome player' to receive input using the
		# keyboard arrow keys and joystick index 0.
		avo.uiService.registerPlayerMovement 'Awesome player', [
			avo.uiService.SpecialKeyCodes.UpArrow
			avo.uiService.SpecialKeyCodes.RightArrow
			avo.uiService.SpecialKeyCodes.DownArrow
			avo.uiService.SpecialKeyCodes.LeftArrow
		], 0
		
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
		]).then =>
			
			# Last, we'll open the window where we show all of the graphics
			# stuff. We'll wait so that there isn't a black screen sitting
			# there while everything loads.
			# Instantiate a Window to receive render events.
			avo.window = new avo.uiService.newWindow [320, 240]
			avo.window.setWindowTitle 'Avocado - Fun Should Be Free'
			
			# avo.main lets us know when it has something to render, so we'll
			# put it on our window.
			avo.main.on 'render', (buffer) -> avo.window.render buffer
			
			# Catch the quit event (window close event).
			avo.window.on 'quit.Engine', => avo.main.quit()
			
			# Allow dragging the avocado around with the left mouse button. Keep
			# track of where the avocado was when we started dragging.
			@dragStartAvocadoLocation = []
			avo.window.on 'mouseButtonDown.InitialState', ({button}) =>
				return unless button is avo.Window.LeftButton
				@dragStartAvocadoLocation = [@x, @y]
			avo.window.on 'mouseDrag.InitialState', ({position, button, relative}) =>
				return unless button is avo.Window.LeftButton
				[@x, @y] = avo.Vector.add @dragStartAvocadoLocation, relative
				
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on movement input.
	tick: ->
		
		# Move it 500px a second based on player 'Awesome player's movement.
		[@x, @y] = avo.Vector.add(
			[@x, @y]
			avo.Vector.scale avo.uiService.playerTickMovement('Awesome player'), 500
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
		
		# Remove our event handler(s).
		avo.window.off '.InitialState'
