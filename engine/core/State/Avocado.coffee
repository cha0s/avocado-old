# Avocado State!
class avo.Main.States['Avocado'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
		
		defer = upon.defer()
		
		# Allow dragging the avocado around.
		avo.Input.on 'mouseButtonDown.AvocadoState', (button) =>
		
			# Ignore anything except left mouse button
			return unless button is avo.Input.LeftButton
			
			@dragging = true
			@dragStartAvocadoLocation = [@x, @y]
			@dragStartMouseLocation = @mouseLocation
			
		avo.Input.on 'mouseButtonUp.AvocadoState', (button) =>
		
			# Ignore anything except left mouse button
			return unless button is avo.Input.LeftButton
			
			@dragging = false
		
		avo.Input.on 'mouseMove.AvocadoState', (x, y) =>
			@mouseLocation = [x, y]
			
			return unless @dragging
			
			[@x, @y] = avo.Vector.add @dragStartAvocadoLocation, avo.Vector.sub(
				@mouseLocation
				@dragStartMouseLocation
			)
		
		# Yum, an avocado!
		@avocado = {}
		avo.Image.load('/image/avocado.png').then (@avocado) =>
			
			# When the image is loaded, we're done initializing. Tell Avocado
			# we're ready!
			defer.resolve()
		
		# Keep track of when we're dragging the mouse.
		@dragging = false
		@dragStartAvocadoLocation = []
		@dragStartMouseLocation = []
		@mouseLocation = []
	
		# Let's move around the avocado! In order to do that, we'll need to
		# keep track of its x, y location.
		[@x, @y] = [0, 0]
		
		defer.promise
	
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on user input.
	tick: ->
		
		# Move it 500px a second.
		[@x, @y] = avo.Vector.add(
			[@x, @y]
			avo.Vector.scale avo.Input.tickMovement(), 500
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
		avo.Input.off '.AvocadoState'
		
		# Wave to the next state because we're a friendly state!
		avo.Logger.info "*AvocadoState waves to #{nextStateName}*"
