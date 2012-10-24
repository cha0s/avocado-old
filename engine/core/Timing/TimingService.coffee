# SPI proxy and constant definitions.

# **TimingService** provides CPU sleep (if the platform supports it), and
# timeouts/intervals.

Timing = require 'Timing'

# Delay execution by a given number of milliseconds.
Timing.TimingService::sleep = (ms) ->
	return unless ms?
	
	@['%sleep'] ms

# <https://developer.mozilla.org/en-US/docs/DOM/window.setTimeout>
@setTimeout = Timing['%setTimeout']

# <https://developer.mozilla.org/en-US/docs/DOM/window.setInterval>
@setInterval = Timing['%setInterval']

# <https://developer.mozilla.org/en-US/docs/DOM/window.clearTimeout>
@clearTimeout = Timing['%clearTimeout']

# <https://developer.mozilla.org/en-US/docs/DOM/window.clearInterval>
@clearInterval = Timing['%clearInterval']

# Keep track of global time elapsing.
elapsed = 0
tickElapsed = 0

# Total elapsed time.
Timing.TimingService.elapsed = -> elapsed
Timing.TimingService.setElapsed = (e) -> elapsed = e

# Time elapsed per engine tick.
Timing.TimingService.tickElapsed = -> tickElapsed
Timing.TimingService.setTickElapsed = (e) -> tickElapsed = e
