
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
		
		@main.user.serverPosition = [150, 150]
		
		super
	
	enter: (args) ->
		
		Box2D.world = new Box2D.b2World new Box2D.b2Vec2(0, 0), false
		
		upon.all([
			
			(super args).then =>
			
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
					@main.user
				)
			
			RasterFont.load('/font/wb-text.png').then (@font) =>
			
		])
			
	tick: ->
		
		if world = Box2D.world
			world.Step 1 / Timing.ticksPerSecondTarget, 8, 3
		
		@main.user.tick()
		
		unitMovement = Graphics.playerUnitMovement('Awesome player')
		
		# Any key/joystick movement input?
		unless Vector.isZero (
			unitMovement
		)
			@main.user.move unitMovement, null, true   
			@main.user.emit 'startedMoving' unless @main.user.isMoving()
			
		else
		
			@main.user.emit 'stoppedMoving' if @main.user.isMoving()
		
		@main.user.setPosition @lerp @main.user.serverPosition, @main.user.position()
		
		@setCamera @main.user.position()
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		super
		
		# Remove our event handler(s).
		Graphics.window.off '.2DTopdownEnvironmentState'
		