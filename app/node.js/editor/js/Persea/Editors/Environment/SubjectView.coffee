
Graphics = require 'Graphics'
Image = Graphics.Image

DisplayList = require 'core/Graphics/DisplayList'
Dom = require 'core/Utility/Dom'
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
			
			@$tiles.css
				top: -offset[1] * tileSize[1]
				left: -offset[0] * tileSize[0]
			
		@$el.append @$canvas
		@$canvas.append @$tiles = $ '<div class="tiles">'
		
		$('#subject').append @$el
		
	canvasSize: ->
		
		tileSize = @environment.tileset().tileSize()
	
		# Start with the window size.
		size = [$(window).width(), $(window).height()]
		
		# Subtract the offset.
		{left, top} = $('#subject').offset()
		size = Vector.sub size, [left, top]
		
		# Give it some padding.
		size = Vector.sub size, [8, 8]
		
		# If the editor's showing, subtract its width.
		if $('#editor .controls').is ':visible'			
			size[0] -= $('#editor').outerWidth() 
		
		# TODO the 96 mask is just due to imprecise caching, code
		# simplicity is the current tradeoff, fix this eventually.
		Vector.mul(
			Vector.floor Vector.div(
				size
				tileSize
			)
			tileSize
		)
	
	resizeCanvas: ->
		
		currentRoom = @model.currentRoom()
		tileSize = @environment.tileset().tileSize()
		
		roomRectangle = Rectangle.compose(
			[0, 0]
			Vector.mul(
				currentRoom.size()
				tileSize
			)
		)
		
		# Resize the canvas and notify any listeners.
		canvasSize = Vector.min(
			@canvasSize()
			Rectangle.size roomRectangle
		)
		
		@$canvas.css
			width: canvasSize[0]
			height: canvasSize[1]
		
		@trigger 'canvasSizeRecalculated', canvasSize
		
		@swipey.setMinMax(
			[0, 0]
			Vector.sub(
				@model.currentRoom().size()
				Vector.div(
					canvasSize
					@environment.tileset().tileSize()
				)
			)
		)
		
	generateRoom: ->
		
		canvasSize = [@$canvas.width(), @$canvas.height()]
		tileSize = @environment.tileset().tileSize()
		
		currentRoom = @model.currentRoom()
		
		sizeInTiles = currentRoom.size()
		
		totalTileSize = sizeInTiles[0] * sizeInTiles[1]
		
		totalRoomSize = Vector.mul sizeInTiles, tileSize
		
		@$tiles.empty()
		
		for i in [0...currentRoom.layerCount()]
		
			layer = new Image totalRoomSize
			
			((i) =>
				
				j = 0
				
				renderTile = =>
					
					y = j
					
					for x in [0...sizeInTiles[0]]
						position = Vector.mul tileSize, [x, y]
						
						index = currentRoom.layer(i).tileIndex [x, y]
						@environment.tileset().render(
							position
							layer
							index
							null
							[0, 0, 16, 16]
						) if index
					
					j += 1
					
					setTimeout(
						=> renderTile()
						10
					) if j < sizeInTiles[1]
					
				renderTile()
					
			) i
				
			@$tiles.append $(layer.Canvas).addClass 'layer'
		
		undefined
		
	changeSubject: (model) ->
		
		@trigger 'windowTitleChanged'
	
		# Don't show anything for a null model.
		unless model?
			@model = model
			@$el.hide()
			return
		
		roomHasChanged = model.currentRoom() isnt @model?.currentRoom()
		
		@environment = model.subject
		
		@model = model
		
		@resizeCanvas()
		
		@generateRoom() if roomHasChanged
		
		@$el.show()
		
		if '' is title = @model.name()
			title = @model.id
		else
			title += " (#{@model.id})"
		@model.trigger 'windowTitleChanged', title
		
	render: ->
	
