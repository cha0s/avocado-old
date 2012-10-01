class avo.Main

	constructor: ->
	
		@buffer = new avo.Image [320, 240]
		
		@currentState = ''
		@state = null
		
		@ticksPerSecond = new avo.Fps()
		@rendersPerSecond = new avo.Fps()
		
		@lastTickTime = 0
		@lastRenderTime = 0
		
		@timeCounter = new avo.Counter()
		
		@tickFrequency = 1000 / avo.ticksPerSecondTarget
		@renderFrequency = 1000 / avo.rendersPerSecondTarget
	
	initialize: ->
		
		defer = upon.defer()
		
		defer.resolve()
		
		defer.promise
		
	tick: ->
	
		avo.setTickTimeElapsed()
		
		@state?.tick()
		
		@lastTickTime = @timeCounter.current()
		@ticksPerSecond.tick()
		
	handleStateChange: ->
	
		if avo.state
			
			if avo.state.quit
				
				alert 'Game over'
			
			@state?.onExit? avo.state.state
			
			@state = null
			
			stateObject = avo.States[avo.state.state]
			
			args = avo.state.args ? {}
			args.from = @currentState
			
			holdState = avo.state.state
			
			stateObject.initialize(args).then =>
				
				@state = stateObject
				@currentState = holdState
			
			delete avo.state
		
	render: ->
		
		@state?.render @buffer
		@window?.render @buffer
		
		@lastRenderTime = @timeCounter.current()
		@rendersPerSecond.tick()

avo.States = {}
