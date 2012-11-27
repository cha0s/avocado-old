requires_['Persea/Editor/Environment'] = (module, exports) ->
	
	Graphics = require 'Graphics'
	
	DisplayList = require 'core/Graphics/DisplayList'
	Dom = require 'core/Utility/Dom'
	Editor = require 'Persea/Editor'
	Image = Graphics.Image
	Rectangle = require 'core/Extension/Rectangle'
	TileLayer = require 'core/Environment/2D/TileLayer'
	Vector = require 'core/Extension/Vector'
	
	exports.Model = Environment = Backbone.Model.extend
		
		initialize: ->
			
			# Metadata for editing.
			@offset = [0, 0]
			@currentRoomIndex = 0
			
		setSubject: (@environment) ->
			
			# Keep URI in sync with Model.id
			@on 'change:id', => @environment.setUri @get 'id'
			@id = @environment.uri()
			
		currentRoom: -> @environment.room @currentRoomIndex
			
	exports.Model.loadSubject = (uri) -> require(
		'core/Environment/2D/Environment'
	).load uri
	
	exports.Collection = Backbone.Collection.extend
		
		model: Environment
		
		localStorage: new Store 'avocado-persea-environment'
		
		# Sort by id (URI).
		comparator: (model) -> model.id
	
	exports.Subjects = new exports.Collection
	
	exports.ThumbsView = Backbone.View.extend
		
		tagName: 'ul'
		
		initialize: ->
			
			@canvasWidth = 'auto'
		
			# Allow swiping through thumbnails when they can't all fit.
			@$thumbs = $ '#subject-thumbs'
			(@$thumbsContainer = $ '#subject-thumbs-container').on
				mousedown: => @$thumbs.stop()
				swipeleft: (e, delta) => @handleSwipe delta, '-'
				swiperight: (e, delta) => @handleSwipe delta, '+'
			
			exports.Subjects.bind 'add reset remove', @render, this
			
			@$thumbs.append @el
			
		setCanvasWidth: (@canvasWidth) -> @render()
		
		handleSwipe: (delta, op) ->
			
			# nop if the thumbnails fit.
			return unless @$thumbs.width() > @$thumbsContainer.width()
			
			# Exponential swipe delta.
			delta = Math.abs delta.end.coords[0] - delta.start.coords[0] - 30
			delta = Math.pow delta, 1.1
			
			# Calculate the offset destination.
			offsetDestination = @$thumbs.css 'left'
			offsetDestination = parseInt offsetDestination.substr 0, offsetDestination.length - 2
			offsetDestination = switch op
				when '+' then offsetDestination + delta
				when '-' then offsetDestination - delta
			offsetDestination = Math.max(
				-(@$thumbs.width() - @$thumbsContainer.width()) + 20
				Math.min(
					0
					offsetDestination
				)
			)
			
			# Animate to the offset.
			@$thumbs.animate(
				left: offsetDestination
			,
				1500
				'easeOutExpo'
			)
			
		render: ->
			
			# Thumbnail bar.
			@$el.empty()
			exports.Subjects.each (environment) =>
				view = new ThumbView model: environment
				view.on 'showSubject', (model) => @trigger 'showSubject', model
				@$el.append view.render().el
	
			# Calculate width of all elements, stop animating, and reset
			# offset.
			@$thumbsContainer.css 'width', @canvasWidth
			@$thumbs.css 'width', _.reduce(
				$('.subject-thumb', @$thumbs)
				(l, r) -> l + Dom.outerWidth r, true
				0
			)
			@$thumbs.stop()
			@$thumbs.css 'left', 0

				
	exports.ThumbView = ThumbView = Backbone.View.extend
		
		tagName: 'li'
		className: 'subject-thumb'
		
		initialize: ->
		
			@model.bind 'change', @render, this
