
EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'
Transition = require 'core/Utility/Transition'
Vector = require 'core/Extension/Vector'

module.exports = class
	
	constructor: (
		el
	) ->
		
		Mixin this, EventEmitter
		
		@active = true

		swipeOffset = [0, 0]
		swipeOffset.x = -> @[0]
		swipeOffset.setX = (x) -> @[0] = x
		swipeOffset.y = -> @[1]
		swipeOffset.setY = (y) -> @[1] = y
		Mixin swipeOffset, Transition
		
		swiping = null
		
		holding = false
		holdStartPosition = [0, 0]
		holdStartOffset = [0, 0]
		
		@setMinMax = (@min, @max) => @emit 'update', swipeOffset
		
		if Modernizr.touch
			
			$el = $(el)
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseup = 'vmouseup'
			
		else
			
			$el = $(window)
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseup = 'mouseup'
		
		$el.on(
			mouseup
			=>
				return true unless @active
				
				holding = false
				
				true
			
		)
		
		$el.on(
			mousemove
			(event) =>
				
				return true unless @active
				
				if holding
					
					position = [event.clientX, event.clientY]
					delta = Vector.sub position, holdStartPosition
					delta = Vector.floor Vector.scale delta, -1/16
					
					offset = Vector.clamp(
						Vector.add delta, holdStartOffset
						@min
						@max
					)
					
					swipeOffset[i] = offset[i] for i in [0..1]
					
					@emit 'update', swipeOffset
					
				true
					
		)
		
		$(el).on(
			mousedown
			(event) =>
				
				return true unless @active
				
				swiping?.stopTransition()
				
				holding = true
				holdStartPosition = [event.clientX, event.clientY]
				holdStartOffset = Vector.copy swipeOffset
				
				true
				
		)
		
		$(el).on
			
			swipe: (event, delta) =>
				return true unless @active
				
				dp = []
				
				for i in [0..1]
					
					delta[i] = delta.end.coords[i] - delta.start.coords[i]
					
					dp[i] = if delta[i] < 0 then 1 else -1
					
					delta[i] = Math.pow(
						Math.abs delta[i]
						1.2
					)
				
				delta = Vector.floor Vector.scale delta, 1/16
				delta = Vector.mul delta, dp
				
				destination = Vector.clamp(
					Vector.add delta, swipeOffset
					@min
					@max
				)
				
				swiping = swipeOffset.transition(
					x: destination[0]
					y: destination[1]
				,
					500
				)
				
				update = => @emit 'update', swipeOffset
				
				swiping.defer.then(
					update
					->
					update
				)
