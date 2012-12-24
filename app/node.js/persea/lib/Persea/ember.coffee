
exports.mixinMvc = (app, name) ->
	
	mvc = require "Persea/Routes/#{name}"
	
	app["#{name}Controller"] = mvc.Controller if mvc.Controller?
	app["#{name}View"] = mvc.View if mvc.View?
	
	undefined

exports.mixinRouter = (router, name) ->
	
	mvc = require "Persea/Routes/#{name}"
	
	_.extend router.actions, mvc.Router?.actions ? {}
	_.extend router.routes, mvc.Router?.routes ? {}
	
	undefined

exports.mixinModels = (App, modelNames) ->
	
	for modelName in modelNames
		
		App["#{modelName}Model"] = require "Persea/Models/#{modelName}"
	
	undefined
