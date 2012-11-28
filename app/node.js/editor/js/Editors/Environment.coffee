requires_['Persea/Editor/Environment'] = (module, exports) ->
	
	Model = require 'Persea/Editor/Environment/Model'
	Collection = require 'Persea/Editor/Environment/Collection'
	SubjectView = require 'Persea/Editor/Environment/SubjectView'
	ThumbsView = require 'Persea/Editor/Environment/ThumbsView'
	
	Subjects = new Collection [],
		localStorage: new Store 'avocado-persea-environment'
	
	Thumbs = new ThumbsView
		id: 'environment-thumbs'
		subjects: Subjects
	
	Subject = new SubjectView
		id: 'environment-subject'
	
	Thumbs.on 'subjectChanged', (model) ->
		Subject.changeSubject model
		
		if '' is title = model.name()
			title = model.id
		else
			title += " (#{model.id})"
		
		Subjects.trigger 'windowTitleChanged', title

	Subject.on 'canvasSizeRecalculated', (calculatedCanvasSize) ->
		Thumbs.setCanvasWidth calculatedCanvasSize[0]
	
	exports.loadSubject = (uri) ->
		
		Model.loadSubject(uri).then (subject) =>
			model = new Model subject: subject
			Subjects.add model
			
			Thumbs.trigger 'subjectChanged', model
	
	exports.Subjects = Subjects
	