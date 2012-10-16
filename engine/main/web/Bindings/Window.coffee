class avo.Window
	
	constructor: ->
		
		avo.Mixin this, avo.EventEmitter
		
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
			0: avo.Window.LeftButton
			1: avo.Window.MiddleButton
			2: avo.Window.RightButton
		
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
	
		obj = @Canvas
		
		@offset_[0] = obj.offsetLeft
		@offset_[1] = obj.offsetTop
		while obj = obj.offsetParent
			@offset_[0] += obj.offsetLeft
			@offset_[1] += obj.offsetTop
	
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
		
		image.render(
			avo.Rectangle.position rectangle
			this
			255
			avo.Image.DrawMode_Blend
			rectangle
		)
		
	'%setFlags': (flags) ->
	
	'%setSize': (size) -> [@Canvas.width, @Canvas.height] = size
	
	'%setMouseVisibility': (visibility) ->
	
	'%setWindowTitle': (window_, iconified) ->
		
		window.document.title = window_
	
	'%size': -> [@Canvas.width, @Canvas.height]
	
	'%width': -> @Canvas.width
