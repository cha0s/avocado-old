class avo.Main.States['2DPlatformerEnvironment'] extends avo.EnvironmentState
	
	createLayerFixture: (layer) ->
	
		fixtureDef = new avo.b2FixtureDef()
		fixtureDef.density = 1
		fixtureDef.friction = 0
		fixtureDef.filter.categoryBits = if layer is -1
			(1 << 5) - 1
		else
			1 << layer
			
		fixtureDef.filter.maskBits = fixtureDef.filter.categoryBits
		
		fixtureDef
		
	createRoomEdges: (wall) ->
		
		wall.isALoop ?= true
		wall.layer ?= -1
		
		avo.Logger.info wall
		
		fixtureDef = @createLayerFixture wall.layer
		fixtureDef.shape = new avo.b2PolygonShape()
		
		for vertice, i in wall.vertices
			
			nextVertice = if i is wall.vertices.length - 1
				if wall.isALoop then wall.vertices[0] else null
			else
				wall.vertices[i + 1]
			break unless nextVertice?
			
			fixtureDef.shape.SetAsEdge(
				new avo.b2Vec2(
					vertice[0] / avo.Physics.PixelsPerMeter
					-vertice[1] / avo.Physics.PixelsPerMeter
				)
				new avo.b2Vec2(
					nextVertice[0] / avo.Physics.PixelsPerMeter
					-nextVertice[1] / avo.Physics.PixelsPerMeter
				)
			)
			
			avo.world.GetGroundBody().CreateFixture fixtureDef
		
	createRoomCollision: ->
		
		## Room outer boundaries
		@createRoomEdges
			
			vertices: [
				[0, 0]
				[@roomRectangle[2] - 1, 0]
				[@roomRectangle[2] - 1, @roomRectangle[3] - 1]
				[0, @roomRectangle[3] - 1]
			]
		
		for collision in @currentRoom.collision ? []
		
			switch collision.type
				
				when 'ellipse'
					
					@createRoomEllipse collision
				
				when 'edges'
					
					@createRoomEdges collision
	
	enter: (args) ->
		
		avo.world = new avo.b2World new avo.b2Vec2(0, -98), false
		
		avo.EntityTraits['Physics'] = avo.EntityTraits['2DPlatformerPhysics']
		
		environmentPromise = super args
		
		@currentRoom.collision ?= []
		
		@currentRoom.collision.push
			
			type: 'edges'
			vertices: [
				[48, 112]
				[304, 112]
				[304, 128]
				[48, 128]
			]
		
		@createRoomCollision()
		
		upon.all([
			
			environmentPromise
				
			avo.Entity.load('/entity/wb-dude.entity.json').then (@entity) =>
				
				# Start the entity at 150, 150.
				@entity.extendTraits [
					type: 'Existence'
					state:
						x: 64
						y: 16
				]
				
				# Facing down.
				@entity.setDirection 2
				
				@entity.reset()
				
			avo.RasterFont.load('/font/wb-text.png').then (@font) =>
			
		]).then =>
			
			# Add a display command to white out the background.
			new avo.FillDisplayCommand(
				@displayList
				80, 80, 80, 255
				@roomRectangle
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				@currentRoom.layer 0
				@environment.tileset()
				@roomRectangle
			) 
			
			new avo.TileLayerDisplayCommand(
				@displayList
				@currentRoom.layer 1
				@environment.tileset()
				@roomRectangle
			) 
			
			new avo.EntityDisplayCommand(
				@displayList
				@entity
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				@currentRoom.layer 2
				@environment.tileset()
				@roomRectangle
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				@currentRoom.layer 3
				@environment.tileset()
				@roomRectangle
			)
			
			@tps = new avo.RasterFontDisplayCommand(
				@displayList
				@font
				"TPS: 0"
				[16, 32]
			)
			@tps.setIsRelative false
		
			@rps = new avo.RasterFontDisplayCommand(
				@displayList
				@font
				"RPS: 0"
				[16, 48]
			)
			@rps.setIsRelative false
			
			# Allow dragging the avocado around with the left mouse button. Keep
			# track of where the avocado was when we started dragging.
			@mousePosition = [0, 0]
			@clicking = false
			avo.window.on 'mouseButtonDown.2DTopdownEnvironmentState', ({button, x, y}) =>
				return unless button is avo.Window.LeftButton
				@clicking = true
				[x, y] = avo.Vector.mul(
					[x, y]
					avo.Vector.div avo.window.originalSize, avo.window.size()
				)
				@mousePosition = [x, y]
			avo.window.on 'mouseButtonUp.2DTopdownEnvironmentState', ({button}) =>
				return unless button is avo.Window.LeftButton
				@clicking = false
			avo.window.on 'mouseMove.2DTopdownEnvironmentState', ({x, y}) =>
				[x, y] = avo.Vector.mul(
					[x, y]
					avo.Vector.div avo.window.originalSize, avo.window.size()
				)
				@mousePosition = [x, y]
				
			avo.window.on 'keyDown', ({code}) =>
				
				if code is 57
				
					@entity.traits['Physics'].state.body.ApplyImpulse(
						new avo.b2Vec2 0, 28
						@entity.traits['Physics'].state.body.GetWorldCenter()
					)
		
	tick: ->
		
		if world = avo.world
			world.Step 1 / avo.ticksPerSecondTarget, 8, 3
		
		@entity.tick()
		
		# Update our counters.
		@tps.setText "TPS: #{@entity.position()}"
		@rps.setText "RPS: #{@main.rendersPerSecond.count()}"
		
		actuallyMoved = false
		
		# Any key/joystick movement input?
		unless avo.Vector.isZero (
			movement = avo.graphicsService.playerUnitMovement('Awesome player')
		)
			actuallyMoved = true
			
			movement[1] = 0
			@entity.move movement, true   

		# Mouse clicking?
		if @clicking and 2 < avo.Vector.cartesianDistance(
			avo.Vector.add @mousePosition, @displayList.position()
			@entity.position()
		)
			actuallyMoved = true
			@entity.move avo.Vector.add @mousePosition, @displayList.position()
		
		if actuallyMoved
			
			@entity.emit 'startedMoving' unless @entity.isMoving()
			
		else
		
			@entity.emit 'stoppedMoving' if @entity.isMoving()
			
		@setCamera @entity.position()
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		super
		
		# Remove our event handler(s).
		avo.window.off '.2DTopdownEnvironmentState'
		