Environment = require 'core/Environment/2D/Environment'

Model = module.exports = DS.Model.extend
	revision: 10
	
	project: DS.belongsTo 'App.ProjectModel'
	tileset: DS.belongsTo 'App.TilesetModel'
	
	name: (->
		
		object = @get 'object'
		object?.name() ? @get 'id'
		
	).property 'object'
	
	description: (->
		
		'A description will go here once it is built into the data model.'
		
	).property 'object'
	
	fetching: (->
		
		object = @get 'object'
		
		return if object? then '' else 'Fetching from server...'
		
	).property 'object'
	
	object: null
	
	didLoad: ->
		
		Environment.load(@get 'id').then (environment) =>
			
			@set 'object', environment

Model.FIXTURES = [
	id: '/environment/wb-forest.environment.json'
	project: 'my-first-project'
	tileset: '/tileset/wb-forest.tileset.json'
,
	id: '/environment/platforms.environment.json'
	project: 'my-second-project'
	tileset: '/tileset/wb-forest.tileset.json'
]

