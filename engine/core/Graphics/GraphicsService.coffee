# We want to store how much a player is moving either with the
# arrow keys or the joystick/gamepad.
movement = {}
keyCodeMap = {}
stickIndexMap = {}

# Register four-directional keyboard movement. Specify a player key to
# associate this movement, as well as a 4-element array of key codes to use
# for the movement. The key codes represent up, right, down, left
# respectively. Also, specify a joystick index to assign to this player.
avo.GraphicsService::registerPlayerMovement = (player, keyCodes, stickIndex) ->
	
	# Map the key code and joystick index to the player so we can look 'em up
	# quick when a key code or joystick movement comes in.
	keyCodeMap[keyCode] = player for keyCode in keyCodes
	stickIndexMap[stickIndex] = player
	movement[player] =
		tickUnit: [0, 0]
		keyCodes: keyCodes
		keyState: [0, 0, 0, 0]
		stickIndex: stickIndex
		joyState: [0, 0, 0, 0]

# Get a unit movement vector for a player scaled by the time passed this tick.
avo.GraphicsService::playerTickMovement = (player) ->
	
	return [0, 0] unless movement[player]?
	
	avo.Vector.scale(
		movement[player].tickUnit
		avo.TimingService.tickElapsed()
	)

# We'll store any movement that comes in, combining keyboard and
# joystick movement, making sure that combined they never exceed 1.
registerMovement = (player) ->
	
	m = movement[player]
	m.tickUnit = [
		Math.max(
			Math.min(
				(
					m.keyState[1] - m.keyState[3]
				) + (
					m.joyState[1] - m.joyState[3]
				)
				1
			)
			-1
		)
		Math.max(
			Math.min(
				(
					m.keyState[2] - m.keyState[0]
				) + (
					m.joyState[2] - m.joyState[0]
				)
				1
			)
			-1
		)
	]

windows = []

avo.GraphicsService::newWindow = (size, flags) ->
	
	window = new avo.Window()
	windows.push window
	
	window.setSize size if size?
	window.setFlags flags if flags?
	
	# Joystick movement.
	window.on 'joyAxis.Avocado', ({stickIndex, axis, value}) ->
		return if axis > 1
		
		return unless (player = stickIndexMap[stickIndex])?
		return unless m = movement[player]
		
		if value > 0
			m.joyState[if axis is 0 then 1 else 2] = Math.abs value
		else if value < 0
			m.joyState[if axis is 0 then 3 else 0] = Math.abs value
		else
			if axis is 0
				m.joyState[1] = m.joyState[3] = 0
			else
				m.joyState[0] = m.joyState[2] = 0
		
		registerMovement player
		
	# Keyboard movement started.
	window.on 'keyDown.Avocado', ({code}) ->
		
		return unless (player = keyCodeMap[code])?
		return unless m = movement[player]
		
		m.keyState[m.keyCodes.indexOf code] = 1
		
		registerMovement player
		
	# Keyboard movement stopped.
	window.on 'keyUp.Avocado', ({code}) ->
	
		return unless (player = keyCodeMap[code])?
		return unless m = movement[player]
	
		m.keyState[m.keyCodes.indexOf code] = 0
		
		registerMovement player
	
	# Mouse dragging is a bit of a higher-level concept. We'll implement it
	# using the low-level API.
	buttons = {}
	dragStartLocation = {}
	mouseLocation = [0, 0]
	
	# Start dragging when a button is clicked.
	window.on 'mouseButtonDown.Avocado', ({button}) ->
		switch button
			when avo.Window.LeftButton, avo.Window.MiddleButton, avo.Window.RightButton
				dragStartLocation[button] = mouseLocation
				buttons[button] = true
				
	# Stop dragging when a button is released.
	window.on 'mouseButtonUp.Avocado', ({button}) ->
		switch button
			when avo.Window.LeftButton, avo.Window.MiddleButton, avo.Window.RightButton
				delete buttons[button]
				delete dragStartLocation[button]
	
	# When the mouse moves,
	window.on 'mouseMove.Avocado', ({x, y}) ->
		mouseLocation = [x, y]
		
		# Check if any buttons are being held down
		keys = Object.keys buttons
		if keys.length > 0
			
			# If so, send a mouseDrag event for each of them.
			for key in keys
				window.emit(
					'mouseDrag'
						position: mouseLocation
						button: parseInt key
						relative: avo.Vector.sub(
							mouseLocation
							dragStartLocation[key]
						)
				)
				
	window
	
avo.GraphicsService::pollEvents = -> window.pollEvents() for window in windows