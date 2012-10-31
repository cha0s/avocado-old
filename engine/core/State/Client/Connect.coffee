# Avocado loads the 'Initial' state, and from there it's all up to you!

AbstractState = require 'core/State/AbstractState'
GlobalConfig = require 'core/GlobalConfig'
Entity = require 'core/Entity/Entity'
Graphics = require 'Graphics'
upon = require 'core/Utility/upon'

module.exports = class extends AbstractState
	
	enter: ->
		
		userLoadedDefer = upon.defer()
		
		@main.connect().then (connection) =>
			
			connection.on 'userLoaded', ({uri, traits}) =>
				
				Entity.load(uri).then (entity) =>
					
					entity.extendTraits(traits).then =>
					
					# Why?
					entity.reset()
					
					@main.user = entity
					
					connection.on 'worldUpdate', ({clients}) =>
					
						entity.serverPosition = clients[0].position
						
					setInterval(
						=>
							
							connection.emit 'userInput',
								unitMovement: Graphics.playerUnitMovement(
									'Awesome player'
								)
							
						1000 / GlobalConfig.CLIENT_PACKET_INTERVAL
					)
					
					userLoadedDefer.resolve()
					
			connection.emit 'userConnect', {}
			
		userLoadedDefer.promise
	
	tick: ->
		
		@main.changeState(
			'Environment/2DTopdownEnvironment'
			environmentUri: '/environment/wb-forest.environment.json'
			roomIndex: 0
		)
