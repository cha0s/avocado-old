
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
		
		@$el.append """
		
		<div class="draw">
			<select class="draw-styles"></select>
			<label>on layer: </label>
			<select class="layers"></select>
		</div>
		
		<div class="buttons">
			<ul>
				<li>
					<ul>
						<li class="button">
							<a id="mode-tileset-move" href="#" style="background-image: url('/app/node.js/editor/images/ui/mode-move.png');"></a>
						</li>
						<li class="button">
							<a id="mode-tileset-draw" href="#" style="background-image: url('/app/node.js/editor/images/ui/mode-select.png');"></a>
						</li>
					</ul>
				</li>
			</ul>		
		</div>
		
		"""
		
		@$buttons = $ '.buttons', @$el
		
		$drawStyles = $ '.draw-styles', @$el
		
		$drawStyles.append $('<option>').text 'Paintbrush'
		$drawStyles.append $('<option>').text 'Flood'
		$drawStyles.append $('<option>').text 'Random flood'
		
		$drawSelect = $ '.layers', @$el
		for index in [0...4]
			$drawSelect.append $('<option>').html "#{index}&nbsp;"
		
		$tilesetContainer = $ '<div class="tileset-container">'
		
		$tilesetContainer.append @$tileset = $ '<div class="tileset">'
		@$tileset.append @$tilesetImage = $ '<div class="image">'
		
		@$tileset.append @$hoverSquare = $ '<div class="hover">'
		(pulseHover = =>
			
			@$hoverSquare.animate(
				opacity: 0
				200
				=>
					@$hoverSquare.animate(
						opacity: .4
						200
						pulseHover
					)
			)
		)()
		
		@$tileset.append @$tileSelection = $ '<div class="selection">'
		@tileSelectionMatrix = [0, 0, 1, 1]
		
		@swipey = new Swipey @$tileset
		@swipey.on 'update', (offset) =>
			
			offset = Vector.floor offset
			tileSize = @tileset.tileSize()
			
			@$tilesetImage.css
				left: offset[0] * -tileSize[0]
				top: offset[1] * -tileSize[1]
				
			@updateTileSelection()
		
		mode = 0
		holding = false
		
		if Modernizr.touch
			
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseout = 'vmouseout'
			mouseup = 'vmouseup'
			
		else
			
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseout = 'mouseout'
			mouseup = 'mouseup'
		
		@$tileset.on(
			mousedown
			(event) =>
				
				holding = true
				
				if mode is 1
					
					{tileSelection} = @calculateMousePositions(
						[event.clientX, event.clientY]
						@$tileset
						@$tilesetImage
					)
					
					@tileSelectionMatrix = [
						tileSelection[0]
						tileSelection[1]
						1
						1
					]
					
					@currentSelection = tileSelection
					
					@updateTileSelection()
					
				true
		)
		
		$(window).on mousemove, (event) =>
			
			if holding and mode is 1
				
				tileSize = @tileset.tileSize()
				
				{tilePosition, tileSelection} = @calculateMousePositions(
					[event.clientX, event.clientY]
					@$tileset
					@$tilesetImage
				)
				
				minSelection = Vector.min @currentSelection, tileSelection
				maxSelection = Vector.max @currentSelection, tileSelection
				@tileSelectionMatrix = [
					minSelection[0]
					minSelection[1]
					maxSelection[0] - minSelection[0] + 1
					maxSelection[1] - minSelection[1] + 1
				]
				
				@updateTileSelection()
				
			true
			
		$(window).on mouseup, (event) =>
			
			holding = false
		
		$('#mode-tileset-move', @$buttons).click =>
			
			$('.button a', @$buttons).removeClass 'active'
			$('#mode-tileset-move', @$buttons).addClass 'active'
			
			mode = 0
			@$tileset.css cursor: 'move'
			@swipey.active = true
			
			undefined
			
		$('#mode-tileset-draw', @$buttons).click =>
			
			$('.button a', @$buttons).removeClass 'active'
			$('#mode-tileset-draw', @$buttons).addClass 'active'
			
			mode = 1
			@$tileset.css cursor: 'default'
			@swipey.active = false
			
			undefined
		
		$('#mode-tileset-move', @$buttons).addClass 'active'		
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
		
		tileSize = @tileset.tileSize()
		
		position = Vector.add(
			[
				Dom.numberFromPxString @$tilesetImage.css 'left'
				Dom.numberFromPxString @$tilesetImage.css 'top'
			]
			Vector.mul(
				Rectangle.position @tileSelectionMatrix
				tileSize
			)
		)
		
		@$hoverSquare.css
			top: position[1]
			left: position[0]
			width: @tileSelectionMatrix[2] * tileSize[0]
			height: @tileSelectionMatrix[3] * tileSize[1]
			
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
