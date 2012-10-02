# Vector operations.

# avo.**Vector** is a utility class to help with vector operations. A vector
# is implemented in Avocado as a 2-element array. Element 0 is x and element
# 1 is y.
avo.Vector = 

	# Scale a vector.
	#
	# <code>\> avo.Vector.scale [.5, 1.5], 2</code> -> <code>[1, 3]</code>
	scale: (array, k) -> [array[0] * k, array[1] * k]
	
	# Add two vectors. 
	#
	# <code>\> avo.Vector.add [1, 2], [1, 1]</code> -> <code>[2, 3]</code>
	add: (l, r) -> [l[0] + r[0], l[1] + r[1]]
	
	# Subtract two vectors. 
	#
	# <code>\> avo.Vector.sub [9, 5], [5, 2]</code> -> <code>[4, 3]</code>
	sub: (l, r) -> [l[0] - r[0], l[1] - r[1]]
