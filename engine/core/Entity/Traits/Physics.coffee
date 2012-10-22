class avo.Physics extends avo.Trait
	
	@PixelsPerMeter = 13
	
	defaults: ->
		
		bodyType: 'dynamic'
		solid: true
		radius: 4
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
		
	resetTrait: ->
		
		return unless avo.world?
		
		bodyDef = new avo.b2BodyDef()
		bodyDef.type = translateBodyType @state.bodyType
		bodyDef.fixedRotation = true
#		bodyDef.linearDamping = 0
		
		worldPosition = avo.Vector.scale(
			[@entity.x(), -@entity.y()]
			1 / avo.Physics.PixelsPerMeter
		)
		
		bodyDef.position.Set.apply bodyDef.position, worldPosition 
		@state.body = avo.world.CreateBody bodyDef
		
		box = new avo.b2PolygonShape()
		box.SetAsBox @state.radius / avo.Physics.PixelsPerMeter, @state.radius / avo.Physics.PixelsPerMeter 
		
		circle = new avo.b2CircleShape()
		circle.SetRadius @state.radius / avo.Physics.PixelsPerMeter
		
		fixtureDef = new avo.b2FixtureDef()
		fixtureDef.shape = circle
#		fixtureDef.shape = box
		fixtureDef.density = 0
		fixtureDef.friction = 0
		
		@adjustFilterBits fixtureDef.filter
		
		@state.body.CreateFixture fixtureDef
		@state.body.SetUserData this
	
	removeTrait: ->
		
		return unless avo.world?
		
		avo.world.DestroyBody @state.body
	
	actions:
		
		setIsTouching: (entity) ->
			
			@isTouching.push entity if -1 is @isTouching.indexOf entity
		
		unsetIsTouching: (entity) ->
			
			index = @isTouching.indexOf entity
			
			@isTouching.splice index, 1 unless index is -1
			
		setMainPartyCollision: ->
			
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
