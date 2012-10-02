# avo.Cps is used to measure the cycles per second of a process. Avocado uses
# this class to measure the cycles per second and renders per second of the
# engine itself. If you instantiate avo.Cps and call avo.Cps::tick() every
# time a process runs, you can call avo.Cps::count() to found how many times
# the cycle runs per second.
# 
# *NOTE:* When you instantiate avo.Cps, a **frequency** is specified. You must call
# avo.Cps.tick() for at least **frequency** milliseconds to get an accurate
# reading. Until then, you will read 0.
class avo.Cps
	
	# Instantiate the CPS counter. By default, it counts the cycles every 250
	# milliseconds.
	constructor: (frequency = 250) ->
		
		@ticker = new avo.Ticker frequency
		@fps = 0
		@c = 0

	# Call avo.Cps::tick() every time the process you want to measure runs.
	tick: ->
	
		if @ticker.ticks() > 0
	
			@fps = @c * (1000 / @ticker.frequency) 
			@c = 0
	
		@c++
	
	# Call avo.Cps::count() to see retrieve how many cycles the process runs
	# per second.
	count: -> @fps
