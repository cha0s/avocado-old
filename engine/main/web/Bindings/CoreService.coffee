upon = require 'core/Utility/upon'

module.exports = CoreService = class

CoreService.EnginePath = '/engine'
CoreService.ResourcePath = '/resource'

CoreService['%writeStderr'] = ->
	
	console?.log? argument for argument in arguments

resourceMap = {}
CoreService['%readResource'] = (uri, fn) ->
	
	if resourceMap[uri]?
		
		fn resourceMap[uri]
		
	else 
		
		request = new XMLHttpRequest()
		request.open 'GET', "#{CoreService.ResourcePath}#{uri}"
		request.onreadystatechange = ->
			
			if request.readyState is 4
				fn resourceMap[uri] = request.responseText
		
		request.send()
