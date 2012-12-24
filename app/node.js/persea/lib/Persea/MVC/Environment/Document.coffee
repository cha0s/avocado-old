Floodfill = require 'core/Utility/Floodfill'
Image = require('Graphics').Image
Matrix = require 'core/Extension/Matrix'
NavBar = require 'Persea/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
UndoCommand = require 'Persea/Undo/Command'
UndoStack = require 'Persea/Undo/Stack'
UndoGroup = require 'Persea/Undo/Group'
Vector = require 'core/Extension/Vector'

RoomLayersView = Ember.CollectionView.extend
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	itemViewClass: Ember.View.extend
		
		attributeBindings: ['unselectable']
		unselectable: 'on'
		
		didInsertElement: ->
			
			$layer = @$()
			
			roomObject = @get 'content.roomObject'
			environmentObject = @get 'content.environmentObject'
			
			sizeInTiles = roomObject.size()
			tileset = environmentObject.tileset()
			tileIndices = roomObject.layer($layer.index()).tileIndices_
			tileSize = tileset.tileSize()
			
			layer = new Image()
			layer.Canvas = $('canvas', $layer)[0]
			
			# Render the layer, row by row.
			y = 0
			indexPointer = 0
			renderPosition = [0, 0]
			(renderTile = =>
				for x in [0...sizeInTiles[0]]
					if index = tileIndices[indexPointer++]
						tileset.render(
							renderPosition
							layer
							index
						)
					
					renderPosition[0] += tileSize[0]
					
				renderPosition[0] = 0
				renderPosition[1] += tileSize[1]
				
				# Defer the next render until we get a tick from the VM, to
				# the browser's UI thread a chance to keep updating.
				_.defer renderTile if ++y < sizeInTiles[1]
			)()
		
		classNames: ['layer']
		template: Ember.Handlebars.compile """

<canvas
	unselectable="on"
	class="canvas"
	{{bindAttr width="view.content.width"}}
	{{bindAttr height="view.content.height"}}
	{{bindAttr style="view.content.style"}}
	{{bindAttr solo="view.content.solo"}}
>
</canvas>

"""

Controller = exports.Controller = Ember.Controller.extend
	
	init: ->
		
		@undoStacks = []
		
	environmentBinding: 'environmentController.environment'
	currentRoomBinding: 'environmentController.currentRoom'
	
	navBarContent: [
		mode: 'move'
		i: 'icon-move'
		title: 'Move: Click and drag or swipe to move the environment.'
	,
		mode: 'edit'
		i: 'icon-pencil'
		title: 'Edit: Click/tap and drag to draw upon the environment.'
	,
		noLink: true
		text: '|'
	,
		id: 'document-undo'
		noSelect: true
		i: 'icon-backward'
		title: 'Undo the last action.'
	,
		id: 'document-redo'
		noSelect: true
		i: 'icon-forward'
		title: 'Redo the last undone action.'
	]
	navBarSelection: null
	navBarView: NavBar.View
	
	# Convenience property to DRY up client usage of the active undo stack.
	undoStack: (->
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.activeStack()
	).property().volatile()
	
	selectedModeChanged: (->
		
		return unless (swipey = @get 'swipey')?
		
		$environmentDocument = $('#environment-document')
		
		switch @get 'navBarSelection.mode'
			
			when 'move'
				
				swipey.active = true
				$environmentDocument.css cursor: 'move'
				
			when 'edit'
				
				swipey.active = false
				$environmentDocument.css cursor: 'default'
		
	).observes 'navBarSelection'
	
	undoGroup: null
	
	environmentObjectChanged: (->
		
		return unless (object = @get 'environment.object')?
		
		@set 'undoGroup', undoGroup = new UndoGroup()
		
		@undoStacks = for i in [0...object.roomCount()]
			new UndoStack undoGroup
			
	).observes 'environment.object'
	
	roomChanged: (->
		
		return unless (currentRoom = @get 'currentRoom')?
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.setActiveStack @undoStacks[currentRoom.index]
		
	).observes 'currentRoom', 'undoGroup'
	
	roomLayers: null
	
	swipeyReset: (->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		
		tileset = environmentObject.tileset()
		
		$environmentDocument = $('#environment-document')
		
		swipey.setMinMax(
			[0, 0]
			Vector.sub(
				roomObject.size()
				Vector.floor Vector.div(
					[
						$environmentDocument.width()
						$environmentDocument.height()
					]
					tileset.tileSize()
				)
			)
		)
		
		swipey.setOffset [0, 0]
		
	).observes 'currentRoom.object', 'environment.object', 'swipey'

	roomLayersChanged: (->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		
		canvasSize = Vector.mul(
			roomObject.size()
			environmentObject.tileset().tileSize()
		)
		
		roomLayers = Ember.ArrayController.create()
		content = for i in [0...roomObject.layerCount()]
			Ember.Object.create
				
				style: "z-index: #{i * 10};"
				
				roomObject: roomObject
				environmentObject: environmentObject
				
				width: canvasSize[0]
				height: canvasSize[1]
				
				solo: false
				
		roomLayers.set 'content', content
		 
		@set 'roomLayers', roomLayers
		
	).observes 'currentRoom.object', 'environment.object'

