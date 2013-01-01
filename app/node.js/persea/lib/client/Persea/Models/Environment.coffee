Environment = require 'core/Environment/2D/Environment'
PerseaModel = require 'Persea/Models/PerseaModel'

EnvironmentModel = module.exports = PerseaModel.extend(
	revision: 11

	name: DS.attr 'string'
	description: DS.attr 'string'
	
	rooms: DS.attr 'passthru'
	tileset: DS.belongsTo 'App.TilesetModel'
	
	objectProperties: ['name', 'description', 'rooms', 'tileset']
	
	loadObject: ->
		
		O =
			name: @get 'name'
			description: @get 'description'
			rooms: JSON.parse JSON.stringify @get 'rooms'
		
		object = new Environment()
		object.fromObject(O).then =>
			
			@set 'object', object
			
).reopenClass
	
	collectionName: 'environments'
