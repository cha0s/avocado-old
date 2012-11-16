
AbstractState = require 'core/State/AbstractState'
DisplayList = require 'core/Graphics/DisplayList'
Environment = require 'core/Environment/2D/Environment'
Graphics = require 'Graphics'
Rectangle = require 'core/Extension/Rectangle'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

module.exports = class extends AbstractState
	
	initialize: ->
		
		@cameraPosition = [0, 0]
		
		super
	
	enter: ({
		environmentUri
		@roomIndex
	}) ->
		
		# Load the environment, an entity to walk around in it, and a font to
		# show the renders and ticks per second, for informational purposes.
		upon.all([
			
			Environment.load(environmentUri).then (@environment) =>
				
		]).then =>
			
			@currentRoom = @environment.room @roomIndex
			
			@roomRectangle = Rectangle.compose(
				[0, 0]
				Vector.mul(
					@currentRoom.size()
					@environment.tileset().tileSize()
				)
			)
			
			# Keep a display list to optimize rendering.
			@displayList = new DisplayList [0, 0, 720, 450], @roomRectangle
			
			# Since we can't rely on graphics SPIIs letting us know when our
			# graphics need to be rewritten, we'll suggest redrawing the entire
			# screen 10 times a second.
			setInterval (=> @displayList.markAllCommandsAsDirty()), 100
		
	lerp: (actual, lerping, easing = .25) ->
		
		return actual if easing is 0
		
		distance = Vector.cartesianDistance(
			actual
			lerping
		)
		return actual if distance is 0
		
		Vector.add(
			lerping
			Vector.scale(
				Vector.hypotenuse(
					actual
					lerping
				)
				if distance is 0
					0
				else
					(Math.min 10, distance / 16) / easing
			)
		)
	
			
	setCamera: (position, easing = .25) ->
				
		newPosition = Vector.clamp(
			Vector.sub(
				Vector.round position
				Vector.scale Graphics.window.originalSize, .5
			)
			[0, 0]
			Vector.sub(
				Rectangle.size @roomRectangle
				Graphics.window.originalSize
			)
		)
		
		@displayList.setPosition(
			Vector.round @cameraPosition = @lerp newPosition, @cameraPosition, easing
		)
		
	# Called repeatedly to allow the state to render graphics.
	render: (buffer) ->
		
		# Render the anything dirty. This will also pass back the dirty areas.
		@displayList.render buffer
		
	# Called when another state is loaded. This gives you a chance to clean
	# up resources and event handlers.
	leave: (nextStateName) ->
		
		@displayList.clear()
