class avo.EntityTraits['2DTopdownPhysics'] extends avo.Physics
	
	defaults: ->
		
		O = super
		
		O.layer = 1
		
		O
		
	hooks:
		
		moveRequest: (hypotenuse) ->
		
			world = avo.world
			return unless world?
			
			hypotenuse = avo.Vector.scale(
				hypotenuse, @entity.movingSpeed() / 13
			)
			
			@entity.emit 'moving', hypotenuse
			
			request = avo.Vector.scale(
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
				new avo.b2Vec2 request[0], -request[1]
				@state.body.GetWorldCenter()
			)
			
	handler:
		
		ticker:
			
			weight: -100
			f: ->
				
				world = avo.world
				return unless world?
				
				return unless @state.body?
				
				{x, y} = @state.body.GetLinearVelocity()
				unless x is 0 and y is 0
					
					velocity = avo.Vector.scale(
						[-x, -y]
						@state.floorFriction
					)
					@state.body.ApplyImpulse(
						new avo.b2Vec2 velocity[0], velocity[1]
						@state.body.GetWorldCenter()
					)
					
				{x, y} = @state.body.GetPosition()
				@entity.setPosition avo.Vector.scale(
					[x, -y]
					13
				)
