
Dom = require 'core/Utility/Dom'
EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'
Rectangle = require 'core/Extension/Rectangle'

module.exports = class
	
	constructor: ->
		
		Window = require('Graphics').Window
		
		Mixin this, EventEmitter
		
		@Canvas = document.createElement 'canvas'
		@Canvas.setAttribute 'tabIndex', 1
		
		@offset_ = [0, 0]
		
		@keyDowns_ = []
		@keyUps_ = []
		@mouseMoves_ = []
		@mouseButtonDowns_ = []
		@mouseButtonUps_ = []
		
		@Canvas.onmousemove = (event) =>
			
			mouseEvent = event ? window.event
			
			@mouseMoves_.push
				x: mouseEvent.clientX - @offset_[0]
				y: mouseEvent.clientY - @offset_[1]
		
		browserMouseButtonMap =
			0: Window.LeftButton
			1: Window.MiddleButton
			2: Window.RightButton
		
		@Canvas.onmousedown = (event) =>
			
			mouseEvent = event ? window.event
			
			@mouseButtonDowns_.push
				x: mouseEvent.clientX - @offset_[0]
				y: mouseEvent.clientY - @offset_[1]
				button: browserMouseButtonMap[mouseEvent.button]
		
		document.onmouseup = (event) =>
			
			mouseEvent = event ? window.event
			
			@mouseButtonUps_.push
				x: mouseEvent.clientX - @offset_[0]
				y: mouseEvent.clientY - @offset_[1]
				button: browserMouseButtonMap[mouseEvent.button]
		
		@Canvas.onkeydown = (event) =>
			
			keyEvent = event ? window.event
			
			@keyDowns_.push code: keyEvent.keyCode
			
		document.onkeyup = (event) =>
			
			keyEvent = event ? window.event
			
			@keyUps_.push code: keyEvent.keyCode
	
	calculateOffset: -> 
		
		@offset_ = Dom.calculateOffset @Canvas 
	
	'%display': ->
	
	'%height': -> @Canvas.height
	
	'%pollEvents': ->
		
		@emit 'keyDown', keyDown for keyDown in @keyDowns_
		@keyDowns_ = []
		
		@emit 'keyUp', keyUp for keyUp in @keyUps_
		@keyUps_ = []
	
		@emit 'mouseMove', mouseMove for mouseMove in @mouseMoves_
		@mouseMoves_ = []
		
		@emit 'mouseButtonDown', mouseButtonDown for mouseButtonDown in @mouseButtonDowns_
		@mouseButtonDowns_ = []
		
		@emit 'mouseButtonUp', mouseButtonUp for mouseButtonUp in @mouseButtonUps_
		@mouseButtonUps_ = []
	
	'%render': (image, rectangle) ->
		
		Image = require('Graphics').Image
		
		image.render(
			Rectangle.position rectangle
			this
			255
			Image.DrawMode_Blend
			rectangle
		)
		
	'%setFlags': (flags) ->
	
	'%setSize': (size) -> [@Canvas.width, @Canvas.height] = size
	
	'%setMouseVisibility': (visibility) ->
	
	'%setWindowTitle': (window_, iconified) ->
		
		window.document.title = window_
	
	'%size': -> [@Canvas.width, @Canvas.height]
	
	'%width': -> @Canvas.width