#			@model.bind 'destroy', @remove, this
			
		events: click: 'showSubject'
			
		showSubject: -> @trigger 'showSubject', @model
			
		render: ->
			
			# Each thumbnail.
			# TODO: use environment.name() and fallback on basename.
			@$el.attr 'title', @model.id
			
			basename = @model.id.match /.*\/([^.]+)\.environment\.json/
			@$el.html $('<h1>').text(basename[1])
			
			this
	
	exports.Thumbs = new exports.ThumbsView
		id: 'environment-thumbs'
		
	currentRoom = null
		
	exports.SubjectView = Backbone.View.extend
		
		initialize: ->
			
			@calculatedCanvasSize = [0, 0]
			@canvas = new Graphics.Image [1, 1]
			@showSubject null
			
			$(window).resize _.throttle(
				=> @showSubject @model
				1000
			)
			
			@$el.append @$canvas = $('<div class="canvas">').append @canvas.Canvas
			@$el.append @$ySlider = $('<div class="y-slider">').slider
				orientation: 'vertical'
			@$el.append @$xSlider = $('<div class="x-slider">').slider()
			
			$('#subject').append @$el
			
		canvasSize: ->
		
			# Start with the window size.
			size = [$(window).width(), $(window).height()]
			
			# Subtract the offset.
			{left, top} = $('#subject').offset()
			size = Vector.sub size, [left, top]
			
			# Give it some padding.
			size = Vector.sub size, [32, 32]
			
			# If the editor's showing, subtract its width.
			if $('#editor .controls').is ':visible'			
				size[0] -= $('#editor').outerWidth() 
			
			# TODO the 96 mask is just due to imprecise caching, the code
			# simplicity is the current tradeoff, fix this.
			Vector.mul(
				Vector.floor Vector.div(
					size
					[96, 96]
				)
				[96, 96]
			)
			
		showSubject: (@model, render = true) ->
			
			# Don't show anything for a null model.
			@$el.hide()
			return unless @model?
			
			@environment = @model.environment
			currentRoom = @model.currentRoom()
			
			roomRectangle = Rectangle.compose(
				[0, 0]
				Vector.mul(
					currentRoom.size()
					@environment.tileset().tileSize()
				)
			)
			
			# Resize the canvas and notify any listeners.
			@calculatedCanvasSize = Vector.min(
				@canvasSize()
				Rectangle.size roomRectangle
			)
			@canvas.Canvas.width = @calculatedCanvasSize[0]
			@canvas.Canvas.height = @calculatedCanvasSize[1]
			@trigger 'canvasSizeRecalculated', @calculatedCanvasSize
			
			# Start a new display list
			@displayList = new DisplayList(
				Rectangle.compose [0, 0], @calculatedCanvasSize
				roomRectangle
			)				
			
			# with background color,
			new Image.FillDisplayCommand(
				@displayList
				68, 68, 102, 255
				roomRectangle
			)
			
			# and 4 layers
			# TODO dynamic layer count.
			@tileLayerCommands = []
			for i in [0...4]
				@tileLayerCommands[i] = new TileLayer.DisplayCommand(
					@displayList
					currentRoom.layer i
					@environment.tileset()
					roomRectangle
					@calculatedCanvasSize
				) 
			
			@recalculateSliders()
			
			@render() if render
			
			@$el.show()
		
		recalculateSliders: ->
			
			canvasSize = @calculatedCanvasSize
			currentRoom = @model.currentRoom()
			tileSize = @environment.tileset().tileSize()
			
			# Some magic to DRY up both axes. The max - ... stuff is due to
			# jQuery UI making 0 the bottom of vertical sliders.
			css = ['width', 'height']
			$sliders = [@$xSlider, @$ySlider]
			max = (i) -> currentRoom.width() - canvasSize[i] / tileSize[i]
			offset = (i, ui) ->
				[
					ui.value
					max(1) - ui.value
				][i]
			position = (i) =>
				[
					[
						@model.offset[0] * tileSize[0]
						@displayList.position()[1]
					]
					[
						@displayList.position()[0]
						@model.offset[1] * tileSize[1]
					]
				][i]
			value = (i) =>
				[
					@model.offset[i]
					max(1) - @model.offset[i]
				][i]
			@displayList.setPosition Vector.mul @model.offset, tileSize
			
			for i in [0...2]
				
				# Don't show unusable sliders.
				if 0 is max i
					$sliders[i].hide()
					continue
				else
					$sliders[i].show()
				
				((i) =>
					
					$sliders[i].css css[i], canvasSize[i] - 24
					$sliders[i].slider(
						'option'
							min: 0
							max: max i
							value: value i
							slide: (event, ui) =>
								@model.offset[i] = offset i, ui
								@displayList.setPosition position i
								@render()
					)
				) i
				
			undefined
			
		render: -> @displayList.render @canvas
		
	exports.Subject = new exports.SubjectView
		id: 'environment-subject'
	
	exports.Thumbs.on 'showSubject', (model) ->
		exports.Subject.showSubject model

	exports.Subject.on 'canvasSizeRecalculated', (calculatedCanvasSize) ->
		exports.Thumbs.setCanvasWidth calculatedCanvasSize[0]
