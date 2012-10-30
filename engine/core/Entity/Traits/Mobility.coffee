
TimingService = require('Timing').TimingService
Trait = require 'core/Entity/Traits/Trait'
Vector = require 'core/Extension/Vector'

module.exports = class extends Trait

	defaults: ->
		
		mobile: true
		movingSpeed: 0
		visibilityIndex: 'moving'
	
	constructor: (entity, state) ->
		
		super entity, state
		
		@isMoving = false
		@movementExpectedTime = 0

	values: ->

		mobile: -> @state.mobile
		
		movingSpeed: -> @state.movingSpeed
		
		isMoving: -> @isMoving
		
		visibilityIndex: -> @state.visibilityIndex
	
	signals: ->
	
		startedMoving: -> @isMoving = true
		stoppedMoving: -> @isMoving = false
		
	actions: ->

		move:
			argTypes: ['Position', 'Boolean']
			argNames: ['Towards position', 'Relative movement']
			renderer: (candidate, args) ->
				
				output = "move #{candidate} forward towards "
				output += "#{Rule.Render args[0]} "
				output += "using relative movement if "
				output += "#{Rule.Render args[1]}"
				
			name: 'Move towards'
			f: (
				toPosition
				elapsed = TimingService.tickElapsed()
				relative = false
			) ->
				return increment: 1 if not @entity.mobile()
				
				direction = @entity.direction()
				position = @entity.position()
				
				if relative
					hypotenuse = toPosition
				else
					hypotenuse = Vector.hypotenuse(
						toPosition
						position
					)
				
				magnitude = elapsed * @entity.movingSpeed()
				
				# Non-relative movement should check whether the movement has
				# passed the destination. If so, the actual position is fixed up to
				# the destination.
				if not relative
					
					@state.hypotenuse = hypotenuse
					
					for i in [0, 1]
						
						continue if @state.hypotenuse[i] is 0
						continue if position[i] is toPosition[i]
						
						continue if @state.hypotenuse[i] > 0 and position[i] <= toPosition[i]
						continue if @state.hypotenuse[i] < 0 and position[i] >= toPosition[i]
						
						position[i] = toPosition[i]
					
					if toPosition[0] is position[0] and toPosition[1] is position[1]
						
						@entity.setPosition position
						delete @state.hypotenuse
						
						return increment: 1
						
				newDirection = Vector.toDirection hypotenuse, @entity.directionCount()
				@entity.setDirection newDirection if direction isnt newDirection
				
				moveInvocations = @entity.invoke 'moveRequest', hypotenuse
				if moveInvocations.length is 0
				
					@entity.emit 'moving', hypotenuse
				
					@entity.setPosition Vector.add position, Vector.scale hypotenuse, magnitude
				
				increment: 0

		moveForward:
			
			argTypes: ['Number', 'Number']
			argNames: ['Minimum movement', 'Maximum movement']
			renderer: (candidate, args) ->
				
				output = "move #{candidate} forward between "
				output += "#{Rule.Render args[0]} and #{Rule.Render args[1]}"
				output += " px"
				
			name: 'Move forward'
			f: (min, max = min) ->
				
				if @isMoving
					
					finishedMoving = @entity.move(@destination).increment > 0 
					finishedMoving = TimingService.elapsed() >= @movementExpectedTime unless finishedMoving
					if finishedMoving
					
						@entity.emit 'stoppedMoving'
						
						return {increment: 1}
					
				else 
				
					destination = @entity.position()
					distance = Math.floor Math.randomRange min, max
					
					switch @entity.direction()
						
						when 0
							destination[1] -= distance
							
						when 1
							destination[0] += distance
							
						when 2
							destination[1] += distance
							
						when 3
							destination[0] -= distance

					@movementExpectedTime = .1 + timeElapsed() + distance / @entity.movingSpeed()

					@destination = destination
					
					@entity.emit 'startedMoving'
				
				return {increment: 0}

		setMobile: (mobile) -> @state.mobile = mobile

		setMovingSpeed: (movingSpeed) -> @state.movingSpeed = movingSpeed
