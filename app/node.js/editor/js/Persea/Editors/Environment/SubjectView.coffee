
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
		
		mode = 0
	
		@changeSubject null
	
		$(window).resize _.throttle(
			=> @changeSubject @model
			1000
		)
		
		@$buttons = $('#persea > .buttons').html """
		<ul>
			<li>
				<p class="heading">Mode</p>
				<ul>
					<li class="button">
						<a id="mode-environment-move" href="#" style="background-image: url('/app/node.js/editor/images/ui/mode-move.png');"></a>
					</li>
					<li class="button">
						<a id="mode-environment-draw" href="#" style="background-image: url('/app/node.js/editor/images/ui/mode-draw.png');"></a>
					</li>
				</ul>
			</li>
		</ul>		
		"""
		
		$('#mode-environment-move', @$buttons).addClass 'active'
		
		@$canvas = $ '<div class="canvas">'
		
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
			
		holding = false
		
		@$canvas.on mousedown, (event) =>
			
			return unless mode is 1
			
			@paintTiles [event.clientX, event.clientY]
			
			undefined
		
		@swipey = new Swipey @$canvas
		@swipey.on 'update', (offset) =>
			
			tileSize = @tileset.tileSize()
			
			@$tiles.css
				top: -offset[1] * tileSize[1]
				left: -offset[0] * tileSize[0]
			
		$(window).on mousemove, (event) =>
			
			return unless holding and mode is 1
			
			@paintTiles [event.clientX, event.clientY]
			
			undefined
		
		$(window).on mouseup, (event) =>
			
			holding = false
			
			undefined
		
		@$canvas.on mouseout, (event) =>
				
			@$overlay.hide()
			
			undefined
				
		@$canvas.on mousedown, (event) =>
				
			holding = true
			
			undefined
				
		@$canvas.on mousemove, (event) =>
			return unless mode is 1
			
			@$overlay.show()
			
			offset = @$canvas.offset()
			tileSize = @tileset.tileSize()
			position = Vector.sub(
				[event.clientX, event.clientY]
				[offset.left, offset.top]
			)
			
			tilePosition = Vector.mul(
				Vector.floor Vector.div(
					position, tileSize
				)
				tileSize
			)
			
			bgImage = $('.tileset .image').css 'background-image'
			
			matrix = @editor.tileSelectionMatrix
			mOffset = Vector.mul tileSize, Rectangle.position matrix
			@$overlay.css
				top: tilePosition[1]
				left: tilePosition[0]
				width: matrix[2] * tileSize[0]
				height: matrix[3] * tileSize[1]
				'background-image': bgImage
				'background-position': "-#{mOffset[0]}px -#{mOffset[1]}px"
			
			undefined
				
		$('#mode-environment-move', @$buttons).click =>
			
			$('.button a', @$buttons).removeClass 'active'
			$('#mode-environment-move', @$buttons).addClass 'active'
			
			mode = 0
			@$overlay.hide()
			@$canvas.css cursor: 'move'
			@swipey.active = true
			
			undefined
			
		$('#mode-environment-draw', @$buttons).click =>
			
			$('.button a', @$buttons).removeClass 'active'
			$('#mode-environment-draw', @$buttons).addClass 'active'
			
			mode = 1
			@$overlay.show()
			@$canvas.css cursor: 'default'
			@swipey.active = false
			
			undefined
		
		@$canvas.css cursor: 'move'
		
		@$el.append @$canvas
		@$canvas.append @$tiles = $ '<div class="tiles">'
		@$canvas.append @$overlay = $ '<div class="overlay">'
		@$overlay.hide()
		(pulseHover = =>
			
			@$overlay.animate(
				opacity: 0
				=>
					@$overlay.animate(
						opacity: .8
						pulseHover
					)
			)
		)()
		
		
		$('#subject').append @$el
	
	paintTiles: (position) ->
		
		{tileSelection} = @calculateMousePositions(
			position
			@$canvas
			@$tiles
		)
		
		matrix = @editor.tileSelectionMatrix
		tile = Rectangle.position matrix
		for y in [0...matrix[3]]
			for x in [0...matrix[2]]
				
				fooTile = Vector.add tile, [x, y]
				@setTileIndex(
					fooTile[1] * @tileset.tiles()[0] + fooTile[0]
					Vector.add tileSelection, [x, y]
				)
				
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
		
	canvasSize: ->
		
		tileSize = @tileset.tileSize()
	
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
	
	setTileIndex: (index, position) ->
		
		room = @model.currentRoom()
		layer = room.layer 0
		
		layer.setTileIndex index, position
		
		@layers[0].drawFilledBox(
			Rectangle.compose(
				Vector.mul(
					position
					@tileset.tileSize()
				)
				@tileset.tileSize()
			)
			0, 0, 0, 0
		)
	
		@tileset.render(
			Vector.mul(
				position
				@tileset.tileSize()
			)
			@layers[0]
			index
			null
			[0, 0, 16, 16]
		) if index
			
	resizeCanvas: ->
		
		currentRoom = @model.currentRoom()
		tileSize = @tileset.tileSize()
		
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
			
		@$buttons.css
			height: canvasSize[1]
		
		@trigger 'canvasSizeRecalculated', canvasSize
		
		@swipey.setMinMax(
			[0, 0]
			Vector.sub(
				@model.currentRoom().size()
				Vector.div(
					canvasSize
					@tileset.tileSize()
				)
			)
		)
		
	generateRoom: ->
		
		canvasSize = [@$canvas.width(), @$canvas.height()]
		tileSize = @tileset.tileSize()
		
		currentRoom = @model.currentRoom()
		
		sizeInTiles = currentRoom.size()
		
		totalTileSize = sizeInTiles[0] * sizeInTiles[1]
		
		totalRoomSize = Vector.mul sizeInTiles, tileSize
		
		@$tiles.empty()
		
		@layers = []
		
		for i in [0...currentRoom.layerCount()]
		
			@layers[i] = new Image totalRoomSize
			
			_.defer(
				(i) =>
					
					j = 0
					
					renderTile = =>
						
						y = j
						
						for x in [0...sizeInTiles[0]]
							position = Vector.mul tileSize, [x, y]
							
							index = currentRoom.layer(i).tileIndex [x, y]
							@tileset.render(
								position
								@layers[i]
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
						
				i
			)
				
			@$tiles.append $(@layers[i].Canvas).addClass 'layer'
		
		undefined
		
	changeSubject: (model) ->
		
		@trigger 'windowTitleChanged'
	
		# Don't show anything for a null model.
		unless model?
			@model = model
			@$el.hide()
			return
		
		roomHasChanged = model.currentRoom() isnt @model?.currentRoom()
		
		@model = model
		@environment = model.subject
		@tileset = @environment.tileset()
		
		@resizeCanvas()
		
		@generateRoom() if roomHasChanged
		
		@$el.show()
		
		if '' is title = @model.name()
			title = @model.id
		else
			title += " (#{@model.id})"
		@model.trigger 'windowTitleChanged', title
		
	render: ->
	
