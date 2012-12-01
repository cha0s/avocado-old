
Graphics = require 'Graphics'
Image = Graphics.Image

DisplayList = require 'core/Graphics/DisplayList'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
TileLayer = require 'core/Environment/2D/TileLayer'
Vector = require 'core/Extension/Vector'

module.exports = Backbone.View.extend
	
	initialize: ({
		@$canvas
	}) ->
		
		@gridOverlay = new Graphics.Image [1, 1]
		@$canvas.append @gridOverlay.Canvas
		
		@$el.append $('<h2>').text 'Draw'
		
		@$el.append $drawWithContainer = $ '<div class="draw-with">'
		$drawWithContainer.append $('<label>').addClass('draw-label').text 'with:'
		$drawWithContainer.append $drawSelect = $ '<select>'
		$drawSelect.append $('<option>').text 'Paintbrush'
		$drawSelect.append $('<option>').text 'Flood'
		$drawSelect.append $('<option>').text 'Randomized flood'
		
		@$el.append $drawOnContainer = $ '<div class="draw-on">'
		$drawOnContainer.append $('<label>').addClass('draw-label').text 'on layer:'
		$drawOnContainer.append $drawSelect = $ '<select>'
		
		for index in [0...4]
			$drawSelect.append $('<option>').html "#{index}&nbsp;"
		
		$tilesetContainer = $ '<div class="tileset-container">'
		
		$tilesetContainer.append @$tileset = $ '<div class="tileset">'
		
		@swipey = new Swipey @$tileset
		@swipey.on 'update', (offset) =>
			
			offset = Vector.floor offset
			tileSize = @tileset.tileSize()
			
			$(@tileset.image().Canvas).css 'left', offset[0] * -tileSize[0]
			$(@tileset.image().Canvas).css 'top', offset[1] * -tileSize[1]
		
		taps = 0
		compoundTapEvent = _.debounce(
			=>
				switch taps
					when 2
						@$tileset.trigger 'doubletap'
					when 3
						@$tileset.trigger 'tripletap'
					
				taps = 0
			300
		)
		
		mode = 0
		
		@$tileset.on
			
			mousedown: (event) =>
				
				taps += 1
				compoundTapEvent()
				
				true
				
			doubletap: =>
				
				switch mode
					
					when 0
						
						@$tileset.css cursor: 'default'
						@swipey.active = false
						
					when 1
				
						@$tileset.css cursor: 'move'
						@swipey.active = true
						
				mode = if mode is 0 then 1 else 0
				
		@$tileset.css
			cursor: 'move'
		
		@$el.append $tilesetContainer
		
		$('#editor .controls').append @$el
	
	attachCanvas: (@$canvas) ->
	
		@$canvas.on
		
			doubletap: ->
				
				alert 'Double tap!'
		
			tripletap: ->
				
				alert 'Triple tap!'
	
	setCanvasSize: (canvasSize) ->
		
		@gridOverlay.Canvas.width = canvasSize[0]
		@gridOverlay.Canvas.height = canvasSize[1]
		
		tileSize = @tileset.tileSize()
		
		sizeInTiles = Vector.div canvasSize, tileSize
		
		for y in [0...sizeInTiles[1]]
			for x in [0...sizeInTiles[0]]
				@gridOverlay.drawLineBox(
					Rectangle.compose(
						Vector.mul tileSize, [x, y]
						tileSize
					)
					255, 255, 255, 32
				)
				
		undefined
	
	setModel: (@model) ->
		return unless @model?
		
		@tileset = @model.subject.tileset()
		
		@model.tilesetOffset ?= [0, 0]
		
		@$tileset.html @tileset.image().Canvas
		
		@swipey.setMinMax(
			[0, 0]
			Vector.sub(
				Vector.div @tileset.image().size(), @tileset.tileSize()
				Vector.div(
					[256, 256]
					@tileset.tileSize()
				)
			)
		)
		
		undefined
