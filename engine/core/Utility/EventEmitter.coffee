class @EventEmitter

	# Keeping track of events registered against this object.
	@::events_ = {}
	@::namespaces_ = {}
	
	constructor: ->
		
		@events_ = {}
		@namespaces_ = {}
		
	parseEventName = (name) ->
	
		# Get the namespace, if any.
		if -1 != index = name.indexOf '.'

			namespace = name.substr(index + 1)
			name = name.substr(0, index)
			
		else
			namespace = ''
		
		namespace: namespace,
		event: name

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
	
		return undefined
		
	emit: (eventName, args...) ->
	
		return if not @events_[eventName]?
		
		for callback of @events_[eventName]
			f = @events_[eventName][callback].f
			
			f.apply f, args

