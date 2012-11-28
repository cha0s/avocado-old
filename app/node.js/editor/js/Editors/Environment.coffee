requires_['Persea/Editor/Environment'] = (module, exports) ->
	
	Collection = require 'Persea/Editor/Environment/Collection'
	Model = require 'Persea/Editor/Environment/Model'
	SubjectView = require 'Persea/Editor/Environment/SubjectView'
	ThumbsView = require 'Persea/Editor/Environment/ThumbsView'
	
	Subjects = new Collection [],
		localStorage: new Store 'avocado-persea-environment'
	
	Subject = new SubjectView
		id: 'environment-subject'
	
	Subjects.on 'subjectChanged', (model) ->
		Subject.changeSubject model

	Thumbs = new ThumbsView
		id: 'environment-thumbs'
		subjects: Subjects
	
	Subject.on 'canvasSizeRecalculated', (calculatedCanvasSize) ->
		Thumbs.setCanvasWidth calculatedCanvasSize[0]
	
	exports.loadSubject = (uri) ->
		
		Model.loadSubject(uri).then (subject) =>
			model = new Model subject: subject
			Subjects.add model
			Subject.changeSubject model
	
	exports.Subjects = Subjects
	