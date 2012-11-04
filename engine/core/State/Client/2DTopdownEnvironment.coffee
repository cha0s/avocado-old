
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
		
		@lastMovement = 0

		@main.on 'removeConnection', (id) =>
			return unless @main.clients[id]?
			
			@entityCommandList.removeEntity @main.clients[id].entity
			delete @main.clients[id]
		
		@environmentLoaded = false 
		
		@main.on 'worldUpdate', (clients) =>
			
			@updateWorld clients if @environmentLoaded
			
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
				
				# The authoritative position of this client.
				client.serverPosition = position
				
				entity = client.entity
				
				continue unless entity?
				
				# Handle animating the movement of other clients. Main entity
				# movement animation is handled locally.
				unless @main.id is id
					if moving
						entity.emit 'startedMoving' unless entity.isMoving()
					else
						entity.emit 'stoppedMoving' if entity.isMoving()
				
				entity.setDirection direction
				
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
				
				loadEntity = (id) =>
				
					Entity.load(
						'/entity/wb-dude.entity.json'
						world: @world
					).then (e) =>
						
						e.extendTraits(
							traits
							world: @world
						).then =>
							
							# Why?
							e.reset()
							
							@main.clients[id] =
								
								entity: e
								serverPosition: position
							
							@entityCommandList.addEntity e
							
				loadEntity id
		
	enter: (args) ->
		
		@environmentLoaded = false
		
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
				
				@environmentLoaded = true 
				
			RasterFont.load('/font/wb-text.png').then (@font) =>
			
		])
			
	tick: ->
		
		super
		
		for id, client of @main.clients
			
			continue unless client.entity?
			
			client.entity.tick()
				
			if @main.id is id
				
				unitMovement = Graphics.playerUnitMovement('Awesome player')
				
				# Any key/joystick movement input?
				unless Vector.isZero (
					unitMovement
				)
#					client.entity.move unitMovement, null, true   
					client.entity.emit 'startedMoving' unless client.entity.isMoving()
					
#					mainEasing = 15
					mainEasing = .25
					
					@lastMovement = Timing.TimingService.elapsed()
					
				else
				
					client.entity.emit 'stoppedMoving' if client.entity.isMoving()
					
					if Timing.TimingService.elapsed() - @lastMovement > .5
					
#						mainEasing = 1
						mainEasing = .25
						
					else
						
#						mainEasing = 4
						mainEasing = .25
						
			client.entity.setPosition @lerp(
				client.serverPosition
				client.entity.position()
				if @main.id is id
					mainEasing
				else
					.25
			)
			
			if @main.id is id
				
				@setCamera client.entity.position()

			
