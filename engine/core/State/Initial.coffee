# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
	
		# Add a display command to white out the background.
		new avo.FillDisplayCommand(
			@main.displayList
			255, 255, 255, 255
			[0, 0, 800, 600]
		)
		
		# Register a player 'Awesome player' to receive input using the
		# keyboard arrow keys and joystick index 0.
		avo.graphicsService.registerPlayerMovement 'Awesome player', [
			avo.graphicsService.SpecialKeyCodes.UpArrow
			avo.graphicsService.SpecialKeyCodes.RightArrow
			avo.graphicsService.SpecialKeyCodes.DownArrow
			avo.graphicsService.SpecialKeyCodes.LeftArrow
		], 0
		
		# Yum, an avocado!
		imagePromise = avo.Image.load('/image/avocado.png').then (image) =>
			
			# Add a display command to show the yummy avocado.
			@avocado = new avo.ImageDisplayCommand(
				@main.displayList
				image
				avo.Rectangle.compose [0, 0], image.size()
			)
		
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
			avo.window = new avo.graphicsService.newWindow [800, 600]
			avo.window.setWindowTitle 'Avocado - Fun Should Be Free'
			
			# @main lets us know when it has something to render, so we'll
			# put it on our window.
			@main.on 'render', (buffer, rectangle) ->
				
				# Render and display the changes to the window.
				avo.window.render buffer, rectangle
				avo.window.display()
				
			# Catch the quit event (window close event).
			avo.window.on 'quit.Engine', => @main.quit()
			
			# Allow dragging the avocado around with the left mouse button. Keep
			# track of where the avocado was when we started dragging.
			@dragStartAvocadoLocation = []
			avo.window.on 'mouseButtonDown.InitialState', ({button}) =>
				return unless button is avo.Window.LeftButton
				@dragStartAvocadoLocation = @avocado.position()
			avo.window.on 'mouseDrag.InitialState', ({position, button, relative}) =>
				return unless button is avo.Window.LeftButton
				@avocado.setPosition avo.Vector.add @dragStartAvocadoLocation, relative
				
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on movement input.
	tick: ->
		
		# Any movement input?
		movement = avo.graphicsService.playerTickMovement('Awesome player')
		return if avo.Vector.isZero movement
		
		# Move the avocado 250px a second based on player 'Awesome player's
		# movement.
		@avocado.setPosition avo.Vector.add(
			@avocado.position()
			avo.Vector.scale movement, 250
		)
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		# Remove our event handler(s).
		avo.window.off '.InitialState'
