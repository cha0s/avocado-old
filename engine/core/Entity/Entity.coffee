# The **Entity** class specifies objects in the game engine. Entities are
# merely compositions of (subclassed) [Trait](Traits/Trait.html) objects.

_ = require 'core/Utility/underscore'
CoreService = require('Core').CoreService
DisplayCommand = require 'core/Graphics/DisplayCommand'
EventEmitter = require 'core/Utility/EventEmitter'
Logger = require 'core/Utility/Logger'
Mixin = require 'core/Utility/Mixin'
Rectangle = require 'core/Extension/Rectangle'
Transition = require 'core/Utility/Transition'
upon = require 'core/Utility/upon'

module.exports = Entity = class
	
	#### Instantiation
	constructor: ->
		
		# Mixins
		# 
		# * **[EventEmitter](../Utility/EventEmitter.html)** for Existence::emit()
		# * **[Transition](../Utility/Transition.html)** for transitioning any property.
		Mixin this, EventEmitter, Transition
		
		# Initialize members.
		@traits = {}

		@tickers = []
		@renderers = []
		
		# All entities require an Existence trait. Calling extendTraits() here 
		# seems risky, but Existence::initializeTrait will always be synchronous
		# (to keep entity instantiation sane).
		@extendTraits [
			type: 'Existence'
		]
		
	# Initialize an Entity from a POD object.
	fromObject: (O) ->
		
		defer = upon.defer()
		
		{@uri, traits} = O

		# Add traits asynchronously.
		@extendTraits(traits).then ->
			
			defer.resolve()
			
		defer.promise
			
	# Load an entity by URI.
	@load: (uri) ->
		
		defer = upon.defer()
		
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			entity = new Entity()
			entity.fromObject(O).then ->
				
				defer.resolve entity
		
		defer.promise
	
	# Deep copy.
	copy: ->
		
		entity = new Entity()
		entity.fromObject @toJSON()
		
		entity
	
	# ***Internal:*** Add an array of [Trait](Traits/Trait.html) PODs to this entity.
	addTraits = (traits) ->
		
		# nop.
		if not traits?
			defer = upon.defer()
			defer.resolve()
			return defer.promise
		
		# Sort all the tickers and renderers by weight.
		@tickers = @tickers.sort (l, r) -> l.weight - r.weight
		@renderers = @renderers.sort (l, r) -> l.weight - r.weight
		
		# Promise the traits:
		for traitInfo in traits
			
			# Instantiate and insert the Trait.
			Trait = require "core/Entity/Traits/#{traitInfo.type}"
			trait = new Trait this, traitInfo.state
			trait.type = traitInfo.type
			@traits[trait.type] = trait
			
			# Bind the actions and values associated with this trait.
			for type in ['actions', 'values']
				for index, meta of trait[type]
					@[index] = _.bind meta.f ? meta, trait
			
			# Refresh the signals associated with this trait.
			for index, signal of trait['signals']
				name = "#{index}.#{trait.type}Trait"
				@off name 
				@on name, signal, trait
			
			# Refresh the handlers associated with this trait.
			if handler = trait['handler']
				
				for handlerType in ['ticker', 'renderer']
					continue unless handler[handlerType]?
					
					# Remove any existing handler.
					@["#{handlerType}s"] = _.filter @["#{handlerType}s"], (e) ->
						e.trait isnt trait.type
				
					# Normalize the handler object.
					unless handler[handlerType].f
						f = handler[handlerType]
						handler[handlerType] = {}
						handler[handlerType].f = f
					
					handler[handlerType].f = _.bind(
						handler[handlerType].f
						trait
					)
					handler[handlerType].weight ?= 0
					handler[handlerType].trait = trait
				
					# Add the handler.
					@["#{handlerType}s"].push handler[handlerType]
			
			trait.initializeTrait()
		
	# Extend this Entity's traits.
	extendTraits: (traits) ->
		
		traits = _.filter traits, (trait) ->
			
			try
				
				require "core/Entity/Traits/#{trait.type}"
				return true
				
			catch e
				
				Logger.warn e.stack
				Logger.warn "Ignoring unknown entity trait: #{trait.type}"
				delete traits[trait.type]
				false
			
		# Wrap all the trait promises in a promise and return it.	
		traitsPromise = for trait in traits
			
			# If the trait already exists,
			if @traits[trait.type]?
				
				{type, state} = trait
				
				# extend the state,
				_.extend @traits[type].state, state
				
				# and fire Trait::initializeTrait().
				[@traits[type].initializeTrait()]
			
			# Otherwise, add the traits as new.
			# TODO aggregate for efficiency.	
			else
				
				addTraits.call this, [trait]
				
		upon.all _.flatten traitsPromise, true
			
	# Remove a Trait from this Entity.
	removeTrait: (type) ->
		
		trait = @traits[type]
		
		# Fire Trait::removeTrait().
		trait.removeTrait this
		
		# Remove the actions and values.
		delete @[index] for index of trait['actions']
		delete @[index] for index of trait['values']
	
		# Remove the handlers.
		@tickers = _.filter @tickers, (e) -> e.trait.type isnt type
		@renderers = _.filter @renderers, (e) -> e.trait.type isnt type
		
		# Remove the trait object.
		delete @traits[type]
	
	# Check whether this Entity has a trait.
	hasTrait: (trait) -> @traits[trait]?
	
	# Invoke a hook with the specified arguments. Returns an array of responses
	# from hook implementations.
	invoke: (hook, args...) ->
		
		for type, trait of @traits
			continue if not trait['hooks'][hook]?
			
			trait['hooks'][hook].apply trait, args

	tick: (commandList) -> ticker.f() for ticker in @tickers
			
	reset: -> trait.resetTrait() for type, trait of @traits
	
	toJSON: ->
		
		uri: @uri
		traits: for type, trait of @traits
			continue if trait.temporal
			trait.toJSON()

module.exports.DisplayCommand = class extends DisplayCommand
	
	constructor: (
		list
		entity
		rectangle = [0, 0, 0, 0]
	) ->
		
		rectangle = Rectangle.translated(
			entity.visibleRect()
			entity.position()
		) if entity.hasTrait 'Visibility'
		
		super list, rectangle
		
		entity.on 'positionChanged.EntityDisplayCommand', =>
			
			@setPosition Rectangle.position Rectangle.translated(
				entity.visibleRect()
				entity.position()
			) if entity.hasTrait 'Visibility'			
			
		entity.on 'renderUpdate.EntityDisplayCommand', => @markAsDirty()
		
		@entity_ = entity
		
	render: (position, clip, destination) ->
		
		for renderer in @entity_.renderers
			
			renderer.f.call @entity_, destination, position, clip
