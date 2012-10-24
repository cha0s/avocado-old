
Box2D = require 'core/Physics/Box2D'
Physics = require 'core/Entity/Traits/Physics'
Trait = require 'core/Entity/Traits/Trait'
Vector = require 'core/Extension/Vector'

module.exports = class extends Physics
	
	defaults: ->
		
		O = super
		
		O.layer = 1
		
		O
		
	hooks: ->
		
		moveRequest: (hypotenuse) ->
		
			return unless Box2D.world?
			
			hypotenuse = Vector.scale(
				hypotenuse, @entity.movingSpeed() / Physics.PixelsPerMeter
			)
			
			@entity.emit 'moving', hypotenuse
			
			request = Vector.scale(
				hypotenuse
				@state.floorFriction
			)
			
			{x, y} = @state.body.GetLinearVelocity()
			velocity = [x, -y]
			
			for i in [0..1]
				
				if request[i] > 0
					if velocity[i] >= hypotenuse[i]
						request[i] = 0
					else
						if (vr = velocity[i] + request[i]) > hypotenuse[i]
							request[i] = hypotenuse[i] - vr
					
				else if request[i] < 0
					if velocity[i] <= hypotenuse[i]
						request[i] = 0
					else
						if (vr = velocity[i] + request[i]) < hypotenuse[i]
							request[i] = hypotenuse[i] - vr
					
			@state.body.ApplyImpulse(
				new Box2D.b2Vec2 request[0], -request[1]
				@state.body.GetWorldCenter()
			)
			
	handler: ->
		
		ticker:
			
			weight: -100
			f: ->
				
				return unless Box2D.world?
				return unless @state.body?
				
				{x, y} = @state.body.GetLinearVelocity()
				unless x is 0 and y is 0
					
					velocity = Vector.scale(
						[-x, -y]
						@state.floorFriction
					)
					@state.body.ApplyImpulse(
						new Box2D.b2Vec2 velocity[0], velocity[1]
						@state.body.GetWorldCenter()
					)
					
				{x, y} = @state.body.GetPosition()
				@entity.setPosition Vector.scale(
					[x, -y]
					Physics.PixelsPerMeter
				)
