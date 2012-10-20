class avo.Room
	
	@layerCount: 5
		
	constructor: ->
	
		@layers_ = []
		@size_ = [0, 0]
		@name_ = ''
		@entities_ = []
		@collision_ = []
		
		@layers_[i] = new avo.TileLayer() for i in [0...avo.Room.layerCount]

	fromObject: (O) ->
	
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		layerPromises = for layer, i in O.layers
			
			@layers_[i] = new avo.TileLayer()
			@layers_[i].fromObject layer
		
		@resize avo.Vector.copy O.size
		
		entityPromises = []
		
		@entities_ = []
		
		if O.entities?
			
			promiseEntity = (entityInfo, i) =>
				
				entityDefer = upon.defer()
				
				avo.Entity.load(entityInfo.uri).then (entity) =>
				
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
		
		room = new avo.Room()
		room.fromObject @toJSON()
		
		room
	
	reset: ->
		
		entity.reset() for entity in @entities_
		
		@startParallax()
		
	startParallax: ->
		
		@layers_[i].startParallax() for i in [0...avo.Room.layerCount]
		
	stopParallax: ->
		
		@layers_[i].stopParallax() for i in [0...avo.Room.layerCount]
	
	resize: (w, h) ->
		
		@size_ = if w instanceof Array then w else [w, h]
		
		for i in [0...avo.Room.layerCount]
			
			@layers_[i] = @layers_[i].copy()
			@layers_[i].resize w, h
	
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
		
		name: @name_
		size: @size_
		layers: @layers_
		collision: @collision_
		entities: @entities_.map (entity) ->
			
			uri: entity.uri
			traits: entity.traitExtensions()