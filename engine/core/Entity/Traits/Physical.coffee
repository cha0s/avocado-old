class avo.EntityTraits['Physical'] extends avo.Trait
	
	defaults: ->
		
		bodyType: 'dynamic'
		solid: true
		radius: 6
		layer: 1
		floorFriction: .1
	
	translateBodyType = (type) ->
	
		switch type
			when 'dynamic' then avo.b2Body.b2_dynamicBody
			when 'static' then avo.b2Body.b2_staticBody

	adjustFilterBits: (filter) ->
	
		filter.categoryBits = 1 << @state.layer
		
		filter.maskBits = if @state.solid
			filter.categoryBits
		else
			0

	adjustFixtureFilterBits: ->
	
		fixture = @state.body.GetFixtureList()
		
		filter = fixture.GetFilterData()
		
		@adjustFilterBits filter
		
		fixture.SetFilterData filter
	
	constructor: (entity, state) ->
		super entity, state
		
		@isTouching = []
		@isInMainParty = false
		@isMoving = false
		
	resetTrait: ->
		
		world = avo.world
		return unless world?
		
		bodyDef = new avo.b2BodyDef()
		bodyDef.type = translateBodyType @state.bodyType
#		bodyDef.linearDamping = 0
		
		worldPosition = avo.Vector.scale(
			[@entity.x(), -@entity.y()]
			1/13
		)
		
		bodyDef.position.Set.apply bodyDef.position, worldPosition 
		@state.body = world.CreateBody bodyDef
		
		circle = new avo.b2CircleShape()
		circle.SetRadius @state.radius
		
		fixtureDef = new avo.b2FixtureDef()
		fixtureDef.shape = circle
		fixtureDef.density = 0
#		fixtureDef.friction = .5
		
		@adjustFilterBits fixtureDef.filter
		
		@state.body.CreateFixture fixtureDef
		@state.body.SetUserData this
	
	removeTrait: ->
		
		world = avo.world
		return unless world?
		
		world.DestroyBody @state.body
	
	actions:
		
		setIsTouching: (entity) ->
			
			@isTouching.push entity if -1 is @isTouching.indexOf entity
		
		unsetIsTouching: (entity) ->
			
			index = @isTouching.indexOf entity
			
			@isTouching.splice index, 1 unless index is -1
			
		setMainPartyCollision: ->
			
			@isInMainParty = true
			
			@adjustFixtureFilterBits()
			
		setRadius: (radius) -> @state.radius = radius
		
		setBodyType:
			
			f: (type) ->
			
				@state.body.SetType translateBodyType @state.bodyType = type
		
		setSolid:
			name: 'Set solidity'
			renderer: (candidate, args) ->
				
				'set ' + candidate + ' solidity to ' + Rule.Render args[0]
				
			f: (solid) ->
				
				@state.solid = solid
				
				@adjustFixtureFilterBits()
				
			argTypes: ['Boolean']
			argNames: ['Solidity']
		
	values:
		
		isTouching:
			
			name: 'Is touching entity'
			renderer: (candidate, args) ->
				
				candidate + ' is touching ' + Rule.Render args[0]
				
			argTypes: ['Entity']
			argNames: ['Other entity']
			f: (entity) -> return -1 isnt @isTouching.indexOf entity
		
		radius: -> @state.radius
		
		isSolid: -> @state.solid
		
		touching: -> @isTouching
		
		bodyType: -> @state.bodyType
	
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
