# avo.**Ticker** allows you to keep track of how many discrete ticks have
# passed. Ticks are measured in milliseconds.
class avo.Ticker

	# Initialize a ticker to count a tick every *frequency* milliseconds.
	constructor: (frequency) ->
		
		# Keep the remainder counted towards the next tick.
		@tickRemainder = 0
		@frequency = frequency
		@last_ = avo.TimingService.elapsed()
		
	# Deep copy a ticker.
	deepCopy: ->
		
		ticker = new avo.Ticker()
		
		ticker.tickRemainder = @tickRemainder
		ticker.frequency = @frequency
		ticker.last_ = @last_
	
	# Reset a ticker, so it will be *@frequency* milliseconds until the next
	# tick.
	reset: ->
		
		@last_ = avo.timeElapsed()
		@tickRemainder = 0
	
	# Count the number of ticks passed since the last invocation.
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

		# Keep the remainder of a tick that's passed.
		@tickRemainder = since - ticks * @frequency

		ticks
