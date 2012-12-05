
Graphics = require 'Graphics'
Image = Graphics.Image

DisplayList = require 'core/Graphics/DisplayList'
Dom = require 'core/Utility/Dom'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
TileLayer = require 'core/Environment/2D/TileLayer'
Vector = require 'core/Extension/Vector'

[MODE_MOVING, MODE_SELECTION] = [0, 1]

module.exports = Backbone.View.extend
	
	initialize: ({
		@subject
	}) ->
		
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
		
		<div class="tileset-container">
			<div class="tileset">
				<div class="image"></div>
				<div class="selection"></div>
			</div>
		</div>
		
		"""
		
		# Selectors.
		@$buttons = $ '.buttons', @$el
		@$drawSelect = $ '.layers', @$el
		@$drawStyles = $ '.draw-styles', @$el
		@$tileset = $ '.tileset', @$el
		@$tilesetImage = $ '.image', @$tileset
		@$tilesetSelection = $ '.selection', @$tileset
		
		# Add draw styles.
		@$drawStyles.append $('<option>').text 'Paintbrush'
		@$drawStyles.append $('<option>').text 'Flood'
		@$drawStyles.append $('<option>').text 'Random flood'
		
		@selectionMatrix = [0, 0, 1, 1]
		
		# Pulse animation for selected tiles.
		(pulse = =>
			
			@$tilesetSelection.animate(
				opacity: 0
				200
				=>
					@$tilesetSelection.animate(
						opacity: .4
						200
						pulse
					)
			)
		)()
		
		# Attach swiping behaviors to the tileset.
		@swipey = new Swipey @$tileset
		@swipey.on 'update', (offset) =>
			
			# Update the tileset image offset.
			[left, top] = Vector.mul(
				Vector.floor offset
				Vector.scale @tileset.tileSize(), -1
			)
			@$tilesetImage.css left: left, top: top
			
			@updateSelectionDimensions()
		
		@attachMouseEvents()
		
		# Mode selection buttons.
		$('#mode-tileset-move', @$buttons).click => @setMode MODE_MOVING
		$('#mode-tileset-draw', @$buttons).click => @setMode MODE_SELECTION
		
		$('#editor .controls').append @$el
		
		@setMode MODE_MOVING
	
	attachMouseEvents: ->
	
		isSelecting = false
		{mousedown, mousemove, mouseup} = Dom.mouseEventNames()
		
		# Mouse button/tap on the tileset.
		@$tileset.on mousedown, (event) =>
			return unless @mode is MODE_SELECTION
				
			isSelecting = true
			
			# Recalculate the selection matrix as a 1x1 starting at the
			# selected tile.
			@selectionMatrix = Rectangle.compose(
				@selectionStart = @tileAt [event.clientX, event.clientY]
				[1, 1]
			)
			
			@updateSelectionDimensions()
				
			true
		
		# Allow click/tap drag to allow a matrix of tiles to be selected.
		$(window).on mousemove, (event) =>
			return unless isSelecting and @mode is MODE_SELECTION
		
			tileSize = @tileset.tileSize()
			
			# Recalculate the new selection matrix.
			tileAt = @tileAt [event.clientX, event.clientY]
			topLeft = Vector.min @selectionStart, tileAt
			bottomRight = Vector.max @selectionStart, tileAt
			@selectionMatrix = Rectangle.compose(
				topLeft
				Vector.add [1, 1], Vector.sub bottomRight, topLeft
			) 
			
			@updateSelectionDimensions()
			
			true
		
		# End selection.	
		$(window).on mouseup, (event) => isSelecting = false
		
	setMode: (@mode) ->
		
		$('.button a', @$buttons).removeClass 'active'
		
		switch @mode
		
			when MODE_MOVING
				$('#mode-tileset-move', @$buttons).addClass 'active'
				@$tileset.css cursor: 'move'
				@swipey.active = true
			
			when MODE_SELECTION
				$('#mode-tileset-draw', @$buttons).addClass 'active'
				@$tileset.css cursor: 'default'
				@swipey.active = false
				
		undefined
	
	tileAt: (position) ->
		
		tileSize = @tileset.tileSize()
		
		Vector.div(
			Vector.add(
				Vector.scale(
					Dom.position @$tilesetImage
					-1
				)
				Vector.mul(
					Vector.floor Vector.div(
						Vector.sub(
							position
							Dom.offset @$tileset
						)
						tileSize
					)
					tileSize
				)
			)
			tileSize
		)
	
	updateSelectionDimensions: ->
		
		tileSize = @tileset.tileSize()
		
		[left, top] = Vector.add(
			[
				Dom.numberFromPxString @$tilesetImage.css 'left'
				Dom.numberFromPxString @$tilesetImage.css 'top'
			]
			Vector.mul(
				Rectangle.position @selectionMatrix
				tileSize
			)
		)
		[width, height] = Vector.mul(
			Rectangle.size @selectionMatrix
			tileSize
		)
		@$tilesetSelection.css
			left: left
			top: top
			width: width
			height: height
			
	setCanvasSize: (canvasSize) ->
	
	setModel: (@model) ->
		return unless @model?
		
		@tileset = @model.subject.tileset()
		
		currentRoom = @model.currentRoom()
		tileSize = @tileset.tileSize()
		
		# Add layer selection options.
		@$drawSelect.empty()
		for index in [0...currentRoom.layerCount()]
			@$drawSelect.append $('<option>').html "#{index}&nbsp;"
		
		# Reset the tileset selection.
		@updateSelectionDimensions()
		
		# Reset the tileset image.
		@$tilesetImage.css
			width: @tileset.image().width()
			height: @tileset.image().height()
			'background-image': "url(\"#{@tileset.image().src}\")"
		
		# Resize the area to be swiped upon.
		@swipey.setMinMax(
			[0, 0]
			Vector.sub(
				@tileset.tiles()
				Vector.floor Vector.div(
					[256, 256]
					tileSize
				)
			)
		)
		
		undefined
