
mongoose = require 'mongoose'

LayerSchema = mongoose.Schema
	
	tileIndices: [Number]
	size: [Number]

RoomSchema = mongoose.Schema
	
	entities: []
	collision: []
	layers: [LayerSchema]
	name: String
	size: [Number]

EnvironmentSchema = mongoose.Schema

	name: String
	tilesetUri: String
	rooms: [RoomSchema]

module.exports = mongoose.model 'Environment', EnvironmentSchema
