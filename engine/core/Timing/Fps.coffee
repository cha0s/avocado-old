class avo.Fps
	
	constructor: (frequency = 250) ->
		
		@ticker = new avo.Ticker frequency
		@fps = 0
		@c = 0

	tick: ->
	
		if @ticker.ticks() > 0
	
			@fps = @c * (1000 / @ticker.frequency) 
			@c = 0
	
		@c++
	
	count: -> @fps
