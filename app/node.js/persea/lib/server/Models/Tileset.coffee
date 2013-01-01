
mongoose = require 'mongoose'

tilesetSchema = new mongoose.Schema
	
	name: String
	description: String
	
	tileSize: [Number]
	tileData: Buffer
	
module.exports = TilesetModel = mongoose.model 'Tileset', tilesetSchema

TilesetModel.castHash = (O) ->
	
	O.tileData = new Buffer O.tileData, 'base64'
