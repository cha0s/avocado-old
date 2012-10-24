CoreService = require('Core').CoreService
Room = require 'core/Environment/2D/Room'
Tileset = require 'core/Environment/2D/Tileset'
upon = require 'core/Utility/upon'

module.exports = Environment = class
	
	constructor: ->
		
		@tileset_ = new Tileset()
		@rooms_ = []
		@name_ = ''
		
	fromObject: (O) ->
		
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		tilesetPromise = Tileset.load(O.tilesetUri).then (@tileset_) =>
			
		promiseRoom = (O, i) =>
			room = new Room()
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
		
		CoreService.readJsonResource(uri).then (O) ->
		
			environment = new Environment()
			
			O.uri = uri
			environment.fromObject(O).then ->
				defer.resolve environment
		
		defer.promise
	
	room: (index) -> @rooms_[index]
	
	tileset: -> @tileset_
	
	copy: ->
		
		environment = new Environment()
		environment.fromObject @toJSON()
		
		environment
	
	toJSON: ->
		
		name: @name_
		prefix: @prefix_
		tileSize: @tileSize_
#		tilesetUri: @tileset_.image().uri()
		rooms: @rooms_
