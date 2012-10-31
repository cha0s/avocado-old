# **Main** implements the main engine loop. This class does everything
# you'd expect in a game loop: user input polling, timing, updating the game
# state (called *tick*ing) and rendering the game state.
#
# Also, States are managed here; instantiated as needed, and entered and left
# as requested.
#
# Subclass this to implement platform-specific functionality.
#
# Emits:
# 
# * <pre>error: When an error was encountered.</pre>
# * <pre>quit:  When the engine is shutting down.</pre>
#

_ = require 'core/Utility/underscore'
Cps = require 'core/Timing/Cps' 
Graphics = require 'Graphics'
Main = require 'core/Main'
Timing = require 'Timing'

module.exports = Server = class extends Main

	constructor: (@connection) ->
		
		super
		
		@stateChange = name: 'Server/Accept', args: {}		

	listen: (fn) ->
		
		switch @connection.type
			
			when 'socketIo'

				# Hardcoded path.				
				io = require('../../../app/server/node_modules/socket.io').listen @connection.server
				
				io.sockets.on 'connection', (socket) ->
					
					fn socket
			
			when 'tcp'
				
				# This is node-specific for the time being.
				require('net').createServer (client) ->
					
					emit = client.emit
					client.emit = (event, args...) ->
						
						return emit.apply(
							client
							[event].concat args
						) if _.contains [
							'listening', 'connection', 'close', 'error'
							'connect', 'data', 'end', 'timeout', 'drain', 'error'
							'close'
						], event
						
						packet =
							type: event
							data: args[0]
						
						client.write JSON.stringify packet
						client.write '\n'
					
					packetData = ''
					client.on 'data', (data) ->
					
						packetData += data
						
						packets = packetData.split '\n'
						
						return if packets.length is 0
						
						packetData = packets.splice -1, 1
						
						for {type, data} in (_.map packets, (packet) -> JSON.parse packet)
							
							client.emit type, data
							
					fn client
			
			when 'ipc'
			
				fn require 'core/Network/Ipc'
