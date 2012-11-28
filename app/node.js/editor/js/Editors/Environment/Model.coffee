requires_['Persea/Editor/Environment/Model'] = (module, exports) ->

	module.exports = Model = Backbone.Model.extend
		
		initialize: ->
			
			# Metadata for editing.
			@offset = [0, 0]
			@currentRoomIndex = 0
			
		setSubject: (@environment) ->
			
			# Keep URI in sync with Model.id
			@on 'change:id', => @environment.setUri @get 'id'
			@id = @environment.uri()
			
		currentRoom: -> @environment.room @currentRoomIndex
			
	Model.loadSubject = (uri) -> require(
		'core/Environment/2D/Environment'
	).load uri
