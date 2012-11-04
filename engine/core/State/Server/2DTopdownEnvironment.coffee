
Entity = require 'core/Entity/Entity'
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
		
		@clients = {}
		
		super
	
	worldUpdateForClient: (idToUpdate) ->
	
		clients: for id, client of @clients
			
			direction: client.entity.direction()
			position: client.entity.position()
			moving: not Vector.isZero client.input.unitMovement
			id: id
	
	enter: (args) ->
		
		(super args).then =>
			
			@main.listen (connection) =>
				
				connection.on 'clientEntered', ({
					id
				}) =>
					
					uri = '/entity/wb-dude.entity.json'
					traits = [
						type: 'Existence'
						state:
							x: 150
							y: 150
							direction: 2
					]
					
					Entity.load(
						uri
						world: @world
					).then (entity) =>
						entity.extendTraits(
							traits
							world: @world
						).then =>
						entity.reset()
						
						@clients[id] =
							
							entity: entity
							input:
								unitMovement: [0, 0]
								
						connection.emit 'environmentUserLoaded',
							id: id
							uri: uri
							traits: traits
							
				connection.on 'clientInput', ({
					id
					input
				}) =>
					
					@clients[id].input = input
				
				connection.on 'removeConnection', ({
					id
				}) =>
					return unless @clients[id]?
					
					delete @clients[id]
				
				connection.on 'environmentWorldUpdate', ({
					id
				}) =>
					
					connection.emit "worldUpdate-#{id}",
					
						@worldUpdateForClient id
			
	tick: ->
		
		super
		
		for id, client of @clients
			client.entity.tick()
			
			continue if Vector.isZero client.input.unitMovement
			
			client.entity.move(
				client.input.unitMovement
				1 / Timing.ticksPerSecondTarget
				true
			)
