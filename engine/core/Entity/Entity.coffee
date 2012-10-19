# The **Entity** class specifies objects in the game engine. Entities are
# merely compositions of (subclassed) [Trait](Traits/Trait.html) objects.
class avo.Entity
	
	#### Instantiation
	constructor: ->
		
		# Mixins
		# 
		# * **[EventEmitter](../Utility/EventEmitter.html)** for Existence::emit()
		# * **[Transition](../Utility/Transition.html)** for transitioning any property.
		avo.Mixin this, avo.EventEmitter, avo.Transition
		
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
		
		avo.CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			entity = new avo.Entity()
			entity.fromObject(O).then ->
				
				defer.resolve entity
		
		defer.promise
	
	# Deep copy.
	copy: ->
		
		entity = new avo.Entity()
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
			trait = new avo.EntityTraits[traitInfo.type] this, traitInfo.state
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
			
			return true if avo.EntityTraits[trait.type]?
			
			avo.Logger.warn "Ignoring unknown entity trait: #{trait.type}"
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

class avo.EntityDisplayCommand extends avo.DisplayCommand
	
	constructor: (
		list
		entity
		rectangle = [0, 0, 0, 0]
	) ->
		
		rectangle = avo.Rectangle.translated(
			entity.visibleRect()
			entity.position()
		) if entity.hasTrait 'Visibility'
		
		super list, rectangle
		
		entity.on 'positionChanged.EntityDisplayCommand', =>
			
			@setPosition avo.Rectangle.position avo.Rectangle.translated(
				entity.visibleRect()
				entity.position()
			) if entity.hasTrait 'Visibility'			
			
		entity.on 'renderUpdate.EntityDisplayCommand', => @markAsDirty()
		
		@entity_ = entity
		
	render: (position, clip, destination) ->
		
		for renderer in @entity_.renderers
			
			renderer.f.call @entity_, destination, position, clip

#### Implementing your own traits
#
# To implement your own trait, add an entry to the avo.**EntityTraits** object.
# Entries must extend [Trait](Traits/Trait.html).
#
# ***TODO: This isn't actually enforced at the moment.***
avo.EntityTraits ?= {}
