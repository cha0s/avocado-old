_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
express = require 'express'
http = require 'http'
net = require 'net'
SessionSockets = require 'session.socket.io'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

cookieParser = express.cookieParser 'FOOBAR'
sessionStore = new express.session.MemoryStore()
app.use cookieParser
app.use express.session(
	store: sessionStore
)

require('./lib/avocadoModules') app

app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.end html

app.use express.static '../..'

server = http.createServer app

server.listen 13337

io = require('socket.io').listen server

io.set 'log level', 1

environmentClients = {}

socketSessionMap = {}

environmentClient = (environmentUri) ->
	
	unless environmentClients[environmentUri]?
		
		client = net.connect
			path: "./comm/#{environmentUri.replace /\//g, '_'}.sock"
			
		client.writePacket = (packet) ->
			
			client.write JSON.stringify packet
			client.write '\n'
			
		packetData = ''
		client.readPackets = (data) ->
			packetData += data
			
			packets = packetData.split '\n'
			
			return [] if packets.length is 0
			
			packetData = packets.splice -1, 1
			
			_.map packets, (packet) -> JSON.parse packet
			
		dispatchPacket = (packet) ->
			
			switch packet.type
				
				when 'worldUpdate'
					{clients} = packet
					for {sessionId, data} in clients
						socketSessionMap[sessionId].emit 'worldUpdate', data
			
		client.on 'data', (data) ->
		
			for packet in client.readPackets data
				dispatchPacket packet
			
		environmentClients[environmentUri] = client
			
	environmentClients[environmentUri]

sessionSockets = new SessionSockets io, sessionStore, cookieParser

sessionSockets.on 'connection', (err, socket, session) ->
	
	location = session.location ? {
		
		uri: '/environment/wb-forest.environment.json'
		roomIndex: 0
	}
	
	entity = session.entity ? {
		
		uri: '/entity/wb-dude.entity.json'
		traits: [
			type: 'Existence'
			state:
				x: 150
				y: 150
				direction: 2
		]
	}
	
	session.location = location
	session.entity = entity
	
	session.save()
	
	socketSessionMap[session.id] = socket
	
	client = environmentClient location.uri
	
	client.writePacket
		type: 'clientEntered'
		sessionId: session.id
		data: entity
	
	socket.on 'clientInput', (data) ->
		
		client.writePacket
			type: 'clientInput'
			sessionId: session.id
			data: data
