Model = module.exports = DS.Model.extend
	revision: 10
	
	name: DS.attr 'string'
	description: DS.attr 'string'
	
	environments: DS.hasMany 'App.EnvironmentModel'
	tilesets: DS.hasMany 'App.TilesetModel'

Model.FIXTURES = [
	id: 'my-first-project'
	name: 'My First Project'
	description: 'Yay =]'
	environments: [
		'/environment/wb-forest.environment.json'
	]
	tilesets: [
		'/tileset/wb-forest.tileset.json'
	]
,
	id: 'my-second-project'
	name: 'My Second Project'
	description: 'Woohoo =]'
	environments: [
		'/environment/platforms.environment.json'
	]
	tilesets: [
		'/tileset/wb-forest.tileset.json'
	]
]

