
module.exports = Backbone.Collection.extend
	
	initialize: (models, {
		@localStorage
	}) ->
		
		@on 'subjectChanged', @changeSubject, this
	
	changeSubject: (@currentSubject) ->
	
	model: require 'Persea/Editors/Environment/Model'
	
	# Sort by id.
	comparator: (model) -> model.id
