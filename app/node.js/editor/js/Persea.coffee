	Core = require 'Core'
	
	# Load up editors.
	# TODO Should be dynamic?
	editors = {}
	for editor in [
		'Environment'
	]
		editors[editor] = require "Persea/Editors/#{editor}"
		
	Menu = Backbone.View.extend
		
		initialize: ->
			
			# Load the menu JSON and render it.
			Core.CoreService.readJsonResource(
				'/../app/node.js/editor/data/menu/persea.json'
			).then (@menu) => @render()
		
		renderRecursive: (O) ->
			
			# Defaults...
			O.href ?= '#'
			O.title ?= O.label
			
			# Add the menu item.
			$item = $('<li>').append $('<a>').attr(
				href: O.href
				title: O.title
			).text O.label
			$item.attr 'id', O.id if O.id?
			
			# Recursively add all the children.
			if O.children?.length > 0
				$sub = $ '<ul>'
				for child in O.children
					$sub.append @renderRecursive child
				$item.append $sub
			
			$item
	        
		render: ->
			
			# Rebuild the menu.
			$menu = $ '<ul class="sf-menu">'
			for O in @menu
				$menu.append @renderRecursive O
			@$el.append $menu
			
			this
		
	Routes = Backbone.Router.extend
		
		initialize: ({
			@persea
		}) ->
	
		routes:
			
			'open': 'openSubject'
			
	exports.View = Backbone.View.extend
	
		initialize: ->
			
			# Load the menu.
			@menu = new Menu el: $ '#menu'
			
			@routes = new Routes persea: this
			
			@routes.on 'all', (name) =>
				[base, route] = name.split ':'
				
				@[route]() if @[route]
			
			# Set the first editor to environments.
			@setCurrentEditorIndex 'Environment'
		
		events:
			
			'click #editor .toggle': 'toggleEditorControls'
		
		toggleEditorControls: ->
			
			return if $('#editor .controls').is ':animated'
			
			$p = $ '#editor .toggle p'
			
			$p.text if $('#editor .controls').is ':visible' then '←' else '→'
			
			$('#editor .controls').toggle()
			
			subjects = editors[@currentEditorIndex_].subjects
			subjects.trigger 'subjectChanged', subjects.currentSubject
		
		# Manage the current editor.
		currentEditorIndex: -> @currentEditorIndex_
		setCurrentEditorIndex: (currentEditorIndex) ->
			editors[@currentEditorIndex_]?.subjects.off 'all', @render, this
			@currentEditorIndex_ = currentEditorIndex
			
			# TODO I feel like we need better event delegation.
			editors[@currentEditorIndex_].subjects.on(
				'all'
				(name, title) ->
					
					switch name
						
						when 'windowTitleChanged'
							
							titleParts = ['Persea']
							titleParts.unshift title if title?
							
							document.title = titleParts.join ' - '
							
						else
							
							@render()
				this
			)
			
		# Turn off text selection by default to make things look nicer. We'll
		# individually turn any element unselectability off on a case-by-case
		# basis.
		render: ->
			$(':not([unselectable])').each -> $(this).attr 'unselectable', 'on'
			
			this
		
		# Load a subject from a URI.
		loadSubject: (uri) ->
			editors[@currentEditorIndex_].loadSubject uri
			
		# Open a subject using a dialog.
		openSubject: ->
			uri = prompt 'URI?'
			
			@routes.navigate '/'
			
			return if '' is uri or not uri?
			
			@loadSubject uri
