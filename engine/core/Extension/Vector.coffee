# Vector operations.

# avo.**Vector** is a utility class to help with vector operations. A vector
# is implemented as a 2-element array. Element 0 is *x* and element 1 is *y*.
avo.Vector = 

	# Scale a vector. This multiplies *x* and *y* by **k**. e.g.
	#
	#     avocado> avo.Vector.scale [.5, 1.5], 2
	#     [1, 3]
	scale: (array, k) -> [array[0] * k, array[1] * k]
	
	# Add two vectors. e.g.
	#
	#     avocado> avo.Vector.add [1, 2], [1, 1]
	#     [2, 3]
	add: (l, r) -> [l[0] + r[0], l[1] + r[1]]
	
	# Subtract two vectors. e.g. 
	#
	#     avocado> avo.Vector.sub [9, 5], [5, 2]
	#     [4, 3]
	sub: (l, r) -> [l[0] - r[0], l[1] - r[1]]
	
	# Checks whether a vector is [0, 0].
	#
	#     avocado> avo.Vector.zero [0, 0]
	#     true
	#
	#     avocado> avo.Vector.zero [0, 1]
	#     false
	isZero: (vector) ->
		
		vector[0] is 0 and vector[1] is 0
	
	# Round both axes of a vector.
	#
	#     avocado> avo.Vector.round [3.14, 4.70]
	#     [3, 5]
	round: (vector) ->
		
		[
			Math.round vector[0]
			Math.round vector[1]
		]
	
	# Floor both axes of a vector.
	#
	#     avocado> avo.Vector.floor [3.14, 4.70]
	#     [3, 4]
	floor: (vector) ->
		
		[
			Math.floor vector[0]
			Math.floor vector[1]
		]
		