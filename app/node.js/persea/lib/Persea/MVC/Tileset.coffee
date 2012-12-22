TabPanes = require 'Persea/MVC/TabPanes'

Landscape = require 'Persea/MVC/Environment/Landscape'
Entities = require 'Persea/MVC/Environment/Entities'
Collision = require 'Persea/MVC/Environment/Collision'

TilesetModel = require 'Persea/Models/Tileset'

exports.mixinApp = (App) ->
	
	App.TilesetModel = TilesetModel
