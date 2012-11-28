requires_['Persea/Editor/Environment'] = (module, exports) ->
	
	Collection = require 'Persea/Editor/Environment/Collection'
	EditorView = require 'Persea/Editor/Environment/EditorView'
	Model = require 'Persea/Editor/Environment/Model'
	SubjectView = require 'Persea/Editor/Environment/SubjectView'
	ThumbsView = require 'Persea/Editor/Environment/ThumbsView'
	
	Subjects = new Collection [],
		localStorage: new Store 'avocado-persea-environment'
	
	Editor = new EditorView
		id: 'environment-editor'
	
	Subject = new SubjectView
		id: 'environment-subject'
	
	$(Subject.canvas.Canvas).on
		
		click: -> alert 'hey'
	
	Subjects.on 'subjectChanged', (model) ->
		Subject.changeSubject model
		
		if model?
			Editor.setModel model
			$('#editor').show()
		else
			$('#editor').hide()

	Thumbs = new ThumbsView
		id: 'environment-thumbs'
		subjects: Subjects
	
	Subject.on 'canvasSizeRecalculated', (calculatedCanvasSize) ->
		Thumbs.setCanvasWidth calculatedCanvasSize[0]
	
	exports.loadSubject = (uri) ->
		
		Model.loadSubject(uri).then (subject) =>
			model = new Model subject: subject
			Subjects.add model
			Subjects.trigger 'subjectChanged', model
	
	exports.Subjects = Subjects
	