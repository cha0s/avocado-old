Image = require('Graphics').Image
NavBar = require 'Persea/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
Vector = require 'core/Extension/Vector'

LayersView = Ember.CollectionView.extend
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	itemViewClass: Ember.View.extend
		
		attributeBindings: ['unselectable']
		unselectable: 'on'
		
		didInsertElement: ->
			
			$layer = @$()
			
			i = $layer.index()
			roomObject = @get 'content.roomObject'
			environmentObject = @get 'content.environmentObject'
			
			sizeInTiles = roomObject.size()
			tileset = environmentObject.tileset()
			tileSize = tileset.tileSize()
			
			layer = new Image()
			layer.Canvas = $('canvas', $layer)[0]
			
#			blob = new Blob ["""
#
#// Render a freakin' layer!
#
#			"""], type: 'text/javascript'
			
			_.defer(
				(i) =>
					
					###
					
					_.defer ->
						
						roomObject.layer(i).fastRender(
							tileset
							layer
						)
					
					###
					
					###
					
					roomObject.layer(i).render(
						[0, 0]
						tileset
						layer
					)
					
					###
					
					
					j = 0
					
					renderTile = =>
						
						y = j
						
						for x in [0...sizeInTiles[0]]
							position = Vector.mul tileSize, [x, y]
							
							index = roomObject.layer(i).tileIndex [x, y]
							tileset.render(
								position
								layer
								index
							) if index
						
						j += 1
						
						_.defer renderTile if j < sizeInTiles[1]
						
					renderTile()
						
				i
			)
		
		classNames: ['layer']
		template: Ember.Handlebars.compile """

<canvas
	unselectable="on"
	class="canvas"
	{{bindAttr width="view.content.width"}}
	{{bindAttr height="view.content.height"}}
	{{bindAttr style="view.content.style"}}
>
</canvas>

"""

