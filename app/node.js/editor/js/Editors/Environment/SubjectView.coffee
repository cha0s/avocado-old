requires_['Persea/Editor/Environment/SubjectView'] = (module, exports) ->

	Graphics = require 'Graphics'
	Image = Graphics.Image
	
	DisplayList = require 'core/Graphics/DisplayList'
	Rectangle = require 'core/Extension/Rectangle'
	TileLayer = require 'core/Environment/2D/TileLayer'
	Vector = require 'core/Extension/Vector'
	
	module.exports = Backbone.View.extend
		
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
			
			# TODO the 96 mask is just due to imprecise caching, code
			# simplicity is the current tradeoff, fix this eventually.
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
		