exports.View = Ember.View.extend
	
	currentRoomBinding: 'controller.currentRoom'
	environmentBinding: 'controller.environment'
	landscapeControllerBinding: 'controller.landscapeController'
	roomLayersBinding: 'controller.roomLayers'
	navBarContentBinding: 'controller.navBarContent'
	navBarSelectionBinding: 'controller.navBarSelection'
	swipeyBinding: 'controller.swipey'
	undoGroupBinding: 'controller.undoGroup'
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	handleResize: _.throttle(
		->
			
			return unless (environmentObject = @get 'environment.object')?
			return unless (roomObject = @get 'currentRoom.object')?
			
			$el = $ '#environment-document'
			
			documentOffset = $el.offset()
			$row = $el.parent()
			rowOffset = $row.offset()
			tileSize = environmentObject.tileset().tileSize()
			
			# Calcuate the maximum width and height that the layout will allow
			# for the canvas.
			width = $row.width() - (documentOffset.left - rowOffset.left)
			
			windowHeight = $(window).height()
			height = windowHeight
			unless height < $('#footer').offset().top
				height -= $('#footer').height()
			height -= documentOffset.top
			height = Math.max(
				320
				if height <= 0
					windowHeight - 40
				else
					height
			)
			
			# Shrink the canvas to fit a small room.
			canvasSize = Vector.min(
				[width, height]
				Vector.mul roomObject.size(), tileSize
			)
			
			# Quantize to tile size.
			size = Vector.mul(
				Vector.floor Vector.div(
					canvasSize
					tileSize
				)
				tileSize
			)
			
			$el.css
				width: size[0]
				height: size[1]
				
			# Remove the spinner.
			$el.parent().css
				background: 'none'
			
			@get('controller').swipeyReset()
			
		75
	).observes 'currentRoom.object', 'environment.object'
		
	drawOverlayStyle: (->
		
		return '' unless (environmentObject = @get 'environment.object')?
		return '' unless (matrix = @get 'landscapeController.tilesetSelectionMatrix')?
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		left = tileSize[0] * -matrix[0]
		top = tileSize[1] * -matrix[1]
		width = tileSize[0] * matrix[2]
		height = tileSize[1] * matrix[3]
		zIndex = currentLayerIndex * 10 + 1
		
		"
background-position: #{left}px #{top}px; 
width: #{width}px; height: #{height}px; 
background-image: url('/resource#{tileset.image().uri()}');
z-index: #{zIndex}
"

	).property(
		'environment.object'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
	)
	
	soloChanged: (->
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		roomLayers = @get 'roomLayers'
		roomLayersContent = roomLayers.get 'content'
		solo = @get 'landscapeController.solo'
		
		if solo
			
			for roomLayer, index in roomLayersContent
				roomLayer.set 'solo', currentLayerIndex isnt index
			
		else
			roomLayer.set 'solo', false for roomLayer in roomLayersContent
			
	).observes(
		'landscapeController.currentLayerIndex'
		'landscapeController.solo'
		'roomLayers'
	)
	
	undoGroupChanged: (->
		
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.on 'canUndoChanged', (canUndo) ->
			$('#document-undo').closest('li').toggleClass(
				'disabled'
				not canUndo
			)
		
		undoGroup.on 'canRedoChanged', (canRedo) ->
			$('#document-redo').closest('li').toggleClass(
				'disabled'
				not canRedo
			)
		
		undoGroup.on 'activeStackChanged', (activeStack) ->
		
			$('#document-undo').closest('li').toggleClass(
				'disabled'
				not activeStack.canUndo()
			)
		
			$('#document-redo').closest('li').toggleClass(
				'disabled'
				not activeStack.canRedo()
			)
			
	).observes 'undoGroup'
	
	positionTranslatedToTile: (position) ->
		
		return [0, 0] unless (environmentObject = @get 'environment.object')?
		
		$environmentDocument = $('#environment-document')
		tileset = environmentObject.tileset()
		offset = $environmentDocument.offset()
					
		position = Vector.sub(
			Vector.add(
				position
				[$(window).scrollLeft(), $(window).scrollTop()]
			)
			[offset.left, offset.top]
		)
		
		position = Vector.floor Vector.div position, tileset.tileSize()
		
	positionTranslatedToLayer: (position) ->
		
		return [0, 0] unless (swipey = @get 'swipey')?
		
		position = @positionTranslatedToTile position
		
		position = Vector.add position, swipey.offset()
		
	positionTranslatedToOverlay: (position) ->
		
		return [0, 0] unless (environmentObject = @get 'environment.object')?
		
		tileset = environmentObject.tileset()
		
		position = @positionTranslatedToTile position
		
		position = Vector.mul position, tileset.tileSize()
		
	tileMatrixFromSelectionMatrix: (selectionMatrix) ->
		
		return [[0]] unless (environmentObject = @get 'environment.object')?
		return [[0]] unless (selectionMatrix = @get 'landscapeController.tilesetSelectionMatrix')?
		
		tileset = environmentObject.tileset()
		
		index = selectionMatrix[1] * tileset.tiles()[0] + selectionMatrix[0]
		
		tileMatrix = []
		for y in [0...selectionMatrix[3]]
			
			row = []
			tileMatrix.push row
			
			for x in [0...selectionMatrix[2]]
				
				tileIndex = index + y * tileset.tiles()[0] + x
				
				row.push tileIndex
				
		tileMatrix
	
	updateCanvas: (position, matrix, layerIndex) ->
	
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		
		$environmentDocument = $('#environment-document')
		layer = roomObject.layer layerIndex
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		layerImage = new Image()
		layerImage.Canvas = $('.layers canvas', $environmentDocument).eq(layerIndex)[0]
		
		layerImage.drawFilledBox Rectangle.compose(
			Vector.mul tileSize, position
			Vector.mul tileSize, Matrix.sizeVector matrix
		), 0, 0, 0, 0
		
		for row, y in matrix
			
			for index, x in row
		
				tileset.render(
					Vector.add(
						Vector.mul position, tileSize
						Vector.mul [x, y], tileSize
					)
					layerImage
					index
				) if index
				
		undefined

	paintTiles: (position, matrix, layerIndex) ->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		
		layer = roomObject.layer layerIndex
		
		@updateCanvas position, matrix, layerIndex
		
		layer.setTileMatrix matrix, position
		
	floodfillTiles: (position, matrix, layerIndex) ->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		layer = roomObject.layer layerIndex
		
		layerImage = new Image()
		layerImage.Canvas = @$().find('.layers canvas').eq(layerIndex)[0]
		
		self = this
		
		LayerFloodfill = class extends Floodfill
			
			valueEquals: Matrix.equals
				
			value: (x, y) ->
				
				layer.tileMatrix(
					Matrix.sizeVector matrix
					[x, y]
				)
			
			setValue: (x, y, matrix) ->
				
				layer.setTileMatrix matrix, [x, y]
				
				self.updateCanvas [x, y], matrix, layerIndex
				
		floodfill = new LayerFloodfill roomObject.size(), Matrix.sizeVector matrix
		
		floodfill.fillAt position[0], position[1], matrix
		
	randomFloodfillTiles: (position, matrix, layerIndex) ->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		layer = roomObject.layer layerIndex
		
		layerImage = new Image()
		layerImage.Canvas = @$().find('.layers canvas').eq(layerIndex)[0]
		
		self = this
		
		LayerRandomFloodfill = class extends Floodfill
			
			valueEquals: Matrix.equals
				
			value: (x, y) ->
				
				layer.tileMatrix(
					[1, 1]
					[x, y]
				)
			
			setValue: (x, y, unused) ->
				
				column = Math.floor matrix.length * Math.random()
				row = Math.floor matrix[0].length * Math.random()
				
				value = [[matrix[column][row]]]
				
				layer.setTileMatrix value, [x, y]
				
				self.updateCanvas [x, y], value, layerIndex
		
		floodfill = new LayerRandomFloodfill roomObject.size(), [1, 1]
		
		index = if 1 is Matrix.size matrix then matrix[0][0] else -1
		
		floodfill.fillAt(
			position[0], position[1]
			index
		)
		
	pushDrawCommand:
		
		Paintbrush: (position) ->
		
			return unless (roomObject = @get 'currentRoom.object')?
			
			currentLayerIndex = @get 'landscapeController.currentLayerIndex'
			layer = roomObject.layer currentLayerIndex
			position = @positionTranslatedToLayer position
			selectionMatrix = @tileMatrixFromSelectionMatrix()
			self = this
			tileMatrix = layer.tileMatrix(
				Matrix.sizeVector selectionMatrix
				position
			)
			
			hasDraw = _.find @draws, (draw) ->
				
				Vector.equals draw.position, position
			
			unless hasDraw?
			
				@draws.push
					position: position
					
					undo: _.bind(
						@paintTiles, this
						position, tileMatrix, currentLayerIndex
					)
					redo: _.bind(
						@paintTiles, this
						position, selectionMatrix, currentLayerIndex
					)
			
			@paintTiles(
				position
				selectionMatrix
				currentLayerIndex
			)
		
		Floodfill: (position) ->
		
			return unless (roomObject = @get 'currentRoom.object')?
			
			currentLayerIndex = @get 'landscapeController.currentLayerIndex'
			layer = roomObject.layer currentLayerIndex
			position = @positionTranslatedToLayer position
			selectionMatrix = @tileMatrixFromSelectionMatrix()
			self = this
			tileMatrix = layer.tileMatrix(
				Matrix.sizeVector selectionMatrix
				position
			)
			
			hasDraw = _.find @draws, (draw) ->
				
				Vector.equals draw.position, position
			
			oldMatrix = layer.tileMatrix(
				roomObject.size()
				[0, 0]
			)
			
			@floodfillTiles(
				position
				selectionMatrix
				currentLayerIndex
			)
		
			newMatrix = layer.tileMatrix(
				roomObject.size()
				[0, 0]
			)
			
			unless hasDraw?
			
				@draws.push
					position: position
					
					undo: ->
						layer.setTileMatrix oldMatrix, [0, 0]
						self.updateCanvas [0, 0], oldMatrix, currentLayerIndex
					redo: ->
						layer.setTileMatrix newMatrix, [0, 0]
						self.updateCanvas [0, 0], newMatrix, currentLayerIndex
			
		'Random flood': (position) ->
		
			return unless (roomObject = @get 'currentRoom.object')?
			
			currentLayerIndex = @get 'landscapeController.currentLayerIndex'
			layer = roomObject.layer currentLayerIndex
			position = @positionTranslatedToLayer position
			selectionMatrix = @tileMatrixFromSelectionMatrix()
			self = this
			tileMatrix = layer.tileMatrix(
				Matrix.sizeVector selectionMatrix
				position
			)
			
			hasDraw = _.find @draws, (draw) ->
				
				Vector.equals draw.position, position
			
			oldMatrix = layer.tileMatrix(
				roomObject.size()
				[0, 0]
			)
			
			@randomFloodfillTiles(
				position
				selectionMatrix
				currentLayerIndex
			)
		
			newMatrix = layer.tileMatrix(
				roomObject.size()
				[0, 0]
			)
			
			unless hasDraw?
			
				@draws.push
					position: position
					
					undo: ->
						layer.setTileMatrix oldMatrix, [0, 0]
						self.updateCanvas [0, 0], oldMatrix, currentLayerIndex
					redo: ->
						layer.setTileMatrix newMatrix, [0, 0]
						self.updateCanvas [0, 0], newMatrix, currentLayerIndex
			
	commitDrawCommands: ->
		
		return if @draws.length is 0
		return unless (undoStack = @get 'controller.undoStack')?		
		
		draws = _.map @draws, _.identity
		
		ranFirstRedo = false
		
		undoStack.push new class extends UndoCommand
			
			undo: ->
				
				for i in [draws.length - 1..0]
					draw = draws[i]
					
					draw.undo()
			
			redo: ->
				
				if ranFirstRedo

					for draw in draws
						
						draw.redo()
						
				ranFirstRedo = true
		
		@draws = []
		
	didInsertElement: ->
		
		@draws = []
		
		(($) =>
			
			$('#document-undo').click =>
				@get('controller.undoStack')?.undo()
				false
			$('#document-redo').click =>
				@get('controller.undoStack')?.redo()
				false
			
			$environmentDocument = $('#environment-document')
			
			$('.draw-overlay', $environmentDocument).css opacity: .85, width: 16, height: 16
			(pulseOverlay = ->
				$('.draw-overlay', $environmentDocument).animate
					opacity: .45
				,
					500
					->
						$('.draw-overlay', $environmentDocument).animate
							opacity: .85
						,
							500
							pulseOverlay
			)()
			
			if Modernizr.touch
				
				$el = $environmentDocument
				mousedown = 'vmousedown'
				mousemove = 'vmousemove'
				mouseout = 'vmouseout'
				mouseover = 'vmouseover'
				mouseup = 'vmouseup'
				
			else
				
				$el = $(window)
				mousedown = 'mousedown'
				mousemove = 'mousemove'
				mouseout = 'mouseout'
				mouseover = 'mouseover'
				mouseup = 'mouseup'
			
			$el.off '.environmentDocument'
			
			holding = false
			
			$environmentDocument.on(
				"#{mousedown}.environmentDocument"
				(event) =>
					
					return if 'move' is @get 'navBarSelection.mode'
					
					currentDrawMode = @get 'landscapeController.currentDrawMode'
					
					holding = true
					
					@pushDrawCommand[currentDrawMode].call this, [event.clientX, event.clientY]
					
					false
			)
			
			setOverlayPosition = (position) ->
				
				$('.draw-overlay', $environmentDocument).css
					left: position[0]
					top: position[1]
			
			$environmentDocument.on(
				"#{mousemove}.environmentDocument"
				(event) =>
					
					return if 'move' is @get 'navBarSelection.mode'
					
					currentDrawMode = @get 'landscapeController.currentDrawMode'
					
					setOverlayPosition @positionTranslatedToOverlay [event.clientX, event.clientY]
					
					if holding
						
						@pushDrawCommand[currentDrawMode].call this, [event.clientX, event.clientY]
					
					false
			)
			
			$environmentDocument.on(
				"#{mouseout}.environmentDocument"
				=>
					
					return if 'move' is @get 'navBarSelection.mode'
					
					$('.draw-overlay', $environmentDocument).hide()
					
					false
			)
			
			$environmentDocument.on(
				"#{mouseover}.environmentDocument"
				=>
					
					return if 'move' is @get 'navBarSelection.mode'
					
					$('.draw-overlay', $environmentDocument).show()
					
					false
			)
			
			$el.on(
				"#{mouseup}.environmentDocument"
				=>
					
					return if 'move' is @get 'navBarSelection.mode'
					
					return if holding is false
					
					@commitDrawCommands()
					
					holding = false
					
					false
			)
			
			# Attach swiping behaviors to the tileset.
			swipey = new Swipey $environmentDocument, 'environmentSwipey'
			swipey.on 'update', (offset) =>
				
				return unless (object = @get 'environment.object')?
				
				tileSize = object.tileset().tileSize()
				
				# Update the tileset image offset.
				[left, top] = Vector.mul(
					Vector.floor offset
					Vector.scale tileSize, -1
				)
				
				$('.layers', $environmentDocument).css left: left, top: top
				
			@set 'swipey', swipey
			
			offset = $environmentDocument.offset()
			
			windowHeight = $(window).height()
			
			autoCanvasHeight = windowHeight
			
			footerOffset = $('#footer').offset()
			unless autoCanvasHeight < footerOffset.top
				autoCanvasHeight -= $('#footer').height()
			
			autoCanvasHeight -= offset.top
			
			autoCanvasHeight = Math.max(
				320
				autoCanvasHeight
			)
			
			height = Math.max(
				320
				if autoCanvasHeight <= 0
					windowHeight - 40
				else
					autoCanvasHeight
			)
			
			$environmentDocument.css
				height: height
				
			$environmentDocument.parent().css
				background: "url('/app/node.js/persea/static/img/spinner.svg') center no-repeat"
				'background-size': 'contain'
			
			@handleResize()
			$(window).resize =>
				@handleResize()
				
			@set 'navBarSelection', @get('navBarContent')[0]
			
		) jQuery
		
	roomLayersView: RoomLayersView
	
	template: Ember.Handlebars.compile """

<div class="navbar">
	<div class="navbar-inner">
		{{view navBarView
			contentBinding="navBarContent"
			selectionBinding="navBarSelection"
		}}
	</div>	
</div>

<div id="environment-document">
	<div class="draw-overlay" {{bindAttr style="view.drawOverlayStyle"}} ></div>
	
	{{view view.roomLayersView
		class="layers"
		contentBinding="roomLayers"
	}}
	
</div>

"""
