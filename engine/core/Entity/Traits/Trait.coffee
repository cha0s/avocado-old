_ = require 'core/Utility/underscore'
upon = require 'core/Utility/upon'

module.exports = class

	constructor: (@entity, state = {}) ->
		
		@state = _.defaults state, @defaults()
	
	defaults: -> {}
	
	preToJSON: ->
	
	toJSON: ->
		
		@preToJSON()
		
		sgfy = JSON.stringify
		
		state = {}
		defaults = @defaults()
		
		for k, v of _.defaults @state, JSON.parse sgfy defaults
			state[k] = v if sgfy(v) isnt sgfy(defaults[k])
			
		O = {}
		O.type = @type
		O.state = state unless _.isEmpty state
		O
	
	hooks: -> {}
	
	signals: -> {}
	
	actions: -> {}
	
	values: -> {}
	
	initializeTrait: ->
		
		@resetTrait()
		
		defer = upon.defer()
		defer.resolve()
		defer.promise
	
	resetTrait: ->
	
	removeTrait: ->
	
	temporal: false
