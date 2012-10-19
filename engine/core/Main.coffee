# avo.**Main** implements the main engine loop. This class does everything
# you'd expect in a game loop: user input polling, timing, updating the game
# state (called *tick*ing) and rendering the game state.
#
# Also, States are managed here; instantiated as needed, and entered and left
# as requested.
#
# Subclass this to implement platform-specific functionality.
#
# Emits:
# 
# * <pre>error: When an error was encountered.</pre>
# * <pre>quit:  When the engine is shutting down.</pre>
# 
class avo.Main
	
	# State implementations should add their class to this map.
	@States = {}

	constructor: ->
		
		avo.Mixin this, avo.EventEmitter
		
		# Keep a back buffer to receive all rendering from the current State.
		@backBuffer = new avo.Image [1280, 720]
		
		# Holds the current State's name.
		@stateName = ''
		
		# Contains an object such as:
		# 
		#     {
		#         name: 'Initial',
		#         args: {
		#             ...
		#         }
		#     }
		#
		# or if no state change is being requested, undefined.
		@stateChange = name: 'Initial', args: {}
		
		# Hold the current State object.
		@stateObject = null
		
		# A cache of all instantiated State objects.
		@states = {}
		
		# Keep a count of the tick and render operations performed per second.
		@ticksPerSecond = new avo.Cps()
		@rendersPerSecond = new avo.Cps()
		
		@timeCounter = new avo.Counter()
		
		# Keep count of tick and render frequencies in milliseconds.
		@tickFrequency = 1000 / avo.ticksPerSecondTarget
		@renderFrequency = 1000 / avo.rendersPerSecondTarget
		
		# Keep handles for out tick and render loops, so we can GC them on
		# quit.
		@tickInterval = null
		@renderInterval = null
		
		# [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
		@tickTargetSeconds = 1 / avo.ticksPerSecondTarget
		@lastElapsed = 0
		@elapsedRemainder = 0
	
	begin: ->
		
		# Tick loop.
		@tickInterval = setInterval(
			=>
				try
					@tick()
				catch error
					@emit 'error', error
			@tickFrequency
		)
		
		# Render loop.
		@renderInterval = setInterval(
			=>
				try
					@render()
				catch error
					@emit 'error', error
			@renderFrequency
		)
	
	# Change the State. This isn't immediate, but will be dispatched on the
	# next tick.
	changeState: (name, args = {}) -> @stateChange = name: name, args: args
	
	# Handle the last State change request.
	handleStateChange: ->
		return unless @stateChange?
		
		# Hold handles to some children in @stateChange since we're going to
		# delete it to say we've handled the state change request.
		args = @stateChange.args
		stateName = @stateChange.name

		# We're handling the state change.
		delete @stateChange
		
		# Leave any State we're currently in and NULL the object so
		# State::tick and State::render don't run until the next State is
		# loaded.
		@stateObject?.leave stateName
		@stateObject = null
		
		# If the State is already loaded and cached, resolve the
		# initialization promise immediately.
		if @states[stateName]?
			defer = upon.defer()
			defer.resolve()
			initializationPromise = defer.promise
			
		# Otherwise, instantiate and cache the State, and the initialization
		# promise is State::initialize's promise.
		else
			@states[stateName] = new avo.Main.States[stateName]
			@states[stateName].main = this
			initializationPromise = @states[stateName].initialize()
			
		# When the State is finished initializing,
		p = initializationPromise.then =>
			
			@emit 'stateInitialized', stateName
			
			# and finished being entered,
			@states[stateName].enter(args, @stateName).then =>
				
				# set the new State name, and the object for ticking/rendering.
				@stateObject = @states[stateName]
				@stateName = stateName
		
	tick: ->
		
		delta = avo.TimingService.elapsed() - @lastElapsed
		delta += @elapsedRemainder
		
		# Poll events.
		avo.graphicsService.pollEvents()
		
		while delta > @tickTargetSeconds
			delta -= @tickTargetSeconds
			
			avo.TimingService.setTickElapsed @tickTargetSeconds
			
			if world = avo.world
				world.Step 1 / avo.ticksPerSecondTarget, 8, 3
			
			# Let the State tick.
			@stateObject?.tick()
			
			# Handle any State change.
			@handleStateChange()
			
			# Track the ticks per second.
			@ticksPerSecond.tick()
			
		@elapsedRemainder = delta
		
		@lastElapsed = avo.TimingService.elapsed()
	
	render: ->
		
		# Let the State do rendering.
		rectangles = @stateObject?.render @backBuffer
		if rectangles?.length > 0
			
			@emit 'render', @backBuffer, rectangles
		
		# Track the renders per second.
		@rendersPerSecond.tick()
		
	quit: ->
		
		# GC our tick and render loop handles.
		clearInterval @tickInterval
		clearInterval @renderInterval
		
		# Notify any listeners that it's time to quit.
		@emit 'quit'
