# SPI proxy and constant definitions.

# Low-level API; writes a message to stderr (or equivalent, depending on
# platform). 
avo.CoreService.writeStderr = avo.CoreService['%writeStderr']

# Low-level API; reads a resource into a string. Returns a promise to be
# resolved with the string containing the resource data. 
avo.CoreService.readResource = avo.CoreService['%readResource']

# Low-level API; reads a JSON resource. Returns a promise to be resolved with
# the parsed JSON object.
avo.CoreService.readJsonResource = (uri) ->
	
	defer = upon.defer()
	
	@readResource(uri).then (resource) -> defer.resolve JSON.parse resource
	
	defer.promise
