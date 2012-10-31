# Avocado loads the 'Initial' state, and from there it's all up to you!

AbstractState = require 'core/State/AbstractState'
Entity = require 'core/Entity/Entity'
GlobalConfig = require 'core/GlobalConfig'
Graphics = require 'Graphics'
upon = require 'core/Utility/upon'

entities = []

module.exports = class extends AbstractState
	
	enter: ->
		
		@main.listen (connection) ->
			
			connection.on 'userConnect', (data) ->
				
				uri = data.uri ? '/entity/wb-dude.entity.json'
				traits = [
					type: 'Existence'
					state:
						x: 150
						y: 150
						direction: 2
				]
				
				Entity.load(uri).then (entity) =>
					
					entity.extendTraits(traits).then =>
					
					# Why?
					entity.reset()
					
					entities.push entity
					
					connection.on 'userInput', ({unitMovement}) ->
						
						entity.move(
							unitMovement
							1 / GlobalConfig.CLIENT_PACKET_INTERVAL
							true
						)
						
					setInterval(
						
						->
							
							connection.emit 'worldUpdate'
								clients: for entity in entities
									position: entity.position()
						
						1000 / GlobalConfig.SERVER_PACKET_INTERVAL
					)
					
					connection.emit 'userLoaded',
						
						uri: uri
						traits: traits
		
		upon.all([
		])
