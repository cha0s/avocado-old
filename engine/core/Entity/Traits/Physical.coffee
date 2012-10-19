class avo.EntityTraits['Physical'] extends avo.Trait
	
	defaults: ->
		
		bodyType: 'dynamic'
		solid: true
		radius: 6
		layer: 1
	
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
		
		bodyDef.position.Set @entity.x(), -@entity.y()
		@state.body = world.CreateBody bodyDef
		
		circle = new avo.b2CircleShape()
		circle.SetRadius @state.radius
		
		fixtureDef = new avo.b2FixtureDef()
		fixtureDef.shape = circle
		fixtureDef.density = 0
#		fixtureDef.friction = .5
		
		@adjustFilterBits fixtureDef.filter
		
		avo.Logger.info @state.body.m_invMass
			
		@state.body.CreateFixture fixtureDef
		avo.Logger.info @state.body.m_invMass
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
	
	signals:
		
		startedMoving: ->
			
			@isMoving = true
		
		stoppedMoving: ->
			
			@isMoving = false
		
	hooks:
		
		moveRequest: (hypotenuse, magnitude) ->
		
			world = avo.world
			return unless world?
			
			mvec = 1000 / (avo.TimingService.tickElapsed() * 1000)
			mvec *= (avo.ticksPerSecondTarget / mvec)
			
			desired = avo.Vector.mul(
				[mvec, -mvec]
				avo.Vector.scale hypotenuse, magnitude
			)
			
			{x, y} = @state.body.GetLinearVelocity()
			velocity = [x, y]
			
			@entity.emit 'moving', avo.Vector.scale hypotenuse, magnitude
			
			change = avo.Vector.scale(
				avo.Vector.sub desired, velocity
				.01
			)
			
			@state.body.ApplyImpulse(
				new avo.b2Vec2 change[0], change[1]
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
				
				return if x is 0 and y is 0
				
				unless @isMoving
					
					velocity = avo.Vector.scale(
						[-x, -y]
						.01
					)
					@state.body.ApplyImpulse(
						new avo.b2Vec2 velocity[0], velocity[1]
						@state.body.GetWorldCenter()
					)
				
				{x, y} = @state.body.GetPosition()
				
				@entity.setPosition avo.Vector.round [x, -y]
