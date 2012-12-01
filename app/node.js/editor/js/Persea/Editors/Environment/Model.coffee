
	Mixin = require 'core/Utility/Mixin'
	Transition = require 'core/Utility/Transition'
	
	module.exports = Model = Backbone.Model.extend
		
		initialize: ({
			@subject
		})->
			
			# Keep URI in sync with Model.id
			@on 'change:id', => @subject.setUri @get 'id'
			@id = @subject.uri()
			
			# Metadata for editing.
			
			
			
			# Set up an offset we can transition for nice swipe effects.
			@offset = [0, 0]
			
			@offset.x = -> @[0]
			@offset.y = -> @[1]
			@offset.setX = (x) -> @[0] = x
			@offset.setY = (y) -> @[1] = y
			
			Mixin @offset, Transition
			
			@currentRoomIndex = 0
			
		currentRoom: -> @subject.room @currentRoomIndex
		
		basename: ->
			basename = @id.match /.*\/([^.]+)\.environment\.json/
			basename[1]
		
		name: -> @subject.name()
	
	Model.loadSubject = (uri) -> require(
		'core/Environment/2D/Environment'
	).load uri
