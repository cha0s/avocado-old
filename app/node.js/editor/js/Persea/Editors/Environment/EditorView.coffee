
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
		@$canvas
	}) ->
		
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
		
		@swipey = new Swipey @$tileset
		@swipey.on 'update', (offset) =>
			
			offset = Vector.floor offset
			tileSize = @tileset.tileSize()
			
			@$tilesetImage.css
				left: offset[0] * -tileSize[0]
				top: offset[1] * -tileSize[1]
		
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
		
		@$tileset.on(
			if Modernizr.touch then 'vmousedown' else 'mousedown'
			(event) =>
				
				taps += 1
				compoundTapEvent()
				
				true
		)
		
		@$tileset.on
			
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
		
		@model.tilesetOffset ?= [0, 0]
		
		bg = "url(\"#{@tileset.image().src}\")"
		
		@$tilesetImage.css
			width: @tileset.image().width()
			height: @tileset.image().height()
			'background-image': bg
		
		return if $("link[uri=\"#{@tileset.image().src}\"]").length > 0
		
		$link = $ '<link>'
		
		$link.attr
			id: 'tileset-index'
			uri: @tileset.image().src
			rel: 'stylesheet'
			type: 'text/css'
			media: 'all'
		
		index = 0
		html = ''
		tiles = @tileset.tiles()
		tileSize = @tileset.tileSize()
		for y in [0...tiles[1]]
			for x in [0...tiles[0]]
				html += "
					#persea #subject .tile[tile-index=\"#{index++}\"] {
						background-image: #{bg};
						background-position: -#{x * tileSize[0]}px -#{y * tileSize[1]}px;
					}\n
				"
		
		$link.attr
			href: 'data:text/css,'+escape(html);
		$('head').append $link
		
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
