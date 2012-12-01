	
	Collection = require 'Persea/Editors/Environment/Collection'
	EditorView = require 'Persea/Editors/Environment/EditorView'
	Model = require 'Persea/Editors/Environment/Model'
	SubjectView = require 'Persea/Editors/Environment/SubjectView'
	ThumbsView = require 'Persea/Editors/Environment/ThumbsView'
	
	subjects = new Collection [],
		localStorage: new Store 'avocado-persea-environment'
	
	subject = new SubjectView
		id: 'environment-subject'
	
	editor = new EditorView
		id: 'environment-editor'
		$canvas: subject.$canvas
	
	subjects.on 'subjectChanged', (model) ->
		
		if model?
			editor.setModel model
			$('#editor').show()
		else
			$('#editor').hide()

		subject.changeSubject model
		
	Thumbs = new ThumbsView
		id: 'environment-thumbs'
		subjects: subjects
	
	subject.on 'canvasSizeRecalculated', (canvasSize) ->
		
		editor.setCanvasSize canvasSize
		Thumbs.setCanvasWidth canvasSize[0]
	
	exports.loadSubject = (uri) ->
		
		Model.loadSubject(uri).then (subject) =>
			model = new Model subject: subject
			subjects.add model
			subjects.trigger 'subjectChanged', model
	
	exports.subjects = subjects
