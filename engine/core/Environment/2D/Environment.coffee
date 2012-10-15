class avo.Environment
	
	constructor: ->
		
		@tileset_ = new avo.Tileset()
		@rooms_ = []
		@name_ = ''
		
	fromObject: (O) ->
		
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		tilesetPromise = avo.Tileset.load(O.tilesetUri).then (@tileset_) =>
			
		promiseRoom = (O, i) =>
			room = new avo.Room()
			room.fromObject(O).then (room) => @rooms_[i] = room
		
		roomPromises = for roomInfo, i in O.rooms
			promiseRoom roomInfo, i
			
		upon.all([
			tilesetPromise
		].concat(
			roomPromises
		)).then ->
			defer.resolve()
			
		defer.promise
	
	@load: (uri) ->
	
		defer = upon.defer()
		
		avo.CoreService.readJsonResource(uri).then (O) ->
		
			environment = new avo.Environment()
			
			O.uri = uri
			environment.fromObject(O).then ->
				defer.resolve environment
		
		defer.promise
	
	room: (index) -> @rooms_[index]
	
	tileset: -> @tileset_
	
	copy: ->
		
		environment = new avo.Environment()
		environment.fromObject @toJSON()
		
		environment
	
	toJSON: ->
		
		name: @name_
		prefix: @prefix_
		tileSize: @tileSize_
#		tilesetUri: @tileset_.image().uri()
		rooms: @rooms_
