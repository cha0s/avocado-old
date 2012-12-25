Vector = require 'core/Extension/Vector'

module.exports = Ember.Controller.extend
	
	environmentBinding: 'environmentController.environment'
	
	navBarContent: [
		mode: 'move'
		i: 'icon-move'
		title: 'Move: Click and drag or swipe to move the tileset.'
	,
		mode: 'edit'
		i: 'icon-pencil'
		title: 'Edit: Click/tap and drag to select tiles.'
	]
	navBarSelection: null
	
	drawLabel: 'With'
	drawTools: []
	currentDrawTool: null
	
	layersLabel: 'Layer'
	layersContent: [0, 1, 2, 3, 4]
	currentLayerIndex: 0
	
	solo: false
	
	_initDrawTools: ->
		
		drawTools = for drawTool in [
			'Paintbrush'
			'Floodfill'
			'RandomFloodfill'
		]
			
			require "Persea/Controllers/Environment/DrawTools/#{drawTool}"
			
		@set 'drawTools', drawTools
		@set 'currentDrawTool', drawTools[0]
	
	init: ->
		
		@_initDrawTools()
