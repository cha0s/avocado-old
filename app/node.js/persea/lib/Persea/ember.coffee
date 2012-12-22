
exports.mixinMvc = (app, name) ->
	
	mvc = require "Persea/MVC/#{name}"
	
	app["#{name}Controller"] = mvc.Controller if mvc.Controller?
	app["#{name}View"] = mvc.View if mvc.View?
	
	undefined

exports.mixinRouter = (router, name) ->
	
	mvc = require "Persea/MVC/#{name}"
	
	_.extend router.actions, mvc.Router?.actions ? {}
	_.extend router.routes, mvc.Router?.routes ? {}
	
	undefined

exports.mixinApp = (App, name) ->
	
	mvc = require "Persea/MVC/#{name}"
	
	mvc.mixinApp? App
	
	undefined
