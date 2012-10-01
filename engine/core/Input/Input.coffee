avo.Input.LeftButton   = 1
avo.Input.MiddleButton = 2
avo.Input.RightButton  = 3
avo.Input.WheelUp      = 4
avo.Input.WheelDown    = 5

avo.input = new avo.Input()

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

avo.input.movement = [0, 0]

eventMap = [
	['moveLeft', 'moveRight']
	['moveUp', 'moveDown']
]

doRepeats = ->
	
	avo.input.movement = [
		moveState[1] - moveState[3]
		moveState[2] - moveState[0]
	]
	
	repeater = (event, i) ->
		
		setTimeout(
			->
				repeatIntervals[i] ?= setInterval(
					->
						avo.input.emit('inputEvent', event);
					50
				)
			500
		)
	
	for i in [0, 1]
		
		if avo.input.movement[i]
			
			repeatTimeouts[i] ?= repeater(
				eventMap[i][if avo.input.movement[i] < 0 then 0 else 1]
				i
			)
			
		else
		
			clearTimeout repeatTimeouts[i]
			clearInterval repeatIntervals[i]
			
			repeatTimeouts[i] = repeatIntervals[i] = null

avo.input.on 'joyAxis', (stick, axis, value) ->
	
	if axis is 1
		
		moveState[0] = -value
		
	else
	
		moveState[1] = value
		
	doRepeats()

avo.input.on 'keyDown', (code) ->
	
	switch code
		
		when keyCodeMap['confirm']
			
			avo.input.emit 'inputEvent', 'confirm'
			
		when keyCodeMap['cancel']
			
			avo.input.emit 'inputEvent', 'cancel'
			
		when keyCodeMap['menu']
			
			avo.input.emit 'inputEvent', 'menu'
			
		when keyCodeMap['moveUp']
		
			avo.input.emit 'inputEvent', 'moveUp'
			
			moveState[0] = 1
			
		when keyCodeMap['moveRight']
			
			avo.input.emit 'inputEvent', 'moveRight'
			
			moveState[1] = 1
			
		when keyCodeMap['moveDown']
		
			avo.input.emit 'inputEvent', 'moveDown'
			
			moveState[2] = 1
			
		when keyCodeMap['moveLeft']
		
			avo.input.emit 'inputEvent', 'moveLeft'
			
			moveState[3] = 1
	
	doRepeats()

avo.input.on 'keyUp', (code) ->
	
	switch code
		
		when keyCodeMap['moveUp']
		
			avo.input.emit 'inputEvent', 'moveUpReleased'
		
			moveState[0] = 0
			
		when keyCodeMap['moveRight']
			
			avo.input.emit 'inputEvent', 'moveRightReleased'
			
			moveState[1] = 0
			
		when keyCodeMap['moveDown']
		
			avo.input.emit 'inputEvent', 'moveDownReleased'
			
			moveState[2] = 0
			
		when keyCodeMap['moveLeft']
		
			avo.input.emit 'inputEvent', 'moveLeftReleased'
			
			moveState[3] = 0
	
	doRepeats()

