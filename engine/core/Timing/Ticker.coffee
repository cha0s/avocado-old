class avo.Ticker

	constructor: (frequency) ->
		
		@tickRemainder = 0
		@frequency = frequency
		@last_ = avo.TimingService.elapsed()
		
	copy: ->
		
		ticker = new avo.Ticker()
		
		ticker.tickRemainder = @tickRemainder
		ticker.frequency = @frequency
		ticker.last_ = @last_
	
	reset: ->
		
		@last_ = avo.timeElapsed()
		@tickRemainder = 0
	
	ticks: ->
		
		# Get current ticks.
		now = (avo.TimingService.elapsed() - @last_) * 1000
		@last_ = avo.TimingService.elapsed()

		# The number of milliseconds since last invocation.
		since = 0

		# The number of ticks since last invocation.
		ticks = 0

		# At least one tick?
		if (since = (now + @tickRemainder)) >= @frequency
			
			# If there's been at least one tick, return the number of ticks
			# that occured, and update the current marker to calculate the
			# delta next time.
			ticks = Math.floor since / @frequency

		@tickRemainder = since - ticks * @frequency

		ticks
