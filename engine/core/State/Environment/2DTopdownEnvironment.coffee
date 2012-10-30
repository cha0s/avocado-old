
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

PACKET_INTERVAL = 30

module.exports = class extends EnvironmentState
	
	initialize: ->
		
		@entityPosition = [150, 150]
		
		super
	
	enter: (args) ->
		
		Box2D.world = new Box2D.b2World new Box2D.b2Vec2(0, 0), false
		
		environmentPromise = super args
		
		entityDefer = upon.defer()
		
		environmentPromise.then =>
		
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
			
			Entity.load('/entity/wb-dude.entity.json').then (@entity) =>
					
				@main.socket.on 'worldUpdate', (entity) =>
					@entityPosition = entity.position
					
				@entity.setPosition [150, 150]
				
				new Entity.DisplayCommand(
					@displayList
					@entity
				)
				
				@entity.reset()
				
				entityDefer.resolve()
		
		upon.all([
			
			environmentPromise
			
			entityDefer.promise
			
			RasterFont.load('/font/wb-text.png').then (@font) =>
			
		]).then =>
			
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
			
	tick: ->
		
		return unless @entity?
		
		if world = Box2D.world
			world.Step 1 / Timing.ticksPerSecondTarget, 8, 3
		
		@entity.tick()
		
		unitMovement = Graphics.graphicsService.playerUnitMovement('Awesome player')
		
		# Any key/joystick movement input?
		unless Vector.isZero (
			unitMovement
		)
			@entity.move unitMovement, null, true   
			@entity.emit 'startedMoving' unless @entity.isMoving()
			
		else
		
			@entity.emit 'stoppedMoving' if @entity.isMoving()
		
		@entity.setPosition @lerp @entityPosition, @entity.position()
		
		# Update our counters.
		@tps.setText "TPS: #{@main.ticksPerSecond.count()}"
		@rps.setText "RPS: #{@main.rendersPerSecond.count()}"
		
		@setCamera @entity.position()
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		super
		
		# Remove our event handler(s).
		Graphics.window.off '.2DTopdownEnvironmentState'
		