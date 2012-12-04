
Graphics = require 'Graphics'
Image = Graphics.Image

DisplayList = require 'core/Graphics/DisplayList'
Dom = require 'core/Utility/Dom'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
TileLayer = require 'core/Environment/2D/TileLayer'
Vector = require 'core/Extension/Vector'

module.exports = Backbone.View.extend
	
	initialize: ({
		@subject
	}) ->
		
		@$canvas = @subject.$canvas
		
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
		@$tileset.append @$tilesetImage = $ '<div class="image">'
		
		@$tileset.append @$hoverSquare = $ '<div class="hover">'
#		@$hoverSquare.hide()
		(pulseHover = =>
			
			@$hoverSquare.animate(
				opacity: 0
				=>
					@$hoverSquare.animate(
						opacity: 1
						pulseHover
					)
			)
		)()
		
		@$tileset.append @$tileSelection = $ '<div class="selection">'
		@tileSelection = 0
		
		@swipey = new Swipey @$tileset
		@swipey.on 'update', (offset) =>
			
			offset = Vector.floor offset
			tileSize = @tileset.tileSize()
			
			@$tilesetImage.css
				left: offset[0] * -tileSize[0]
				top: offset[1] * -tileSize[1]
				
			@updateTileSelection()
		
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
		
		if Modernizr.touch
			
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseout = 'vmouseout'
			
		else
			
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseout = 'mouseout'
		
		@$tileset.on(
			mousedown
			(event) =>
				
				if mode is 1
					
					tileSize = @tileset.tileSize()
					
					{tilePosition, tileSelection} = @calculateMousePositions(
						[event.clientX, event.clientY]
						@$tileset
						@$tilesetImage
					)
					
					tileIndex = tileSelection[0] + tileSelection[1] * @tileset.tiles()[0]
					
					@tileSelection = tileIndex
					
					@updateTileSelection()
					
#					@$hoverSquare.css
#						top: tilePosition[1]
#						left: tilePosition[0]
				
				taps += 1
				compoundTapEvent()
				
				true
		)
		
		@$tileset.on(
			mouseout
			(event) =>
				
#				@$hoverSquare.hide()
				
				true
		)
		
		@$tileset.on(
			mousemove
			(event) =>
				
				###
				
				return unless mode is 1
				
				{tilePosition} = @calculateMousePositions(
					[event.clientX, event.clientY]
					@$tileset
					@$tilesetImage
				)
				
				@$hoverSquare.show()
				@$hoverSquare.css
					top: tilePosition[1]
					left: tilePosition[0]
				
				###
				
				true
		)
		
		@$tileset.on
			
			doubletap: =>
				
				switch mode
					
					when 0
						
						@$tileset.css cursor: 'default'
						@swipey.active = false
						
					when 1
				
#						@$hoverSquare.hide()
						@$tileset.css cursor: 'move'
						@swipey.active = true
						
				mode = if mode is 0 then 1 else 0
				
		@$tileset.css
			cursor: 'move'
		
		@$el.append $tilesetContainer
		
		$('#editor .controls').append @$el
	
	calculateMousePositions: (position, $el, $scrollEl) ->
	
		offset = $el.offset()
		position = Vector.sub(
			position
			[offset.left, offset.top]
		)
		
		tilePosition = Vector.mul(
			Vector.floor Vector.div(
				position, @tileset.tileSize()
			)
			@tileset.tileSize()
		)
		
		scrollOffset = Vector.scale(
			[
				Dom.numberFromPxString $scrollEl.css 'left'
				Dom.numberFromPxString $scrollEl.css 'top'
			]
			-1
		)
		
		tileSelection = Vector.div(
			Vector.add(
				scrollOffset
				tilePosition
			)
			@tileset.tileSize()
		)
		
		position: position
		tilePosition: tilePosition
		tileSelection: tileSelection
	
	updateTileSelection: ->
		
		position = Vector.add(
			[
				Dom.numberFromPxString @$tilesetImage.css 'left'
				Dom.numberFromPxString @$tilesetImage.css 'top'
			]
			Vector.mul(
				[
					@tileSelection % @tileset.tiles()[0]
					Math.floor @tileSelection / @tileset.tiles()[0]
				]
				@tileset.tileSize()
			)
		)
		
		@$hoverSquare.css
			top: position[1]
			left: position[0]
			
	setCanvasSize: (canvasSize) ->
	
	attachCanvas: (@$canvas) ->
	
		@$canvas.on
		
			doubletap: ->
				
				alert 'Double tap!'
		
			tripletap: ->
				
				alert 'Triple tap!'
	
	setModel: (@model) ->
		return unless @model?
		
		@tileset = @model.subject.tileset()
		
		tileSize = @tileset.tileSize()
		
		@$hoverSquare.css
			width: tileSize[0]
			height: tileSize[1]
		
		@model.tilesetOffset ?= [0, 0]
		
		bg = "url(\"#{@tileset.image().src}\")"
		
		@$tilesetImage.css
			width: @tileset.image().width()
			height: @tileset.image().height()
			'background-image': bg
		
		@swipey.setMinMax(
			[0, 0]
			Vector.sub(
				Vector.div @tileset.image().size(), tileSize
				Vector.div(
					[256, 256]
					tileSize
				)
			)
		)
		
		undefined
