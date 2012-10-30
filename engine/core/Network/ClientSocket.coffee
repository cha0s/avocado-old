
_ = require 'core/Utility/underscore'
EventEmitter = require 'core/Utility/EventEmitter'
Main = require 'core/Main'
Mixin = require 'core/Utility/Mixin'
NetworkConfig = require 'core/Config/Network'
upon = require 'core/Utility/upon'

defer = upon.defer()

module.exports = if '{{{hostname}}}' is NetworkConfig.host
	
	socket = {}
	Mixin socket, EventEmitter
	socket.id = 'MAIN'
	
	defer.resolve socket
	
	defer.promise
	
else
	
	socket = if io?
		io.connect NetworkConfig.host
	else
		require('socket.io-client').connect NetworkConfig.host
		
	socket.on 'connect', -> defer.resolve socket
	
	defer.promise
