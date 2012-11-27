
_ = require 'core/Utility/underscore'
Entity = require 'core/Entity/Entity'
TileLayer = require 'core/Environment/2D/TileLayer'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

module.exports = Room = class
	
	@layerCount: 5
		
	constructor: ->
	
		@layers_ = []
		@size_ = [0, 0]
		@name_ = ''
		@entities_ = []
		@collision_ = []
		
		@layers_[i] = new TileLayer() for i in [0...Room.layerCount]

	fromObject: (O) ->
	
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		layerPromises = for layer, i in O.layers
			
			@layers_[i] = new TileLayer()
			@layers_[i].fromObject layer
		
		@resize Vector.copy O.size
		
		entityPromises = []
		
		@entities_ = []
		
		if O.entities?
			
			promiseEntity = (entityInfo, i) =>
				
				entityDefer = upon.defer()
				
				Entity.load(entityInfo.uri).then (entity) =>
				
					extensionDefer = upon.defer()
					
					if entityInfo.traits?
						entity.extendTraits(entityInfo.traits).then ->
							extensionDefer.resolve()
					else
						extensionDefer.resolve()
						
					extensionDefer.then =>
						@addEntity entity
						entityDefer.resolve()
						
				entityDefer.promise
			
			entityPromises = for entityInfo, i in O.entities
				promiseEntity entityInfo, i
				
		upon.all(entityPromises.concat(layerPromises)).then =>
			defer.resolve this
		
		defer.promise
		
	copy: ->
		
		room = new Room()
		room.fromObject @toJSON()
		
		room
	
	reset: ->
		
		entity.reset() for entity in @entities_
		
		@startParallax()
		
	startParallax: ->
		
		@layers_[i].startParallax() for i in [0...Room.layerCount]
		
	stopParallax: ->
		
		@layers_[i].stopParallax() for i in [0...Room.layerCount]
	
	resize: (w, h) ->
		
		@size_ = if w instanceof Array then w else [w, h]
		
		for i in [0...Room.layerCount]
			
			@layers_[i] = @layers_[i].copy()
			@layers_[i].resize w, h
	
	height: -> @size_[1]
	width: -> @size_[0]
	
	size: -> @size_
	
	layer: (index) -> @layers_[index]
	
	tick: ->
	
		entity.tick() for entity in @entities_
	
	name: -> @name_
	
	addEntity: (entity) ->
		
		@entities_.push entity
		
		entity.setRoom this
		
		entity
	
	removeEntity: (entity) ->
		
		return if -1 is index = @entities_.indexOf entity
		
		@entities_.splice index, 1
	
	entityList: (location, distance) ->
		
		for entity in @entities_
			if entity.location().cartesianDistance(location) < distance
				entity
	
	toJSON: ->
		
		entities = _.map @entities_, (entity) ->
			
			uri: entity.uri
			traits: entity.traitExtensions()
		
		name: @name_
		size: @size_
		layers: @layers_
		collision: @collision_
		entities: entities
