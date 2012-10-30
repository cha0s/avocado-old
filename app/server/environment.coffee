coffee = require 'coffee-script'

# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml', '../..'
Core.coreService = new Core.CoreService()
Core.CoreService.setEngineRoot '../../engine'
Core.CoreService.setResourceRoot '../../resource'

# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml', '../..'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml', '../..'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml', '../..'
Sound.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

Entity = require 'core/Entity/Entity'
Logger = require 'core/Utility/Logger'

# Register a stderr logging strategy.
Logger.registerStrategy (message, type) ->
	
	# Colors for the console.
	colors =
	
		error : '\x1B[1;31m'
		warn  : '\x1B[1;33m'
		info  : '\x1B[1;32m'
		reset : '\x1B[0m'
		
	# TYPE:
	Core.CoreService.writeStderr "#{
		colors[type]
	}#{
		type.toUpperCase()
	}#{
		colors.reset
	}:"
	
	# message
	Core.CoreService.writeStderr message

_ = require 'core/Utility/underscore'
fs = require 'fs'
net = require 'net'

PACKET_INTERVAL = 33
UPDATE_INTERVAL = 66

entities = {}

dispatchPacket = ({
	type
	sessionId
	data
}) ->
	
	switch type
		
		when 'clientEntered'
			{uri, traits} = data
			Entity.load(uri).then (entity) ->
				entity.extendTraits(traits).then ->
					entity.reset()
					entities[sessionId] = entity
			
		when 'clientInput'
			{unitMovement} = data
			entities[sessionId].move(
				unitMovement
				1 / PACKET_INTERVAL
				true
			)

server = net.createServer (connection) ->
	
	connection.writePacket = (packet) ->
		
		connection.write JSON.stringify packet
		connection.write '\n'
		
	packetData = ''
	connection.readPackets = (data) ->
		packetData += data
		
		packets = packetData.split '\n'
		
		return [] if packets.length is 0
		
		packetData = packets.splice -1, 1
		
		_.map packets, (packet) -> JSON.parse packet
			
	connection.on 'data', (data) ->
		
		for packet in connection.readPackets data
			dispatchPacket packet
	
	setInterval(
		
		-> 
			connection.writePacket
				type: 'worldUpdate'
				clients: for sessionId, entity of entities
					sessionId: sessionId
					data:
						position: entity.position()
		
		1000 / UPDATE_INTERVAL
	)

fs.unlinkSync './comm/_environment_wb-forest.environment.json.sock'
server.listen './comm/_environment_wb-forest.environment.json.sock'




