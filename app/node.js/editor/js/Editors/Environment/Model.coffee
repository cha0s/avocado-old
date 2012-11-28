requires_['Persea/Editor/Environment/Model'] = (module, exports) ->

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
			
	Model.loadSubject = (uri) -> require(
		'core/Environment/2D/Environment'
	).load uri
