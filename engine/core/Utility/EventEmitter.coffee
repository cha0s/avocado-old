# avo.**EventEmitter** is a mixin which lends the ability to emit events and
# manage the registration of listeners who listen for the emission of the
# events.
class avo.EventEmitter

	# Keeping track of events registered against this object.
	@::events_ = {}
	@::namespaces_ = {}
	
	# Make space for the events and event emitters.
	constructor: ->
		
		@events_ = {}
		@namespaces_ = {}
	
	# Helper function for **on** and **off**. Parse the incoming (possibly)
	# namespaced event name, and return an object.
	parseEventName = (name) ->
	
		# Get the namespace, if any.
		if -1 != index = name.indexOf '.'

			namespace = name.substr(index + 1)
			name = name.substr(0, index)
			
		else
			namespace = ''
		
		namespace: namespace
		event: name

	# Add listeners to an object. *eventName* is a (possibly) namespaced event
	# to listen for. *f* is a function to be called when the event fires, and
	# *that*, if specified, is the 'this' variable in the callback. 'this'
	# defaults to the object upon which the event listener is registered.
	on: (eventName, f, that = this) ->
		info = parseEventName eventName
		
		@events_[info.event] = {} if not @events_[info.event]?
		@namespaces_[info.namespace] = {} if not @namespaces_[info.namespace]?
		
		@events_[info.event][f] =
			f: f.bind that
			namespace: info.namespace
			
		@namespaces_[info.namespace][f] =
			event: info.event
			
		return undefined
		
	# Remove listeners from an object.
	# 
	# There are four ways to use avo.**EventEmitter**.off:
	# 
	# 1. You can call <code>object.off 'eventName', function</code> where
	# *function* is a function previously attached with <code>object.on
	# eventName, function</code>. If the function was never registered
	# against this event, nothing happens.
	# 
	# 2. You can call <code>object.off 'eventName.namespace'</code> where
	# *namespace* is a user-defined namespace. If no listener was registered
	# under the current namespaced event, nothing happens.
	# 
	# 3. You can call <code>object.off '.namespace'</code> where
	# *namespace* is a user-defined namespace. If no listener was registered
	# under the current namespace, nothing happens.
	# 
	# 4. You can call <code>object.off 'eventName'</code>. This is generally
	# undesirable, as Avocado registers event listeners against some built-in
	# objects, and they can be easily be accidentally removed with this
	# method. ***Use caution.***
	off: (eventName, f) ->
		info = parseEventName eventName
		
		# If we're given the function, our job is easy.
		if 'function' == typeof f
			return if not @events_[info.event]?
			
			delete @events_[info.event][f]
			delete @namespaces_[info.namespace][f]
			
			return
		
		# No namespace? Remove every matching event.
		if '' == info.namespace
			for f of @events_[info.event]
				delete @namespaces_[@events_[info.event][f].namespace][f]
				delete @events_[info.event][f]
			return
	
		# Namespaced event? Remove it.
		if info.event
			for f of @events_[info.event]
				if info.namespace != @events_[info.event][f].namespace
					continue
				delete @namespaces_[info.namespace][f]
				delete @events_[info.event][f]
			return
		
		# Only a namespace? Remove all events associated with it.
		for f of @namespaces_[info.namespace]
			delete @events_[@namespaces_[info.namespace][f].event][f]
			delete @namespaces_[info.namespace][f]
		
		return
		
	# Notify ALL the listeners!
	emit: (eventName, args...) ->
		return if not @events_[eventName]?
		
		for callback of @events_[eventName]
			f = @events_[eventName][callback].f
			f.apply f, args

