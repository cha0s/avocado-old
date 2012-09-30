
# Register a stderr logging strategy.
avo.Logger.registerStrategy (message, type) ->
	
	# Colors for the console.
	colors =
	
		error : '\x1B[1;31m'
		warn  : '\x1B[1;33m'
		info  : '\x1B[1;32m'
		reset : '\x1B[0m'
		
	# TYPE:
	# message
	avo.CoreService.writeStderr "#{
		colors[type]
	}#{
		type.toUpperCase()
	}#{
		colors.reset
	}:"
	
	avo.CoreService.writeStderr message

avo.Logger.info 'Main engine loop...'
