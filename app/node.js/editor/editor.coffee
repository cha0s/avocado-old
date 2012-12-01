# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml', '../../..'
Core.coreService = new Core.CoreService()
Core.CoreService.setEngineRoot '../../../engine'
Core.CoreService.setResourceRoot '../../../resource'

# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml', '../../..'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml', '../../..'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml', '../../..'
Sound.soundService = new Sound.SoundService()

GlobalConfig = require 'core/GlobalConfig'

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = GlobalConfig.SERVER_PACKET_INTERVAL
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

Logger = require 'core/Utility/Logger'

# Register a stderr logging strategy.
Logger.registerStrategy Logger.stderrStrategy

_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
express = require 'express'
helpers = require '../common/helpers'
http = require 'http'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

require('../common/avocadoModules') app

rootPath = '../../..'

editorFiles = helpers.gatherFilesRecursiveSync "#{rootPath}/app/node.js/editor/js", "/app/node.js/editor/js"
editorFiles = editorFiles.filter (e) ->
	
	return false if e.match('../../../app/node.js/editor/js/vendor')?
	return false if e is '../../../app/node.js/editor/js/index.coffee'
	
	not e.match('../../../app/node.js/editor/js/vendor')?
	
editorFiles = editorFiles.map (filename) ->
	src: filename.replace '../../../app/node.js/editor/js/', '/app/node.js/editor/js/'

commonFiles = helpers.gatherFilesRecursiveSync "#{rootPath}/app/node.js/common", "/app/node.js/common"
commonFiles = commonFiles.map (filename) ->
	src: filename.replace '../../../app/node.js/common/', '/app/node.js/common/'

app.locals.editorFiles = commonFiles.concat editorFiles

helpers.serveModuleFiles(
	app
	resourcePath
	rootPath
	'/app/node.js/editor/js/'
) for resourcePath in [
	/^\/app\/node.js\/editor\/js\/Persea.*/
]

helpers.serveModuleFiles(
	app
	resourcePath
	rootPath
	'/app/node.js/common/'
) for resourcePath in [
	/^\/app\/node.js\/common\/.*/
]

# Catch-all. Actually send any processed code we've handled.
app.get /.*/, (req, res, next) ->
	
	if req.processedCode
		res.end req.processedCode
		
	else
		next()
	
app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.end html
		
app.use express.static __dirname + '/../../..'

httpServer = http.createServer app
httpServer.listen 13338

io = require('socket.io').listen httpServer

ioSettings =
	'log level': 1
	'transports': [
		'websocket'
		'flashsocket'
		'htmlfile'
		'xhr-polling'
		'jsonp-polling'
	]

io.set key, value for key, value of ioSettings

io.sockets.on 'connection', (socket) ->
