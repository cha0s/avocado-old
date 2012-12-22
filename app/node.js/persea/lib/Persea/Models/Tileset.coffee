Tileset = require 'core/Environment/2D/Tileset'

Model = module.exports = DS.Model.extend
	revision: 10
	
	projects: DS.hasMany 'App.ProjectModel'
	environments: DS.hasMany 'App.EnvironmentModel'
	
	object: null
	
	didLoad: ->
		
		Tileset.load(@get 'id').then (tileset) =>
			
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

