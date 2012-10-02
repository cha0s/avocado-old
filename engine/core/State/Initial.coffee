# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Initial'] extends avo.AbstractState
	
	initialize: ->
		
		defer = upon.defer()
		
		# We want to store how much the player is moving either with the
		# arrow keys or the joystick/gamepad. We can set up our own custom
		# input handling here!
		avo.Input.movement = [0, 0]
		keyboardMoveState = [0, 0, 0, 0]
		joystickMoveState = [0, 0, 0, 0]
		
		# Let's add a little helper to calculate the movement for one tick.
		avo.Input.tickMovement = ->
			avo.Vector.scale avo.Input.movement, avo.TimingService.tickElapsed()
		
		# We'll store any movement that comes in, combining keyboard and
		# joystick movement, making sure that combined they never exceed 1.
		storeMovement = -> avo.Input.movement = [
			Math.max(
				Math.min(
					(keyboardMoveState[1] - keyboardMoveState[3]) + (joystickMoveState[1] - joystickMoveState[3])
					1
				)
				-1
			)
			Math.max(
				Math.min(
					(keyboardMoveState[2] - keyboardMoveState[0]) + (joystickMoveState[2] - joystickMoveState[0])
					1
				)
				-1
			)
		]
		
		# Joystick movement.
		avo.Input.on 'joyAxis', (stick, axis, value) ->
			return if axis > 1
			
			if value > 0
				joystickMoveState[if axis is 0 then 1 else 2] = Math.abs value
			else if value < 0
				joystickMoveState[if axis is 0 then 3 else 0] = Math.abs value
			else
				
				if axis is 0
					joystickMoveState[1] = joystickMoveState[3] = 0
				else
					joystickMoveState[0] = joystickMoveState[2] = 0
			
			storeMovement()
			
		# Keyboard movement started.
		avo.Input.on 'keyDown', (code) ->
			switch code
				when avo.Input.SpecialKeys.UpArrow
					keyboardMoveState[0] = 1
				when avo.Input.SpecialKeys.RightArrow
					keyboardMoveState[1] = 1
				when avo.Input.SpecialKeys.DownArrow
					keyboardMoveState[2] = 1
				when avo.Input.SpecialKeys.LeftArrow
					keyboardMoveState[3] = 1
			
			storeMovement()
			
		# Keyboard movement stopped.
		avo.Input.on 'keyUp', (code) ->
			switch code
				when avo.Input.SpecialKeys.UpArrow
					keyboardMoveState[0] = 0
				when avo.Input.SpecialKeys.RightArrow
					keyboardMoveState[1] = 0
				when avo.Input.SpecialKeys.DownArrow
					keyboardMoveState[2] = 0
				when avo.Input.SpecialKeys.LeftArrow
					keyboardMoveState[3] = 0
			
			storeMovement()
		
		defer.resolve()
		
		defer.promise
		
	tick: ->
		
		# Once we're running... AVOCADO!!
		avo.main.changeState 'Avocado'
