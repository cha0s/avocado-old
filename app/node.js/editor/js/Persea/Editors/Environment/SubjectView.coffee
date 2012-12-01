
	Graphics = require 'Graphics'
	Image = Graphics.Image
	
	DisplayList = require 'core/Graphics/DisplayList'
	Rectangle = require 'core/Extension/Rectangle'
	Swipey = require 'Swipey'
	TileLayer = require 'core/Environment/2D/TileLayer'
	Vector = require 'core/Extension/Vector'
	
	module.exports = Backbone.View.extend
		
		initialize: ->
			
			@changeSubject null
		
			###
			
			taps = 0
			compoundTapEvent = _.debounce(
				=>
					switch taps
						when 2
							$(@subjectCanvas.Canvas).trigger 'doubletap'
						when 3
							$(@subjectCanvas.Canvas).trigger 'tripletap'
						
					taps = 0
				300
			)
			
			$(@subjectCanvas.Canvas).on
				
				mousedown: (event) =>
					
					taps += 1
					compoundTapEvent()
					
					true
					
			$(@subjectCanvas.Canvas).css
				cursor: 'move'
			
			###
			
			$(window).resize _.throttle(
				=> @changeSubject @model
				1000
			)
			
			@$canvas = $ '<div class="canvas">'
			
			@swipey = new Swipey @$canvas
			@swipey.on 'update', (offset) =>
				
				tileSize = @environment.tileset().tileSize()
				
				@displayList.setPosition Vector.mul(
					Vector.round offset
					tileSize
				) 
				@render()
			
			@subjectCanvas = new Graphics.Image [1, 1]
			@$canvas.append @subjectCanvas.Canvas
			
			@$el.append @$canvas
			
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
		
		resizeCanvas: ->
			
			currentRoom = @model.currentRoom()
			
			roomRectangle = Rectangle.compose(
				[0, 0]
				Vector.mul(
					currentRoom.size()
					@environment.tileset().tileSize()
				)
			)
			
			# Resize the canvas and notify any listeners.
			calculatedCanvasSize = Vector.min(
				@canvasSize()
				Rectangle.size roomRectangle
			)
			
			@subjectCanvas.Canvas.width = calculatedCanvasSize[0]
			@subjectCanvas.Canvas.height = calculatedCanvasSize[1]
			
			@trigger 'canvasSizeRecalculated', calculatedCanvasSize
			
			# Start a new display list
			@displayList = new DisplayList(
				Rectangle.compose [0, 0], calculatedCanvasSize
				roomRectangle
			)				
			
			# with background color,
			new Image.FillDisplayCommand(
				@displayList
				68, 68, 102, 255
				roomRectangle
			)
			
			# ###
			
			# and 4 layers
			# TODO dynamic layer count.
			@tileLayerCommands = []
			for i in [0...4]
				@tileLayerCommands[i] = new TileLayer.DisplayCommand(
					@displayList
					currentRoom.layer i
					@environment.tileset()
					roomRectangle
					calculatedCanvasSize
				) 
			
			# ###
			
			@swipey.setMinMax(
				[0, 0]
				Vector.sub(
					@model.currentRoom().size()
					Vector.div(
						calculatedCanvasSize
						@environment.tileset().tileSize()
					)
				)
			)
			
		changeSubject: (@model) ->
			
			@trigger 'windowTitleChanged'
		
			# Don't show anything for a null model.
			@$el.hide()
			return unless @model?
			
			@environment = @model.subject
			
			@resizeCanvas()
			
			@$el.show()
			
			if '' is title = @model.name()
				title = @model.id
			else
				title += " (#{@model.id})"
			@model.trigger 'windowTitleChanged', title
			
		render: -> @displayList.render @subjectCanvas
		
