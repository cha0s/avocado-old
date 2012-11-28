requires_['Persea/Editor/Environment/EditorView'] = (module, exports) ->

	Graphics = require 'Graphics'
	Image = Graphics.Image
	
	DisplayList = require 'core/Graphics/DisplayList'
	Rectangle = require 'core/Extension/Rectangle'
	TileLayer = require 'core/Environment/2D/TileLayer'
	Vector = require 'core/Extension/Vector'
	
	module.exports = Backbone.View.extend
		
		initialize: ->
			
			$tilesetContainer = $ '<div class="tileset-container">'
			
			$tilesetContainer.append @$tileset = $ '<div class="tileset">'
			
			$tilesetContainer.append @$ySlider = $('<div class="y-slider">').slider
				orientation: 'vertical'
			$tilesetContainer.append @$xSlider = $('<div class="x-slider">').slider()
			
			@$el.append $tilesetContainer
			
			$('#editor .controls').append @$el
		
		setModel: (@model) ->
			return unless @model?
			
			@tileset = @model.subject.tileset()
			
			@model.tilesetOffset ?= [0, 0]
			
			@$tileset.html @tileset.image().Canvas
			
			canvasSize = [256, 256]
			totalSize = Vector.div @tileset.image().size(), @tileset.tileSize()
			tileSize = @tileset.tileSize()
			
			# Some magic to DRY up both axes. The max - ... stuff is due to
			# jQuery UI making 0 the bottom of vertical sliders.
			$sliders = [@$xSlider, @$ySlider]
			max = (i) -> totalSize[i] - canvasSize[i] / tileSize[i]
			offset = (i, ui) ->
				[
					ui.value
					max(1) - ui.value
				][i]
			setPosition = (i) =>
				[
					=> $(@tileset.image().Canvas).css 'left', @model.tilesetOffset[0] * -tileSize[0]
					=> $(@tileset.image().Canvas).css 'top', @model.tilesetOffset[1] * -tileSize[1]
				][i]()
			value = (i) =>
				[
					@model.tilesetOffset[i]
					max(1) - @model.tilesetOffset[i]
				][i]
				
			setPosition 0
			setPosition 1
			
			css = ['width', 'height']
			for i in [0...2]
				
				# Don't show unusable sliders.
				if 0 is max i
					$sliders[i].hide()
					continue
				else
					$sliders[i].show()
				
				((i) =>
					
					$sliders[i].css css[i], canvasSize[i] - 24
					$sliders[i].slider(
						'option'
							min: 0
							max: max i
							value: value i
							slide: (event, ui) =>
								@model.tilesetOffset[i] = offset i, ui
								setPosition i
								@render()
					)
				) i
				
			undefined
			
