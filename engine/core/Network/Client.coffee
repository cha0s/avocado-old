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

Cps = require 'core/Timing/Cps' 
Graphics = require 'Graphics'
jsuri = require 'core/Utility/jsuri'
Main = require 'core/Main'
Timing = require 'Timing'
upon = require 'core/Utility/upon'

module.exports = Client = class extends Main
	
	# State implementations should add their class to this map.
	@States = {}

	constructor: (@url) ->
		
		super
		
		# Keep a back buffer to receive all rendering from the current State.
		@backBuffer = new Graphics.Image [1280, 720]
		
		# Keep a count of the render operations performed per second.
		@rendersPerSecond = new Cps()
		
		# Keep count of render frequency in milliseconds.
		@renderFrequency = 1000 / Timing.rendersPerSecondTarget
		
		# Keep render loop, so we can GC them on
		# quit.
		@renderInterval = null
		
		@stateChange = name: 'Client/Initial', args: {}
		
	connect: ->
		
		defer = upon.defer()
		
		uri = jsuri.Uri @url
		
		socketIo = (url) ->
			
			socket = if io?
				io.connect url
			else
				require('socket.io-client').connect url
				
			socket.on 'connect', ->
				
				defer.resolve socket
		
		switch uri.protocol()
			
			when 'http', 'ws'
				
				uri.protocol 'http'
				socketIo uri.toString()
				
			when 'https', 'wss'
				
				uri.protocol 'https'
				socketIo uri.toString()
				
			when 'tcp'
				
				foo = 'bar'
				
			when 'ipc'
				
				defer.resolve require 'core/Network/Ipc'
		
		defer.promise
		
	begin: ->
		
		super
		
		# Render loop.
		@renderInterval = setInterval(
			=>
				try
					@render()
				catch error
					@emit 'error', error
			@renderFrequency
		)
	
	render: ->
		
		# Let the State do rendering.
		rectangles = @stateObject?.render @backBuffer
		if rectangles?.length > 0
			
			@emit 'render', @backBuffer, rectangles
		
		# Track the renders per second.
		@rendersPerSecond.tick()
		
	quit: ->
		
		# GC our render loop handle.
		clearInterval @renderInterval
		
		super
