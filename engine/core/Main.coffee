class avo.Main

	constructor: ->
		
		Mixin this, EventEmitter
	
		@buffer = new avo.Image [320, 240]
		
		@currentStateName = ''
		@stateObject = null
		@states = {}
		
		@ticksPerSecond = new avo.Cps()
		@rendersPerSecond = new avo.Cps()
		
		@tickFrequency = 1000 / avo.ticksPerSecondTarget
		@renderFrequency = 1000 / avo.rendersPerSecondTarget
		
		@tickInterval = null
		@renderInterval = null
	
	begin: ->
	
		avo.state = state: 'Initial' 
		
		avo.Input.on 'quit.Engine', =>
		
			@quit()
		
		setInterval(
			=>
				
				try
				
					avo.Input.poll()
				
					@tick()
					
					@handleStateChange()
				
				catch error
					
					@emit 'error', error
					
			@tickFrequency
		)
		
		setInterval(
		
			=>
			
				try
				
					@render()
				
				catch error
					
					@emit 'error', error
					
			@renderFrequency
		)
			
	handleStateChange: ->
		return unless avo.state?
			
		@stateObject?.onExit avo.state.state
		@stateObject = null
		
		args = avo.state.args ? {}
		args.from = @currentStateName
		
		if @states[avo.state.state]?
			
			defer = upon.defer()
			defer.resolve()
			initializationPromise = defer.promise
			
		else
			
			@states[avo.state.state] = new avo.States[avo.state.state]
			initializationPromise = @states[avo.state.state].initialize()
			
		stateObject = @states[avo.state.state]
		stateName = avo.state.state
		
		initializationPromise.then =>
		
			stateObject.enter(args).then =>
				
				@stateObject = stateObject
				@currentStateName = stateName
		
		delete avo.state
		
	tick: ->
	
		avo.TimingService.tick()
		@stateObject?.tick()
		
		@ticksPerSecond.tick()
		
	render: ->
		
		@stateObject?.render @buffer
		@window?.render @buffer
		
		@rendersPerSecond.tick()

	quit: ->
		
		clearInterval @tickInterval
		clearInterval @renderInterval
		
		@emit 'quit'
		
avo.States = {}
