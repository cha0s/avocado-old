requires_['Persea/Editor/Environment/Collection'] = (module, exports) ->
	
	module.exports = Backbone.Collection.extend
		
		initialize: (models, {
			@localStorage
		}) ->
		
		model: require 'Persea/Editor/Environment/Model'
		
		# Sort by id.
		comparator: (model) -> model.id
