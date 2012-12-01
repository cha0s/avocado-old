	
	Collection = require 'Persea/Editors/Environment/Collection'
	EditorView = require 'Persea/Editors/Environment/EditorView'
	Model = require 'Persea/Editors/Environment/Model'
	SubjectView = require 'Persea/Editors/Environment/SubjectView'
	ThumbsView = require 'Persea/Editors/Environment/ThumbsView'
	
	Subjects = new Collection [],
		localStorage: new Store 'avocado-persea-environment'
	
	Editor = new EditorView
		id: 'environment-editor'
	
	Subject = new SubjectView
		id: 'environment-subject'
	
#	$(Subject.canvas.Canvas).on
#		
#		click: -> alert 'hey'
	
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
	