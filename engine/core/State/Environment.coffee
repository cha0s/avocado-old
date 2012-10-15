# Avocado loads the 'Initial' state, and from there it's all up to you!
class avo.Main.States['Environment'] extends avo.AbstractState
	
	enter: ({
		environmentUri
	}) ->
		
		# Load the environment, an entity to walk around in it, and a font to
		# show the renders and ticks per second, for informational purposes.
		upon.all([
			
			avo.Environment.load(environmentUri).then (@environment) =>
				
			avo.Entity.load('/entity/wb-dude.entity.json').then (@entity) =>
				
				# Start the entity at 150, 150.
				@entity.extendTraits [
					type: 'Existence'
					state:
						x: 150
						y: 150
				]
				
				# Facing down.
				@entity.setDirection 2
			
			avo.RasterFont.load('/font/wb-text.png').then (@font) =>
			
		]).then =>
			
			currentRoom = @environment.room 0
			
			@roomRectangle = avo.Rectangle.compose(
				[0, 0]
				avo.Vector.mul(
					currentRoom.size()
					@environment.tileset().tileSize()
				)
			)
			
			# Keep a display list to optimize rendering.
			@displayList = new avo.DisplayList [0, 0, 720, 450], @roomRectangle
			
			# Since we can't rely on graphics SPIIs letting us know when our
			# graphics need to be rewritten, we'll suggest redrawing the entire
			# screen 10 times a second.
			setInterval (=> @displayList.markCommandsAsDirty()), 100
			
			# Add a display command to white out the background.
			new avo.FillDisplayCommand(
				@displayList
				80, 80, 80, 255
				@roomRectangle
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				currentRoom.layer(0)
				@environment.tileset()
				@roomRectangle
			) 
			
			new avo.TileLayerDisplayCommand(
				@displayList
				currentRoom.layer(1)
				@environment.tileset()
				@roomRectangle
			) 
			
			new avo.EntityDisplayCommand(
				@displayList
				@entity
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				currentRoom.layer(2)
				@environment.tileset()
				@roomRectangle
			)
			
			new avo.TileLayerDisplayCommand(
				@displayList
				currentRoom.layer(3)
				@environment.tileset()
				@roomRectangle
			)
			
			@tps = new avo.FontDisplayCommand(
				@displayList
				@font
				""
				[16, 32]
			)
			@tps.setIsRelative false
		
			@rps = new avo.FontDisplayCommand(
				@displayList
				@font
				""
				[16, 48]
			)
			@rps.setIsRelative false
			
			# Allow dragging the avocado around with the left mouse button. Keep
			# track of where the avocado was when we started dragging.
			@mouseLocation = [0, 0]
			@clicking = false
			avo.window.on 'mouseButtonDown.EnvironmentState', ({button, x, y}) =>
				return unless button is avo.Window.LeftButton
				@clicking = true
				[x, y] = avo.Vector.mul(
					[x, y]
					avo.Vector.div avo.window.originalSize, avo.window.size()
				)
				@mouseLocation = [x, y]
			avo.window.on 'mouseButtonUp.EnvironmentState', ({button}) =>
				return unless button is avo.Window.LeftButton
				@clicking = false
			avo.window.on 'mouseMove.EnvironmentState', ({x, y}) =>
				[x, y] = avo.Vector.mul(
					[x, y]
					avo.Vector.div avo.window.originalSize, avo.window.size()
				)
				@mouseLocation = [x, y]
		
	setCameraFromEntity: (entity) ->
				
		@displayList.setPosition avo.Vector.clamp(
			avo.Vector.sub(
				avo.Vector.round entity.position()
				avo.Vector.sub(
					avo.Vector.scale avo.window.originalSize, .5
					avo.Vector.scale(
						avo.Rectangle.size entity.visibleRect()
						.5
					)
				)
			)
			[0, 0]
			avo.Vector.sub(
				avo.Rectangle.size @roomRectangle
				avo.window.originalSize
			)
		)
		
	tick: ->
		
		# Update our counters.
		@tps.setText "TPS: #{@main.ticksPerSecond.count()}"
		@rps.setText "RPS: #{@main.rendersPerSecond.count()}"
		
		# Any key/joystick movement input?
		unless avo.Vector.isZero (
			movement = avo.graphicsService.playerUnitMovement('Awesome player')
		)
			@entity.move movement, true   

		# Mouse clicking?
		if @clicking
			@entity.move avo.Vector.add @mouseLocation, @displayList.position()
		
		# Let the entity know it isn't moving anymore, so it switches back
		# to the idle animation.
		unless @clicking or not avo.Vector.isZero movement
			@entity.emit 'becameIdle'
			
		@setCameraFromEntity @entity
		
	# Called repeatedly to allow the state to render graphics.
	render: (buffer) ->
		
		# Render the anything dirty. This will also pass back the dirty areas.
		@displayList.render buffer
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		@displayList.clear()
		
		# Remove our event handler(s).
		avo.window.off '.InitialState'
