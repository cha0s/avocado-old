
# Register a stderr logging strategy.
avo.Logger.registerStrategy (message, type) ->
	
	# Colors for the console.
	colors =
	
		error : '\x1B[1;31m'
		warn  : '\x1B[1;33m'
		info  : '\x1B[1;32m'
		reset : '\x1B[0m'
		
	# TYPE:
	avo.CoreService.writeStderr "#{
		colors[type]
	}#{
		type.toUpperCase()
	}#{
		colors.reset
	}:"
	
	# message
	avo.CoreService.writeStderr message

window = new avo.Window()

window.set [640, 480]

working = new avo.Image 320, 240

avo.Image.load('/image/avocado.png').then (image) ->
	
	avo.Logger.info 'Loaded an avocado.'
	
	image.render [0, 0], working
	
	avo.Logger.info 'Rendered it to the backbuffer.'
	
	window.render working

	avo.Logger.info 'Rendered it to the screen.'
