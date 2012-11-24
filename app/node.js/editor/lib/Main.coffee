# Subclass Main. We update the elapsed time manually, since we don't get
# a tight loop like on native platforms; everything is interval-based in a
# browser.

Core = require 'Core'
Graphics = require 'Graphics'
Logger = require 'core/Utility/Logger'
Timing = require 'Timing'

# Register a logging strategy.
Logger.registerStrategy (message, type) ->
	
	# TYPE:
	Core.CoreService.writeStderr type.toUpperCase()
	
	# message
	Core.CoreService.writeStderr message

# SPI proxies.
require 'core/proxySpiis'

DisplayList = require 'core/Graphics/DisplayList'
Dom = require 'core/Utility/Dom'
Rectangle = require 'core/Extension/Rectangle'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

socket = io.connect 'http://editor.avocado.cha0sb0x.ath.cx'

class Editor
	
	constructor: (@avocadoEditor) ->
		
		@editorCanvasLastMousePosition = [-1, -1]
	
	controls: ->
	
	calculateTileFromMousePosition: (mousePosition) ->
	
		Vector.scale(
			Vector.floor Vector.scale(
				Vector.sub(
					mousePosition
					@avocadoEditor.editorCanvasOffset
				)
				1 / 16
			)
			16
		)
	
	canvasMouseDown: ->
	
	canvasMouseMove: ({position}) ->
	
		@editorCanvasLastMousePosition = position
	
	canvasMouseLeave: ->
	
		@editorCanvasLastMousePosition = [-1, -1]

	canvasMouseUp: ->
	
class EnvironmentEditor	 extends Editor

	constructor: (avocadoEditor) ->
		
		super avocadoEditor
		
		@drawing = false
		
		@tilesetImage = new Graphics.Image [256, 256]
		
		$(document).mouseup => @drawing = false
	
		require(
			'core/Environment/2D/Environment'
		).load(
			'/environment/wb-forest.environment.json'
		).then (@environment) =>
			
			@environment.room(0).layer(0).render(
				[0, 0]
				@environment.tileset()
				avocadoEditor.editorCanvas
			)
			
			@environment.tileset().image().render(
				[0, 0]
				@tilesetImage
			)
	
	controls: ->
		
		$controls = $('<div id="environment-controls" />')
		
		$controls.append @tilesetImage.Canvas
		
		$controls
	
	drawAt: (position) ->
	
		tile = Vector.scale(
			@calculateTileFromMousePosition position
			1 / 16
		)
	
		@environment.room(0).layer(0).setTileIndex(
			51
			tile
		)
		
	canvasMouseDown: ({position, button}) ->
	
		@drawing = true
		
		@drawAt position
		
	canvasMouseMove: ({position}) ->
		
		@drawAt position if @drawing
	
		unless Vector.equals @editorCanvasLastMousePosition, [-1, -1]
			
			lastTile = @calculateTileFromMousePosition @editorCanvasLastMousePosition
			
			@environment.room(0).layer(0).render(
				[0, 0]
				@environment.tileset()
				@avocadoEditor.editorCanvas
				[
					lastTile[0]
					lastTile[1]
					17
					17
				]
			)
		
		tile = @calculateTileFromMousePosition position
		
		@avocadoEditor.editorCanvas.drawLineBox [
			tile[0]
			tile[1]
			16
			16
		], 255, 255, 255, 155
		
		super
	
	canvasMouseLeave: ->
	
		lastTile = @calculateTileFromMousePosition @editorCanvasLastMousePosition
		
		@environment.room(0).layer(0).render(
			[0, 0]
			@environment.tileset()
			@avocadoEditor.editorCanvas
			[
				lastTile[0]
				lastTile[1]
				17
				17
			]
		)
		
		super

class AvocadoEditor
	
	constructor: ->
		
		@domDefer = upon.defer()
		
		@editorCanvas = new Graphics.Image [640, 480]
		
		@editorCanvas.fill 230, 230, 230
		
		@editorCanvasRectangle = [0, 0, 640, 480]
		
		@editorCanvasLastMousePosition = [-1, -1]
		
		@editor = new Editor()
		
	setEditor: (@editor) ->
		
		@domDefer.then =>
		
			$('#editorControls-container').empty()
			
			$('#editorControls-container').append @editor.controls()
		
	domReady: ->
	
		$('#editorCanvas-container').append @editorCanvas.Canvas
		
		@editorCanvasOffset = Dom.calculateOffset @editorCanvas.Canvas
		
		@editorCanvasRectangle = Rectangle.translated(
			@editorCanvasRectangle
			@editorCanvasOffset
		)
		
		$(@editorCanvas.Canvas).mousedown (event) =>
			@editor.canvasMouseDown
				position: [event.pageX, event.pageY]

		$(@editorCanvas.Canvas).mouseleave (event) =>
			@editor.canvasMouseLeave()

		$(@editorCanvas.Canvas).mousemove (event) =>
			@editor.canvasMouseMove
				position: [event.pageX, event.pageY]

		$(@editorCanvas.Canvas).mouseup (event) =>
			@editor.canvasMouseUp
				position: [event.pageX, event.pageY]
				
		@domDefer.resolve()

avocadoEditor = new AvocadoEditor

avocadoEditor.setEditor new EnvironmentEditor avocadoEditor

$(document).ready -> avocadoEditor.domReady()
			
socket.on 'connect', ->
	
#	alert environmentImage.Canvas
