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
	drawContent: [
		'Paintbrush'
		'Floodfill'
		'Random flood'
	]
	currentDrawMode: 'Paintbrush'
	
	layersLabel: 'Layer'
	layersContent: [0, 1, 2, 3, 4]
	currentLayerIndex: 0
	
	solo: false
