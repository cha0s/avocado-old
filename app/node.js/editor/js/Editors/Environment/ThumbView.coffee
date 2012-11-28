requires_['Persea/Editor/Environment/ThumbView'] = (module, exports) ->

	module.exports = Backbone.View.extend
		
		tagName: 'li'
		className: 'subject-thumb'
		
		initialize: ->
		
			@model.bind 'change', @render, this
			
		events: click: 'showSubject'
			
		showSubject: -> @trigger 'showSubject', @model
			
		render: ->
			
			# Each thumbnail.
			# TODO: use environment.name() and fallback on basename.
			@$el.attr 'title', @model.id
			
			basename = @model.id.match /.*\/([^.]+)\.environment\.json/
			@$el.html $('<h1>').text(basename[1])
			
			this
	
