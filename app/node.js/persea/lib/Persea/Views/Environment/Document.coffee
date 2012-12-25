Floodfill = require 'core/Utility/Floodfill'
Image = require('Graphics').Image
Matrix = require 'core/Extension/Matrix'
NavBarView = require 'Persea/Views/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
RoomLayersView = require 'Persea/Views/Environment/RoomLayers'
Swipey = require 'Swipey'
UndoCommand = require 'Persea/Undo/Command'
UndoStack = require 'Persea/Undo/Stack'
UndoGroup = require 'Persea/Undo/Group'
Vector = require 'core/Extension/Vector'

module.exports = Ember.View.extend
	
	currentRoomBinding: Ember.Binding.oneWay 'controller.currentRoom'
	environmentControllerBinding: Ember.Binding.oneWay 'controller.environmentController'
	environmentBinding: Ember.Binding.oneWay 'controller.environment'
	landscapeControllerBinding: Ember.Binding.oneWay 'environmentController.landscapeController'
	navBarContentBinding: Ember.Binding.oneWay 'controller.navBarContent'
	navBarSelectionBinding: Ember.Binding.oneWay 'controller.navBarSelection'
	roomLayersBinding: Ember.Binding.oneWay 'controller.roomLayers'
	undoGroupBinding: Ember.Binding.oneWay 'controller.undoGroup'
	undoStackBinding: Ember.Binding.oneWay 'controller.undoStack'
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	handleResize: _.throttle(
		->
			
			return unless (roomObject = @get 'currentRoom.object')?
			return unless (tilesetObject = @get 'environment.tileset.object')?
			
			$el = $ '#environment-document'
			
			documentOffset = $el.offset()
			$row = $el.parent()
			rowOffset = $row.offset()
			tileSize = tilesetObject.tileSize()
			
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
			
			@swipeyReset()
			
		75
	).observes 'currentRoom.object', 'environment.object'
		
	drawOverlayStyle: (->
		
		return '' if 'move' is @get 'navBarSelection.mode'
		
		currentDrawTool = @get 'landscapeController.currentDrawTool'
		return "" unless (properties = currentDrawTool.drawOverlayStyle? this)?
		{left, top, width, height, imageUrl} = properties
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		zIndex = currentLayerIndex * 10 + 1
		
		"
background-position: #{left}px #{top}px; 
width: #{width}px; height: #{height}px; 
background-image: url('/resource#{imageUrl}'); 
z-index: #{zIndex}
"

	).property(
		'environment.object'
		'landscapeController.currentDrawTool'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
		'navBarSelection.mode'
	)
	
	soloChanged: (->
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		roomLayers = @get 'roomLayers'
		solo = @get 'landscapeController.solo'
		
		if solo
			
			for roomLayer, index in roomLayers
				roomLayer.set 'solo', currentLayerIndex isnt index
			
		else
			roomLayer.set 'solo', false for roomLayer in roomLayers
			
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
		
	).observes 'undoGroup'
	
	undoStackChanged: (->
		
		return unless (undoStack = @get 'undoStack')?
		
		$('#document-undo, #document-redo').each (i, elm) =>
			$(elm).closest('li').toggleClass(
				'disabled', not undoStack?["can#{['Undo', 'Redo'][i]}"]()
			)
			
	).observes 'undoStack'
	
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
	
	swipeyReset: (->
		
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
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
					tilesetObject.tileSize()
				)
			)
		)
		
		swipey.setOffset [0, 0]
		
	).observes 'currentRoom.object', 'environment.tileset.object', 'swipey'

	positionTranslatedToTile: (position) ->
		
		return [0, 0] unless (tilesetObject = @get 'environment.tileset.object')?
		
		$environmentDocument = $('#environment-document')
		offset = $environmentDocument.offset()
		
		position = Vector.sub(
			Vector.add(
				position
				[$(window).scrollLeft(), $(window).scrollTop()]
			)
			[offset.left, offset.top]
		)
		
		position = Vector.floor Vector.div position, tilesetObject.tileSize()
		
	positionTranslatedToLayer: (position) ->
		
		return [0, 0] unless (swipey = @get 'swipey')?
		
		position = @positionTranslatedToTile position
		
		position = Vector.add position, swipey.offset()
		
	positionTranslatedToOverlay: (position) ->
		
		return [0, 0] unless (tilesetObject = @get 'environment.tileset.object')?
				
		position = @positionTranslatedToTile position
		
		position = Vector.mul position, tilesetObject.tileSize()
		
	tileMatrixFromSelectionMatrix: (selectionMatrix) ->
		
		return [[0]] unless (selectionMatrix = @get 'landscapeController.tilesetSelectionMatrix')?
		return [[0]] unless (tilesetObject = @get 'environment.tileset.object')?
		
		index = selectionMatrix[1] * tilesetObject.tiles()[0] + selectionMatrix[0]
		
		tileMatrix = []
		for y in [0...selectionMatrix[3]]
			
			row = []
			tileMatrix.push row
			
			for x in [0...selectionMatrix[2]]
				
				tileIndex = index + y * tilesetObject.tiles()[0] + x
				
				row.push tileIndex
				
		tileMatrix
	
	commitDrawCommands: ->
		
		return if (drawCommands = @get 'drawCommands').length is 0
		return unless (undoStack = @get 'undoStack')?		
		
		draws = _.map drawCommands, _.identity
		
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
		
	didInsertElement: ->
		
		controller = @get 'controller'
		
		$('#document-undo, #document-redo').each (i, elm) =>
			$(elm).click =>
				(@get 'undoStack')?[['undo', 'redo'][i]]()
				false

		controller.roomChanged()
		
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
				
				@set 'drawing', true
				@set 'drawCommands', []
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mousedown']?.call currentDrawTool, event, this
				
				false
		)
		
		$environmentDocument.on(
			"#{mousemove}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mousemove']?.call currentDrawTool, event, this
				
				false
		)
		
		$el.on(
			"#{mouseup}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				return unless @get 'drawing'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseup']?.call currentDrawTool, event, this
				
				@commitDrawCommands()
				
				@set 'drawing', false
				
				false
		)
		
		$environmentDocument.on(
			"#{mouseout}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseout']?.call currentDrawTool, event, this
				
				false
		)
		
		$environmentDocument.on(
			"#{mouseover}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseover']?.call currentDrawTool, event, this
				
				false
		)
		
		# Attach swiping behaviors to the tileset.
		swipey = new Swipey $environmentDocument, 'environmentSwipey'
		swipey.on 'update', (offset) =>
			
			return unless (tilesetObject = @get 'environment.tileset.object')?
			
			tileSize = tilesetObject.tileSize()
			
			# Update the tileset image offset.
			[left, top] = Vector.mul(
				offset
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
