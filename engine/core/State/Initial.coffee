# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.States['Initial'] extends avo.AbstractState
	
	# Called the first time this state is loaded. You can set up any stuff your
	# state needs here. This is the Initial state, so we can also set up
	# things specific to our game.
	initialize: ->
		
		defer = upon.defer()
		
		# We want to store how much the player is moving either with the
		# arrow keys or the joystick/gamepad. We can set up our own custom
		# input handling here!
		avo.Input.movement = [0, 0]
		keyboardMoveState = [0, 0, 0, 0]
		
		# Let's add a little helper to calculate the movement for one tick.
		avo.Input.tickMovement = ->
			avo.Vector.scale avo.Input.movement, avo.TimingService.tickElapsed()
		
		# We'll store any movement that comes in.
		storeMovement = -> avo.Input.movement = [
			keyboardMoveState[1] - keyboardMoveState[3]
			keyboardMoveState[2] - keyboardMoveState[0]
		]
		
		# Joystick movement.
		avo.Input.on 'joyAxis', (stick, axis, value) ->
			return if axis > 1
			
			if value > 0
				keyboardMoveState[if axis is 0 then 1 else 2] = Math.abs value
			else if value < 0
				keyboardMoveState[if axis is 0 then 3 else 0] = Math.abs value
			else
				
				if axis is 0
					keyboardMoveState[1] = keyboardMoveState[3] = 0
				else
					keyboardMoveState[0] = keyboardMoveState[2] = 0
			
			storeMovement()
			
		# Keyboard movement started.
		avo.Input.on 'keyDown', (code) ->
			
			switch code
				when avo.Input.SpecialKeys.UpArrow then keyboardMoveState[0] = 1
				when avo.Input.SpecialKeys.RightArrow then keyboardMoveState[1] = 1
				when avo.Input.SpecialKeys.DownArrow then keyboardMoveState[2] = 1
				when avo.Input.SpecialKeys.LeftArrow then keyboardMoveState[3] = 1
			
			storeMovement()
			
		# Keyboard movement stopped.
		avo.Input.on 'keyUp', (code) ->
			switch code
				when avo.Input.SpecialKeys.UpArrow then keyboardMoveState[0] = 0
				when avo.Input.SpecialKeys.RightArrow then keyboardMoveState[1] = 0
				when avo.Input.SpecialKeys.DownArrow then keyboardMoveState[2] = 0
				when avo.Input.SpecialKeys.LeftArrow then keyboardMoveState[3] = 0
			
			storeMovement()
		
		# Yum, an avocado!
		@avocado = {}
		
		# Keep track of when we're dragging the mouse.
		@dragging = false
		@dragStartAvocadoLocation = []
		@dragStartMouseLocation = []
		@mouseLocation = []
	
		# Let's move around the avocado! In order to do that, we'll need to
		# keep track of its x, y location.
		[@x, @y] = [0, 0]
		
		defer.resolve()
		
		defer.promise
	
	# Called every time this state is entered. You should do things like
	# setting up your event handlers here.
	enter: (args) ->
		
		# Initialization is asynchronous.
		defer = upon.defer()
		
		# Load that avocado image.
		avo.Image.load('/image/avocado.png').then (@avocado) =>
			
			# When the image is loaded, we're done initializing. Tell Avocado
			# we're ready!
			defer.resolve()
			
		# Allow dragging the avocado around.
		avo.Input.on 'mouseButtonDown.State', (button) =>
		
			# Ignore anything except left mouse button
			return unless button is avo.Input.LeftButton
			
			@dragging = true
			@dragStartAvocadoLocation = [@x, @y]
			@dragStartMouseLocation = @mouseLocation
			
		avo.Input.on 'mouseButtonUp.State', (button) =>
		
			# Ignore anything except left mouse button
			return unless button is avo.Input.LeftButton
			
			@dragging = false
		
		avo.Input.on 'mouseMove.State', (x, y) =>
			@mouseLocation = [x, y]
			
			return unless @dragging
			
			[@x, @y] = avo.Vector.add @dragStartAvocadoLocation, avo.Vector.sub(
				@mouseLocation
				@dragStartMouseLocation
			)
		
		# Promise Avocado we'll finish initialization... eventually!
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
	onExit: (nextStateName) ->
		
		# Remove our user input event handler.
		avo.Input.off 'inputEvent.State'
		
		# Wave to the next state because we're a friendly state!
		avo.Logger.info "*waves to #{nextStateName}*"
