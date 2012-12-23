
_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
express = require 'express'
helpers = require '../common/helpers'
http = require 'http'
path = require 'path'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

require('../common/process-sources') app, "../../.."

perseaFiles = helpers.gatherFilesRecursiveSync('./lib').map (filename) ->
	src: filename.replace './lib', '/app/node.js/persea/lib'

helpers.serveModuleFiles(
	app
	resourcePath
	'../../..'
	'/app/node.js/persea/lib/'
) for resourcePath in [
	/^\/app\/node.js\/persea\/lib\/.*/
]

app.locals.perseaFiles = perseaFiles

# Catch-all. Actually send any processed code we've handled.
app.get /.*/, (req, res, next) ->
	
	if req.processedCode
		type = express.mime.lookup req._parsedUrl.pathname
		unless res.getHeader 'content-type'
			charset = express.mime.charsets.lookup type
			res.setHeader(
				'Content-Type'
				type + (if charset then "; charset=#{charset}" else '')
			)
	
		res.end req.processedCode
		
	else
		next()
	
app.get '/', (req, res) ->
	
	res.render 'index', {}, (error, html) ->
		
		res.end html

app.use express.static '../../..'

httpServer = http.createServer app
httpServer.listen 13338