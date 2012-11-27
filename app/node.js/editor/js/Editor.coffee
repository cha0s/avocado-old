Vector = require 'core/Extension/Vector'

requires_['Persea/Editor'] = (module, exports) ->

	module.exports = class
		
		constructor: (@persea) ->
			return unless @persea?
			
			@subject = @persea.subject
			
		controls: ->
		
		calculateTileFromMousePosition: (mousePosition) ->
		
			Vector.scale(
				Vector.floor Vector.scale(
					Vector.sub(
						mousePosition
						@subject.offset
					)
					1 / 16
				)
				16
			)
		
		canvasMouseDown: ->
		
		canvasMouseMove: ({position}) ->
		
			@subject.lastMousePosition = position
		
		canvasMouseLeave: ->
		
			@subject.lastMousePosition = [-1, -1]
	
		canvasMouseUp: ->
		
		sizeChanged: ->
		
