# SPI proxy and constant definitions.

# avo.**Counter** keeps track of time.

# Get the current timestamp. This will be different based on platform, but
# calling one second later will always return timestamp + 1.
avo.Counter::current = avo.Counter::['%current']

# Request the time delta in milliseconds since last invocation.
avo.Counter::since = avo.Counter::['%since']
