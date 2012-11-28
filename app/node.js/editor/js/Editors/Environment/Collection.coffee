requires_['Persea/Editor/Environment/Collection'] = (module, exports) ->
	
	module.exports = Backbone.Collection.extend
		
		initialize: (models, {
			@localStorage
		}) ->
			
			@on 'subjectChanged', @changeSubject, this
		
		changeSubject: (@currentSubject) ->
		
		model: require 'Persea/Editor/Environment/Model'
		
		# Sort by id.
		comparator: (model) -> model.id
