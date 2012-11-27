
CoreService = require 'main/web/Bindings/CoreService'
upon = require 'core/Utility/upon'

Images = {}
module.exports = AvoImage = class
	
	constructor: (width, height) ->

		@URI = ''
		@Pixels = null
		@Canvas = document.createElement 'canvas'
		
		if width?
			
			[width, height] = width if width instanceof Array
		
			@Canvas.width = width
			@Canvas.height = height

	@['%load'] = (uri, fn) ->
		
		defer = upon.defer()
		
		i = new AvoImage()
		
		resolve = ->
			
			i.URI = uri
			i.BrowserImage = Images[uri]
			i.Canvas = document.createElement 'canvas'
			
			i.Canvas.width = i.BrowserImage.width
			i.Canvas.height = i.BrowserImage.height
			
			context = i.Canvas.getContext '2d'
			context.drawImage i.BrowserImage, 0, 0
			
			defer.resolve i
			fn i
		
		if Images[uri]?
		
			Images[uri].defer.then -> resolve()
			
		else
		
			Images[uri] = new Image()
			Images[uri].onload = resolve
			Images[uri].defer = upon.defer()
			
			defer.then -> Images[uri].defer.resolve()
			
			Images[uri].src = "#{CoreService.ResourcePath}#{uri}"
		
		defer.promise
	
	rgbToHex = (r, g, b, a) ->
	
		if a?
			"rgba(#{r}, #{g}, #{b}, #{a})"
		else
			"rgb(#{r}, #{g}, #{b})"
			
	'%drawFilledBox': (box, r, g, b, a, mode) ->
		
		context = @Canvas.getContext '2d'
		
		oldAlpha = context.globalAlpha
		
		context.globalAlpha = a / 255
		
		context.fillStyle = rgbToHex r, g, b, a
		context.fillRect box[0], box[1], box[2], box[3]
		
		context.globalAlpha = oldAlpha
	
	'%drawLine': (line, r, g, b, a, mode) ->
		
		context = @Canvas.getContext '2d'
	
		context.beginPath()
		context.moveTo line[0], line[1]
		context.lineTo line[2], line[3]
		
		context.fillStyle = rgbToHex r, g, b, a
		context.stroke()
	
	'%drawLineBox': (box, r, g, b, a, mode) ->
		
		context = @Canvas.getContext '2d'
		
		context.lineCap = 'butt';
		context.fillStyle = context.strokeStyle = rgbToHex r, g, b, a
		
		context.strokeRect box[0] + .5, box[1] + .5, box[2], box[3]
	
	'%fill': (r, g, b, a) ->
		
		context = @Canvas.getContext '2d'
		
		# HACK!
		if a > 0
			context.rect 0, 0, @width(), @height()
			context.fillStyle = rgbToHex r, g, b, a
			context.fill() 
		else
			context.clearRect(0, 0, @width(), @height())
	
	'%width': -> @Canvas.width
	
	'%height': -> @Canvas.height
	
	'%lockPixels': ->
		
		unless @Pixels?
			
			@Pixels = @Canvas.getContext('2d').getImageData 0, 0, @width(), @height()
	
	'%pixelAt': (x, y) ->
		
		if @Pixels?
		
			data = @Pixels.data
			i = (y * @width() + x) * 4
			
		else
			
			data = @Canvas.getContext('2d').getImageData(x, y, 1, 1).data
			i = 0
		
		(data[i + 3] << 24) | (data[i] << 16) | (data[i + 1] << 8 ) | data[i + 2]
	
	'%render': (position, destination, alpha, mode, sourceRect) ->
		context = destination.Canvas.getContext '2d'
		
		sourceRect[2] = @width() if sourceRect[2] is 0
		sourceRect[3] = @height() if sourceRect[3] is 0
		
		context.globalAlpha = alpha / 255
		
		sourceRect[0] = 0 if sourceRect[0] < 0
		sourceRect[1] = 0 if sourceRect[1] < 0
		position[0] = 0 if position[0] < 0
		position[1] = 0 if position[1] < 0
		
		context.drawImage(
			@Canvas
			sourceRect[0], sourceRect[1], sourceRect[2], sourceRect[3]
			position[0], position[1], sourceRect[2], sourceRect[3]
		)
		
		context.globalAlpha = 1.0
	
	'%renderGrayscale': (destination, amount, darken) ->
		
		d = @Canvas.getContext('2d').getImageData(0, 0, @width(), @height()).data
		
		context = destination.Canvas.getContext '2d'
		imageData = context.getImageData 0, 0, @width(), @height()
		e = imageData.data
		w = @width()
		
		for y in [0...@height()]
			for x in [0...@width()]
		
				i = (y * w + x) * 4
				
				r = d[i    ]
				g = d[i + 1]
				b = d[i + 2]
	
				grgb = darken * Math.min(
					255.0
					r * .3 + g * .59 + b * .11
				)
				
				e[i    ] = r - (r - grgb) * amount
				e[i + 1] = g - (g - grgb) * amount
				e[i + 2] = b - (b - grgb) * amount
				e[i + 3] = 255
		
		context.putImageData imageData, 0, 0
	
	'%setPixelAt': (x, y, c) ->
		
		return unless x >= 0 and y >= 0 and x < @width() and y < @height()
	
		if @Pixels?
			
			imageData = @Pixels
			i = (y * @width() + x) * 4
			
		else
			
			imageData = @Canvas.getContext('2d').createImageData 1, 1
			i = 0
		
		imageData.data[i    ] = (c >>> 16) & 255
		imageData.data[i + 1] = (c >>> 8) & 255
		imageData.data[i + 2] = c & 255
		imageData.data[i + 3] = c >>> 24
		
		unless @Pixels?
			
			@Canvas.getContext('2d').putImageData imageData, x, y
	
	'%unlockPixels': ->
		
		if @Pixels?
			
			@Canvas.getContext('2d').putImageData @Pixels, 0, 0
			@Pixels = null
	
	'%uri': -> @URI