Controller = exports.Controller = Ember.Controller.extend
	
	navBarContent: [
		noLink: true
		id: 'environment-document-mode'
		text: 'Mode'
	,
		mode: 'move'
		i: 'icon-move'
		title: 'Move: Click and drag or swipe to move the environment.'
	,
		mode: 'edit'
		i: 'icon-pencil'
		title: 'Edit: Click/tap and drag to draw upon the environment.'
	]
	navBarSelection: null
	navBarView: NavBar.View
	
	selectedMode: (->
		
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
	
	environment: null
	
	layersContent: []
	layersView: LayersView
	
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

	layersChanged: (->
		
		return unless (environmentObject = @get 'environment.object')?
		return unless (roomObject = @get 'currentRoom.object')?
		
		canvasSize = Vector.mul(
			roomObject.size()
			environmentObject.tileset().tileSize()
		)
		
		layersContent = for i in [0...roomObject.layerCount()]
			
			Ember.Controller.create
				
				style: "z-index: #{i * 10};"
				
				roomObject: roomObject
				environmentObject: environmentObject
				
				width: canvasSize[0]
				height: canvasSize[1]
			
		layersContent.roomObject = roomObject
		layersContent.environmentObject = environmentObject
		
		@set 'layersContent', layersContent
		
	).observes 'currentRoom.object', 'environment.object'

exports.View = Ember.View.extend
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	handleResize: _.throttle(
		->
			
			return unless (environmentObject = @get 'controller.environment.object')?
			return unless (roomObject = @get 'controller.currentRoom.object')?
			
			$el = $('#environment-document')
			
			offset = $el.offset()
			
			windowHeight = $(window).height()
			
			autoCanvasHeight = windowHeight
			
			footerOffset = $('#footer').offset()
			unless autoCanvasHeight < footerOffset.top
				autoCanvasHeight -= $('#footer').height()
			
			autoCanvasHeight -= offset.top
			
			$row = $el.parent()
			
			rowOffset = $row.offset()
			
			width = $row.width() - (offset.left - rowOffset.left)
			
			height = Math.max(
				320
				if autoCanvasHeight <= 0
					windowHeight - 40
				else
					autoCanvasHeight
			)
			
			tileSize = environmentObject.tileset().tileSize()
			
			canvasSize = Vector.mul(
				roomObject.size()
				tileSize
			)
			
			size = Vector.mul(
				Vector.floor Vector.div(
					Vector.min [width, height], canvasSize
					tileSize
				)
				tileSize
			)
			
			$el.css
				width: size[0]
				height: size[1]
				
			$el.parent().css
				background: 'none'
			
			@get('controller').swipeyReset()
			
		75
	).observes 'controller.currentRoom.object', 'controller.environment.object'
		
	drawOverlayStyle: (->
		
		return unless (environmentObject = @get 'controller.environment.object')?
		
		matrix = @get 'controller.landscapeController.tilesetSelectionMatrix'
		mode = @get 'controller.navBarSelection.mode'
		selectedLayer = @get 'controller.landscapeController.layersSelection'
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		left = tileSize[0] * -matrix[0]
		top = tileSize[1] * -matrix[1]
		width = tileSize[0] * matrix[2]
		height = tileSize[1] * matrix[3]
		zIndex = selectedLayer * 10 + 1
		
		"
background-position: #{left}px #{top}px; 
width: #{width}px; height: #{height}px; 
background-image: url('/resource#{tileset.image().uri()}');
z-index: #{zIndex}
"

	).property(
		'controller.navBarSelection'
		'controller.landscapeController.tilesetSelectionMatrix'
		'controller.environment.object'
		'controller.landscapeController.layersSelection'
	)
	
	soloChanged: (->
		
		layersContent = @get 'controller.layersContent'
		solo = @get 'controller.landscapeController.solo'
		selectedLayer = @get 'controller.landscapeController.layersSelection'
		
		$layers = @$().find '.layers'
		
		if solo
			
			$layers.find('.layer').hide()	
			$layers.find('.layer').eq(selectedLayer).show()	
			
		else
			
			$layers.find('.layer').show()
		
	).observes 'controller.landscapeController.solo', 'controller.layersContent', 'controller.landscapeController.layersSelection'
	
	paintTiles: (position) ->
	
		return unless (environmentObject = @get 'controller.environment.object')?
		return unless (roomObject = @get 'controller.currentRoom.object')?
		return unless (swipey = @get 'controller.swipey')?
		
		$environmentDocument = $('#environment-document')
		layersSelection = @get 'controller.landscapeController.layersSelection'
		matrix = @get 'controller.landscapeController.tilesetSelectionMatrix'
		tileset = environmentObject.tileset()
		tileSize = tileset.tileSize()
		
		index = matrix[1] * tileset.tiles()[0] + matrix[0]
		layer = roomObject.layer layersSelection
		
		layerImage = new Image()
		
		layerImage.Canvas = $('.layers canvas', $environmentDocument).eq(layersSelection)[0]
		
		offset = $environmentDocument.offset()			
		position = Vector.sub(
			Vector.add(
				position
				[$(window).scrollLeft(), $(window).scrollTop()]
			)
			[offset.left, offset.top]
		)
		
		position = Vector.floor Vector.div position, tileset.tileSize()
		
		position = Vector.add position, swipey.offset()
		
		layerImage.drawFilledBox Rectangle.compose(
			Vector.mul tileSize, position
			Vector.mul tileSize, Rectangle.size matrix
		), 0, 0, 0, 0
		
		tileMatrix = []
		for y in [0...matrix[3]]
			
			row = []
			tileMatrix.push row
			
			for x in [0...matrix[2]]
				
				tileIndex = index + y * tileset.tiles()[0] + x
				
				tileset.render(
					Vector.add(
						Vector.mul position, tileSize
						Vector.mul [x, y], tileSize
					)
					layerImage
					tileIndex
				) if index
				
				row.push tileIndex
				
		layer.setTileMatrix tileMatrix, position
		
	didInsertElement: ->
		
		(($) =>
			
			$environmentDocument = $('#environment-document')
			
			$('.draw-overlay', $environmentDocument).css opacity: .85, width: 16, height: 16
				
			(pulseSelection = ->
				$('.draw-overlay', $environmentDocument).animate
					opacity: .45
				,
					500
					->
						$('.draw-overlay', $environmentDocument).animate
							opacity: .85
						,
							500
							pulseSelection
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
					
					return if 'move' is @get 'controller.navBarSelection.mode'
					
					holding = true
		
					@paintTiles [event.clientX, event.clientY]
					
					false
			)
			
			setOverlayPosition = _.throttle(
				(position) ->
				
					$('.draw-overlay', $environmentDocument).css
						left: position[0]
						top: position[1]
				50
			)
			
			$environmentDocument.on(
				"#{mousemove}.environmentDocument"
				(event) =>
					
					return if 'move' is @get 'controller.navBarSelection.mode'
					
					return unless (environmentObject = @get 'controller.environment.object')?

					offset = $environmentDocument.offset()			
					position = Vector.sub(
						Vector.add(
							[event.clientX, event.clientY]
							[$(window).scrollLeft(), $(window).scrollTop()]
						)
						[offset.left, offset.top]
					)
					tileSize = environmentObject.tileset().tileSize()
					
					position = Vector.mul(
						Vector.floor Vector.div(
							position
							tileSize
						)
						tileSize
					)
					
					setOverlayPosition position
					
					if holding
						
						@paintTiles [event.clientX, event.clientY]
					
					false
			)
			
			$environmentDocument.on(
				"#{mouseout}.environmentDocument"
				=>
					
					return if 'move' is @get 'controller.navBarSelection.mode'
					
					$('.draw-overlay', $environmentDocument).hide()
					
					false
			)
			
			$environmentDocument.on(
				"#{mouseover}.environmentDocument"
				=>
					
					return if 'move' is @get 'controller.navBarSelection.mode'
					
					$('.draw-overlay', $environmentDocument).show()
					
					false
			)
			
			$el.on(
				"#{mouseup}.environmentDocument"
				=>
					
					return if 'move' is @get 'controller.navBarSelection.mode'
					
					holding = false
					
					false
			)
			
			# Attach swiping behaviors to the tileset.
			swipey = new Swipey $environmentDocument, 'environmentSwipey'
			swipey.on 'update', (offset) =>
				
				return unless (object = @get 'controller.environment.object')?
				
				tileSize = object.tileset().tileSize()
				
				# Update the tileset image offset.
				[left, top] = Vector.mul(
					Vector.floor offset
					Vector.scale tileSize, -1
				)
				
				$('.layers', $environmentDocument).css left: left, top: top
				
			@set 'controller.swipey', swipey
			
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
				
			@set 'controller.navBarSelection', @get('controller.navBarContent')[1]
			
		) jQuery
		
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
	
	{{view layersView
		class="layers"
		contentBinding="layersContent"
	}}
	
</div>

"""
