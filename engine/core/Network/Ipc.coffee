
EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'

module.exports = ->
	
	socket = {}
	
	Mixin socket, EventEmitter
	
	socket
