Tileset = require 'core/Environment/2D/Tileset'
upon = require 'core/Utility/upon'

Model = module.exports = DS.Model.extend
	revision: 10
	
	projects: DS.hasMany 'App.ProjectModel'
	environments: DS.hasMany 'App.EnvironmentModel'
	
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
		
		uri = @get 'id'
		
		Tileset.load(uri).then (tileset) =>
			
			@set 'object', tileset
			
Model.FIXTURES = [
	id: '/tileset/wb-forest.tileset.json'
	projects: [
		'my-first-project'
		'my-second-project'
	]
	environments: [
		'/environment/wb-forest.environment.json'
		'/environment/platforms.environment.json'
	]
]

