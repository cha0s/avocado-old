class avo.EnvironmentState extends avo.AbstractState
	
	initialize: ->
		
		@cameraPosition = [0, 0]
		
		super
	
	enter: ({
		environmentUri
		@roomIndex
	}) ->
		
		# Load the environment, an entity to walk around in it, and a font to
		# show the renders and ticks per second, for informational purposes.
		upon.all([
			
			avo.Environment.load(environmentUri).then (@environment) =>
				
		]).then =>
			
			@currentRoom = @environment.room @roomIndex
			
			@roomRectangle = avo.Rectangle.compose(
				[0, 0]
				avo.Vector.mul(
					@currentRoom.size()
					@environment.tileset().tileSize()
				)
			)
			
			# Keep a display list to optimize rendering.
			@displayList = new avo.DisplayList [0, 0, 720, 450], @roomRectangle
			
			# Since we can't rely on graphics SPIIs letting us know when our
			# graphics need to be rewritten, we'll suggest redrawing the entire
			# screen 10 times a second.
			setInterval (=> @displayList.markCommandsAsDirty()), 100
			
	setCamera: (position, easing = .25) ->
				
		newPosition = avo.Vector.clamp(
			avo.Vector.sub(
				avo.Vector.round position
				avo.Vector.scale avo.window.originalSize, .5
			)
			[0, 0]
			avo.Vector.sub(
				avo.Rectangle.size @roomRectangle
				avo.window.originalSize
			)
		)
		
		@displayList.setPosition newPosition if easing is 0
		
		distance = avo.Vector.cartesianDistance(
			@displayList.position()
			newPosition
		)
		return if distance is 0
		
		@displayList.setPosition avo.Vector.round @cameraPosition = avo.Vector.add(
			@cameraPosition
			avo.Vector.scale(
				avo.Vector.hypotenuse(
					newPosition
					@cameraPosition
				)
				if distance is 0
					0
				else
					(Math.min 10, distance / 16) / easing
			)
		)
		
	# Called repeatedly to allow the state to render graphics.
	render: (buffer) ->
		
		# Render the anything dirty. This will also pass back the dirty areas.
		@displayList.render buffer
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		@displayList.clear()
