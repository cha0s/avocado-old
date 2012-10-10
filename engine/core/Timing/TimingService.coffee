# SPI proxy and constant definitions.

# avo.**TimingService** provides CPU sleep (if the platform supports it), and
# timeouts/intervals.

# Delay execution by a given number of milliseconds.
avo.TimingService::sleep = (ms) ->
	return unless ms?
	
	@['%sleep'] ms

# <https://developer.mozilla.org/en-US/docs/DOM/window.setTimeout>
@setTimeout = avo['%setTimeout']

# <https://developer.mozilla.org/en-US/docs/DOM/window.setInterval>
@setInterval = avo['%setInterval']

# <https://developer.mozilla.org/en-US/docs/DOM/window.clearTimeout>
@clearTimeout = avo['%clearTimeout']

# <https://developer.mozilla.org/en-US/docs/DOM/window.clearInterval>
@clearInterval = avo['%clearInterval']

# Keep track of global time elapsing.
elapsed = 0
#lastElapsed = 0
tickElapsed = 0

# Total elapsed time.
avo.TimingService.elapsed = -> elapsed
avo.TimingService.setElapsed = (e) -> elapsed = e

# Time elapsed per engine tick.
avo.TimingService.tickElapsed = -> tickElapsed
avo.TimingService.setTickElapsed = (e) -> tickElapsed = e
