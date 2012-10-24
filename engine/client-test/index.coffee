
_ = require 'core/Utility/underscore'
Main = require 'core/Main'

if io?
	socket = io.connect 'http://avocado.cha0sb0x.ath.cx'
else
	socket = require('socket.io-client').connect 'http://avocado.cha0sb0x.ath.cx'

setInterval(

	->
		return unless Main.main.entity
		
		socket.emit 'entityUpdated',
			position: Main.main.entity.position()
			direction: Main.main.entity.direction()
			animationIndex: Main.main.entity.currentAnimationIndex()
			animationFrameIndex: Main.main.entity.currentAnimation().currentFrameIndex()
		
	1000 / 30
)

socket.on 'entityAdded', (entity) ->
	
	Main.main.emit 'entityAdded', entity

socket.on 'entityUpdated', (entity) ->
	
	Main.main.emit 'entityUpdated', entity
