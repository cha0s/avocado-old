class avo.CoreService

avo.CoreService['%writeStderr'] = ->
	
	console?.log? argument for argument in arguments

resourceMap = {}
avo.CoreService['%readResource'] = (uri) ->
	
	defer = upon.defer()
	
	if resourceMap[uri]?
		
		defer.resolve resourceMap[uri]
		
	else 
		
		request = new XMLHttpRequest()
		request.open 'GET', "#{avo.ResourcePath}#{uri}"
		request.onreadystatechange = ->
			
			if request.readyState is 4
				defer.resolve resourceMap[uri] = request.responseText
		
		request.send()

	defer.promise
