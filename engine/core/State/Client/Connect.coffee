# Avocado loads the 'Initial' state, and from there it's all up to you!

AbstractState = require 'core/State/AbstractState'
GlobalConfig = require 'core/GlobalConfig'
Entity = require 'core/Entity/Entity'
Graphics = require 'Graphics'
upon = require 'core/Utility/upon'

changeState = null

module.exports = class extends AbstractState
	
	enter: ->
		
		@main.clients = {}
		
		@main.connect().then (connection) =>
			
			connection.on 'userLoaded', ({
				id
				uri
				traits
			}) =>
				
				Entity.load(uri).then (entity) =>
					
					entity.extendTraits(traits).then =>
					
					# Why?
					entity.reset()
					
					@main.user = entity
					@main.clients[id] =
						
						entity: entity
						serverPosition: entity.position()
					
					connection.on 'worldUpdate', ({clients}) =>
						
						@main.emit 'worldUpdate', clients
						
					connection.on 'removeConnection', ({id}) =>
						
						@main.emit 'removeConnection', id
						
					setInterval(
						=>
							
							connection.emit 'userInput',
								unitMovement: Graphics.playerUnitMovement(
									'Awesome player'
								)
							
						1000 / GlobalConfig.CLIENT_PACKET_INTERVAL
					)
					
			connection.on 'changeState', ({
				name
				args
			}) ->
				
				changeState =
					name: name
					args: args
				
			connection.emit 'userConnect', {}
			
		upon.all([
		])

	tick: ->
		
		if changeState?
			
			@main.changeState(
				changeState.name
				changeState.args
			)
			
			changeState = null
			