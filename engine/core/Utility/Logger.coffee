# avo.Logger handles logging information. It can be customized to log through
# logging strategies.
class avo.Logger

	# Logging strategies define how messages of different types are logged.
	# A logging strategy is a function taking two arguments: message and type.
	# When registering a logging strategy, types may be specified; these
	# determine which strategies are used when logging a message of a
	# particular type. By default a registered strategy will implement logging
	# for all types.
	strategies = {}
	@registerStrategy: (strategy, types = ['info', 'error', 'warn']) ->
		(strategies[type] ?= []).push strategy for type in types

	# Log the message type using the registered strategies.	
	log = (message, type) ->
		strategy message, type for strategy in strategies[type] ? []
	
	# All message types receive a facade.
	delegateType = (type) -> (message) -> log message, type
	for type in ['info', 'error', 'warn']
		@[type] = delegateType type
