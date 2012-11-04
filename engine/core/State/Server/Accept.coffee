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
	
	initialize: ->
		
		@environmentClients = {}
		
		super
	
	broadcast: (name, data) ->
		
		client.connection.emit name, data for id, client of clients
		
		undefined
	
	environmentClient: (uri) ->
		
		clientDefer = upon.defer()
		
		if @environmentClients[uri]?
		
			clientDefer.resolve @environmentClients[uri].client
			
		else
		
			connection = switch GlobalConfig.ENVIRONMENT_SERVER_STRATEGY
			
				when 'ipc'
				
					ipcSocket = require('core/Network/Ipc')()
					
					# Create a new server to execute the environment.
					Server = class extends (require 'core/Network/Server')
					server = new Server
						type: 'ipc'
						ipcSocket: ipcSocket
					server.changeState(
						'Server/2DTopdownEnvironment'
						environmentUri: '/environment/wb-forest.environment.json'
						roomIndex: 0
					)
					server.on 'error', (error) -> throw error
					server.begin()
					
					@main.on 'quit', -> server.quit()
					
					url: 'ipc://'
					ipcSocket: ipcSocket
					
					@environmentClients[uri] =
						client: ipcSocket
						
					server.on 'stateEntered', (stateName) =>
						if stateName is 'Server/2DTopdownEnvironment'
							clientDefer.resolve @environmentClients[uri].client
		
		clientDefer.promise
	
	connectionId = 1
	newConnectionId: -> '' + connectionId++
	
	enter: ->
		
		@main.listen (connection) =>
			
			connection.on 'userConnect', (data) =>
				
				id = @newConnectionId()
				
				@environmentClient(
					'/environment/wb-forest.environment.json'
				).then (environmentClient) =>
					
					client = clients[id] =
						environmentClient: environmentClient
						connection: connection
					
					connection.on 'disconnect', =>
						return unless clients[id]?
						
						@broadcast 'removeConnection', id: id
						client.environmentClient.emit 'removeConnection', id: id
						
						delete clients[id]
					
					connection.on 'clientInput', (input) ->
						
						client.environmentClient.emit 'clientInput',
							id: id
							input: input
					
					client.environmentClient.on "worldUpdate-#{id}", (worldUpdate) ->
						
						connection.emit 'worldUpdate', worldUpdate
						
					client.environmentClient.on 'environmentUserLoaded', ({
						id
						uri
						traits
					}) ->
						
						connection.emit 'userLoaded',
							
							uri: uri
							traits: traits
							id: id
							
						connection.emit 'changeState',
							
							name: 'Client/2DTopdownEnvironment'
							args:
								environmentUri: '/environment/wb-forest.environment.json'
								roomIndex: 0
								
					client.environmentClient.emit 'clientEntered',
						
						id: id
				
		upon.all([
		])
		
	tick: ->
		
		if updateTicker.ticks() > 0
			for id, client of clients
				client.environmentClient.emit 'environmentWorldUpdate', id: id
				
		undefined
