
EnvironmentState = require 'core/State/Environment/2DTopdownEnvironment'
Box2D = require 'core/Physics/Box2D'
Entity = require 'core/Entity/Entity'
Graphics = require 'Graphics'
Image = Graphics.Image
RasterFont = require 'core/Graphics/RasterFont'
TileLayer = require 'core/Environment/2D/TileLayer'
Timing = require 'Timing'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

module.exports = class extends EnvironmentState
	
	initialize: ->

		@main.on 'removeConnection', (id) =>
			return unless @main.clients[id]?
			
			@entityCommandList.removeEntity @main.clients[id].entity
			delete @main.clients[id]
		
		@main.on 'worldUpdate', (clients) =>
			
			@updateWorld clients
			
		super
		
	updateWorld: (clients) ->
	
		for clientInfo in clients
			
			{
				id
				moving
				position
				direction
			} = clientInfo
			
			if (client = @main.clients[id])?
				
				entity = client.entity
				
				# Handle animating the movement of other clients. Main entity
				# movement animation is handled locally.
				unless @main.user is entity
					if moving
						entity.emit 'startedMoving' unless entity.isMoving()
					else
						entity.emit 'stoppedMoving' if entity.isMoving()
				
				entity.setDirection direction
				
				# The authoritative position of this client.
				client.serverPosition = position
				
			# If we don't have this client yet, create a new record for it.
			else
				@main.clients[id] = {}
				
				traits = [
					type: 'Existence'
					state:
						x: position[0]
						y: position[1]
						direction: direction
				]
				
				Entity.load('/entity/wb-dude.entity.json').then (e) =>
					
					e.extendTraits(traits).then =>
					
						# Why?
						e.reset()
						
						@main.clients[id] =
							
							entity: e
							serverPosition: position
						
						@entityCommandList.addEntity e
		
	enter: (args) ->
		
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
				
				@entityCommandList = new Entity.DisplayCommandList(
					@displayList
				)
				
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
				
				@entityCommandList.addEntity @main.user
				
			RasterFont.load('/font/wb-text.png').then (@font) =>
			
		])
			
	tick: ->
		
		super
		
		unitMovement = Graphics.playerUnitMovement('Awesome player')
		
		# Any key/joystick movement input?
		unless Vector.isZero (
			unitMovement
		)
#			@main.user.move unitMovement, null, true   
			@main.user.emit 'startedMoving' unless @main.user.isMoving()
			
			mainEasing = 0
			
		else
		
			@main.user.emit 'stoppedMoving' if @main.user.isMoving()
			
			mainEasing = 0
			
		for id, client of @main.clients
			
			oldPosition = Vector.round client.entity.position()
			
			client.entity.setPosition @lerp(
				client.serverPosition
				client.entity.position()
				if @main.user is client.entity
					mainEasing
				else
					.25
			)
			
		@setCamera @main.user.position()
