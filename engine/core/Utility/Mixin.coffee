# Dynamic object composition helper. Use in an object's constructor
# function.
@Mixin = (ToExtend, Extenders...) ->
	
	# Each one of the extenders gets instantiated,
	for Extender in Extenders
		extender = new Extender()
		
		# Then mixed in to the object we're extending.
		for own key, value of Extender.prototype
			ToExtend[key] = extender[key]
