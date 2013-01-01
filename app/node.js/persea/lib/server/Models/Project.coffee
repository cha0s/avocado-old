
mongoose = require 'mongoose'

Environment = require './Environment'
Tileset = require './Tileset'

ProjectSchema = mongoose.Schema
	
	uri: String
	name: String
	description: String
	
	environments: [Environment.Schema]
	tilesets: [Tileset.Schema]
	
module.exports = mongoose.model 'Project', ProjectSchema
