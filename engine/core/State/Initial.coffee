# Avocado loads the 'Initial' state, and from there it's all up to you!
avo.States['Initial'] = new class
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here.
	constructor: ->
		
		# Yum, an avocado!
		@avocado = {}
	
		# Let's move around the avocado! In order to do that, we'll need to
		# keep track of its x, y location.
		@x = 0
		@y = 0
	
	# Called every time this state is loaded. You should do things like loading
	# images and setting up your event handlers here.
	initialize: (args) ->
		
		# Initialization is asynchronous.
		defer = upon.defer()
		
		# Load that avocado image.
		avo.Image.load('/image/avocado.png').then (@avocado) =>
			
			# When the image is loaded, we're done initializing. Tell Avocado
			# we're ready!
			defer.resolve()
		
		# Promise Avocado we'll finish initialization... eventually!
		defer.promise
	
	# Called repeatedly while this state is loaded. You can do things like
	# update your world here. We'll move the avocado based on user input.
	tick: ->
		
		# Move it 100px a second.
		movement = avo.tickTimeElapsed() * 100
		@x += avo.input.movement[0] * movement
		@y += avo.input.movement[1] * movement
	
	# Called repeatedly while this state is loaded. You can render all of
	# your pretty pictures here!
	render: (buffer) ->
		
		# Fill the screen with white.
		buffer.fill 255, 255, 255
		
		# Show the avocado at its current x, y location.
		@avocado.render [@x, @y], buffer
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	onExit: (nextStateName) ->
		
		# Remove our user input event handler.
		avo.input.off 'inputEvent.State'
		
		# Wave to the next state because we're a friendly state!
		avo.Logger.info "*waves to #{nextStateName}*"
