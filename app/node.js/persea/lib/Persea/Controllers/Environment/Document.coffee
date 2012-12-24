Floodfill = require 'core/Utility/Floodfill'
Image = require('Graphics').Image
Matrix = require 'core/Extension/Matrix'
NavBarView = require 'Persea/Views/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
RoomLayersView = require 'Persea/Views/Environment/RoomLayers'
UndoCommand = require 'Persea/Undo/Command'
UndoStack = require 'Persea/Undo/Stack'
UndoGroup = require 'Persea/Undo/Group'
Vector = require 'core/Extension/Vector'

module.exports = Ember.Controller.extend
	
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
	navBarView: NavBarView
	
	# Convenience property to DRY up client usage of the active undo stack.
	undoStack: (->
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.activeStack()
	).property().volatile()
	
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

