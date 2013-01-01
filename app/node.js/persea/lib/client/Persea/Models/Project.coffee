Model = module.exports = DS.Model.extend(
	revision: 11
	
	name: DS.attr 'string'
	description: DS.attr 'string'
	
	environments: DS.hasMany 'App.EnvironmentModel'
	tilesets: DS.hasMany 'App.TilesetModel'
	
).reopenClass
	
	collectionName: 'projects'
