Environment = require 'core/Environment/2D/Environment'

Model = module.exports = DS.Model.extend
	revision: 10
	
	description: DS.attr 'string'
	
	project: DS.belongsTo 'App.ProjectModel'
	tileset: DS.belongsTo 'App.TilesetModel'
	
	name: (->
		
		object = @get 'object'
		object?.name() ? "Fetching #{@get 'id'}..."
		
	).property 'object'
	
	object: null
	
	didLoad: ->
		
		Environment.load(@get 'id').then (environment) =>
			
			@set 'object', environment

Model.FIXTURES = [
	id: '/environment/wb-forest.environment.json'
	description: 'A nice foresty area'
	project: 'my-first-project'
	tileset: '/tileset/wb-forest.tileset.json'
,
	id: '/environment/platforms.environment.json'
	description: 'Some platforms'
	project: 'my-second-project'
	tileset: '/tileset/wb-forest.tileset.json'
]

