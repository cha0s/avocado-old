requires_['Persea/Editor/Environment/ThumbView'] = (module, exports) ->

	module.exports = Backbone.View.extend
		
		tagName: 'li'
		className: 'subject-thumb'
		
		initialize: ->
		
			@model.bind 'change', @render, this
			
		events:
			
			click: 'changeSubject'
			
		changeSubject: -> @trigger 'subjectChanged', @model
			
		render: ->
			
			# Each thumbnail.
			# TODO: use environment.name() and fallback on basename.
			@$el.attr 'title', @model.id
			
			title = @model.subject.name()
			if '' is title 
				basename = @model.id.match /.*\/([^.]+)\.environment\.json/
				title = basename[1]
			@$el.html $('<h1>').text title
			
			this
	
