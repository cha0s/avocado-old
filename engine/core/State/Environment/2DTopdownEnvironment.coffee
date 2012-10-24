
Box2D = require 'core/Physics/Box2D'
Entity = require 'core/Entity/Entity'
EnvironmentState = require 'core/State/Environment'
Graphics = require 'Graphics'
Image = Graphics.Image
RasterFont = require 'core/Graphics/RasterFont'
TileLayer = require 'core/Environment/2D/TileLayer'
Timing = require 'Timing'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

module.exports = class extends EnvironmentState
	
	initialize: ->
		
		@listDefer = upon.defer()
		
		@addedEntities_ = {}
		
		@main.on 'entityUpdated', ({id, position, direction, animationIndex, animationFrameIndex}) =>
			
			return unless @addedEntities_[id]
			
			@addedEntities_[id].setDirection direction
			@addedEntities_[id].setPosition position
			@addedEntities_[id].setCurrentAnimationIndex animationIndex
			@addedEntities_[id].currentAnimation().setCurrentFrameIndex animationFrameIndex
		
		@main.on 'entityAdded', ({id, traits}) =>
			
			@listDefer.then =>
				
				Entity.load('/entity/wb-dude.entity.json').then (entity) =>
					
					@addedEntities_[id] = entity
			
					entity.extendTraits traits
					
					entity.reset()
					
					new Entity.DisplayCommand(
						@displayList
						entity
					)
				
		super
	
	enter: (args) ->
		
		Box2D.world = new Box2D.b2World new Box2D.b2Vec2(0, 0), false
		
		environmentPromise = super args
		
		upon.all([
			
			environmentPromise
				
			Entity.load('/entity/wb-dude.entity.json').then (@entity) =>
				
				@main.entity = @entity
				
				# Start the entity at 150, 150.
				@entity.extendTraits [
					type: 'Existence'
					state:
						x: 150
						y: 150
				]
				
				# Facing down.
				@entity.setDirection 2
				
				@entity.reset()
				
			RasterFont.load('/font/wb-text.png').then (@font) =>
			
		]).then =>
			
#			@entity.on 'positionChanged', => @main.emit 'entityUpdated'
#			@entity.on 'directionChanged', => @main.emit 'entityUpdated'
			
			# Add a display command to white out the background.
			new Image.FillDisplayCommand(
				@displayList
				80, 80, 80, 255
				@roomRectangle
			)
			
			new TileLayer.DisplayCommand(
				@displayList
				@currentRoom.layer 0
				@environment.tileset()
				@roomRectangle
			) 
			
			new TileLayer.DisplayCommand(
				@displayList
				@currentRoom.layer 1
				@environment.tileset()
				@roomRectangle
			) 
			
			new Entity.DisplayCommand(
				@displayList
				@entity
			)
			
			@listDefer.resolve()
			
			###
			
			new TileLayer.DisplayCommand(
				@displayList
				@currentRoom.layer 2
				@environment.tileset()
				@roomRectangle
			)
			
			new TileLayer.DisplayCommand(
				@displayList
				@currentRoom.layer 3
				@environment.tileset()
				@roomRectangle
			)
			
			###
			
			@tps = new RasterFont.DisplayCommand(
				@displayList
				@font
				"TPS: 0"
				[16, 32]
			)
			@tps.setIsRelative false
		
			@rps = new RasterFont.DisplayCommand(
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
			Graphics.window.on 'mouseButtonDown.2DTopdownEnvironmentState', ({button, x, y}) =>
				return unless button is Graphics.Window.LeftButton
				@clicking = true
				[x, y] = Vector.mul(
					[x, y]
					Vector.div Graphics.window.originalSize, Graphics.window.size()
				)
				@mousePosition = [x, y]
			Graphics.window.on 'mouseButtonUp.2DTopdownEnvironmentState', ({button}) =>
				return unless button is Graphics.Window.LeftButton
				@clicking = false
			Graphics.window.on 'mouseMove.2DTopdownEnvironmentState', ({x, y}) =>
				[x, y] = Vector.mul(
					[x, y]
					Vector.div Graphics.window.originalSize, Graphics.window.size()
				)
				@mousePosition = [x, y]
		
	tick: ->
		
		if world = Box2D.world
			world.Step 1 / Timing.ticksPerSecondTarget, 8, 3
		
		@entity.tick()
		
		# Update our counters.
		@tps.setText "TPS: #{@main.ticksPerSecond.count()}"
		@rps.setText "RPS: #{@main.rendersPerSecond.count()}"
		
		actuallyMoved = false
		
		# Any key/joystick movement input?
		unless Vector.isZero (
			movement = Graphics.graphicsService.playerUnitMovement('Awesome player')
		)
			actuallyMoved = true
			@entity.move movement, true   

		# Mouse clicking?
		if @clicking and 2 < Vector.cartesianDistance(
			Vector.add @mousePosition, @displayList.position()
			@entity.position()
		)
			actuallyMoved = true
			@entity.move Vector.add @mousePosition, @displayList.position()
		
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
		Graphics.window.off '.2DTopdownEnvironmentState'
		