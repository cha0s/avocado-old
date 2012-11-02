# Avocado loads the 'Initial' state, and from there it's all up to you!

AbstractState = require 'core/State/AbstractState'
Entity = require 'core/Entity/Entity'
GlobalConfig = require 'core/GlobalConfig'
Graphics = require 'Graphics'
Ticker = require 'core/Timing/Ticker'
Timing = require 'Timing'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

clients = {}

updateTicker = new Ticker 1000 / GlobalConfig.SERVER_PACKET_INTERVAL

module.exports = class extends AbstractState
	
	broadcast: (name, data) ->
		
		client.connection.emit name, data for id, client of clients
	
	worldUpdateForClient: (clientToUpdate) ->
	
		clientToUpdate.connection.emit 'worldUpdate'
			
			clients: for id, client of clients
				
				direction: client.entity.direction()
				position: client.entity.position()
				moving: not Vector.isZero client.userInput.unitMovement
				id: id
	
	connectionId = 1
	newConnectionId: -> connectionId++
	
	enter: ->
		
		@main.listen (connection) =>
			
			connection.on 'userConnect', (data) =>
				
				uri = data.uri ? '/entity/wb-dude.entity.json'
				traits = [
					type: 'Existence'
					state:
						x: 150
						y: 150
						direction: 2
				]
				id = @newConnectionId()
				
				connection.on 'disconnect', =>
					return unless clients[id]?
					
					@broadcast 'removeConnection', id: id
					
					delete clients[id]
					
				Entity.load(uri).then (entity) =>
					
					entity.extendTraits(traits).then =>
					
					# Why?
					entity.reset()
					
					client = clients[id] =
						
						connection: connection
						entity: entity
					
					connection.on 'userInput', (userInput) ->
						
						client.userInput = userInput
						
					connection.emit 'userLoaded',
						
						uri: uri
						traits: traits
						id: id
		
					connection.emit 'changeState',
						
						name: 'Client/2DTopdownEnvironment'
						args:
							environmentUri: '/environment/wb-forest.environment.json'
							roomIndex: 0
		
		upon.all([
		])
		
	tick: ->
		
		for id, client of clients
		
			continue if Vector.isZero client.userInput.unitMovement
			
			client.entity.move(
				client.userInput.unitMovement
				1 / Timing.ticksPerSecondTarget
				true
			)
		
		if updateTicker.ticks() > 0
			
			for id, client of clients
				
				@worldUpdateForClient client
