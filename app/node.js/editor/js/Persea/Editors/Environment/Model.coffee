
	module.exports = Model = Backbone.Model.extend
		
		initialize: ({
			@subject
		})->
			
			# Keep URI in sync with Model.id
			@on 'change:id', => @subject.setUri @get 'id'
			@id = @subject.uri()
			
			# Metadata for editing.
			@offset = [0, 0]
			@currentRoomIndex = 0
			
		currentRoom: -> @subject.room @currentRoomIndex
		
		basename: ->
			basename = @id.match /.*\/([^.]+)\.environment\.json/
			basename[1]
		
		name: -> @subject.name()
	
	Model.loadSubject = (uri) -> require(
		'core/Environment/2D/Environment'
	).load uri
