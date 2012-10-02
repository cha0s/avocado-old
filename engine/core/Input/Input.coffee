# Proxy and constant definitions.

Input = new avo.Input()
avo.Input = Input

avo.Input.LeftButton   = 1
avo.Input.MiddleButton = 2
avo.Input.RightButton  = 3
avo.Input.WheelUp      = 4
avo.Input.WheelDown    = 5

keyCodeMap =

	# Enter
	'confirm'  : 13
	
	# Backspace
	'cancel'   : 8
	
	# Escape
	'menu'     : 27
	
	# Up
	'moveUp'   : 273
	
	# Right
	'moveRight': 275
	
	# Down
	'moveDown' : 274
	
	# Left
	'moveLeft' : 276

moveState = [0, 0, 0, 0]
repeatIntervals = [null, null]
repeatTimeouts = [null, null]

avo.Input.movement = [0, 0]

eventMap = [
	['moveLeft', 'moveRight']
	['moveUp', 'moveDown']
]

doRepeats = ->
	
	avo.Input.movement = [
		moveState[1] - moveState[3]
		moveState[2] - moveState[0]
	]
	
	repeater = (event, i) ->
		
		setTimeout(
			->
				repeatIntervals[i] ?= setInterval(
					->
						avo.Input.emit('inputEvent', event);
					50
				)
			500
		)
	
	for i in [0, 1]
		
		if avo.Input.movement[i]
			
			repeatTimeouts[i] ?= repeater(
				eventMap[i][if avo.Input.movement[i] < 0 then 0 else 1]
				i
			)
			
		else
		
			clearTimeout repeatTimeouts[i]
			clearInterval repeatIntervals[i]
			
			repeatTimeouts[i] = repeatIntervals[i] = null

avo.Input.on 'joyAxis', (stick, axis, value) ->
	
	if axis is 1
		
		moveState[0] = -value
		
	else
	
		moveState[1] = value
		
	doRepeats()

avo.Input.on 'keyDown', (code) ->
	
	switch code
		
		when keyCodeMap['confirm']
			
			avo.Input.emit 'inputEvent', 'confirm'
			
		when keyCodeMap['cancel']
			
			avo.Input.emit 'inputEvent', 'cancel'
			
		when keyCodeMap['menu']
			
			avo.Input.emit 'inputEvent', 'menu'
			
		when keyCodeMap['moveUp']
		
			avo.Input.emit 'inputEvent', 'moveUp'
			
			moveState[0] = 1
			
		when keyCodeMap['moveRight']
			
			avo.Input.emit 'inputEvent', 'moveRight'
			
			moveState[1] = 1
			
		when keyCodeMap['moveDown']
		
			avo.Input.emit 'inputEvent', 'moveDown'
			
			moveState[2] = 1
			
		when keyCodeMap['moveLeft']
		
			avo.Input.emit 'inputEvent', 'moveLeft'
			
			moveState[3] = 1
	
	doRepeats()

avo.Input.on 'keyUp', (code) ->
	
	switch code
		
		when keyCodeMap['moveUp']
		
			avo.Input.emit 'inputEvent', 'moveUpReleased'
		
			moveState[0] = 0
			
		when keyCodeMap['moveRight']
			
			avo.Input.emit 'inputEvent', 'moveRightReleased'
			
			moveState[1] = 0
			
		when keyCodeMap['moveDown']
		
			avo.Input.emit 'inputEvent', 'moveDownReleased'
			
			moveState[2] = 0
			
		when keyCodeMap['moveLeft']
		
			avo.Input.emit 'inputEvent', 'moveLeftReleased'
			
			moveState[3] = 0
	
	doRepeats()

