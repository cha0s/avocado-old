# Rectangle operations.

# avo.**Rectangle** is a utility class to help with rectangle operations. A
# rectangle is implemented as a 2-element array. Element 0 is *x*, element
# 1 is *y*, element 2 is *width* and element 3 is *height*.
avo.Rectangle = 

	# Check if a rectangle intersects with another rectangle.
	#
	#     avocado> avo.Rectangle.intersects [0, 0, 16, 16], [8, 8, 24, 24]
	#     true
	#
	#     avocado> avo.Rectangle.intersects [0, 0, 16, 16], [16, 16, 32, 32]
	#     false
	intersects: (l, r) ->
	
		return false if l[0] >= r[0] + r[2]
		return false if r[0] >= l[0] + l[2]
		return false if l[1] >= r[1] + r[3]
		return false if r[1] >= l[1] + l[3]
		
		true

	# Compose a rectangle from a position vector and a size vector.
	#
	#     avocado> avo.Rectangle.compose [0, 0], [16, 16]
	#     [0, 0, 16, 16]
	compose: (l, r) ->
		
		l.concat r

	# Returns the position of a rectangle.
	#
	#     avocado> avo.Rectangle.position [8, 8, 16, 16]
	#     [8, 8]
	position: (rectangle) ->
		
		[
			rectangle[0]
			rectangle[1]
		]
	
	# Returns the size of a rectangle.
	#
	#     avocado> avo.Rectangle.position [8, 8, 16, 16]
	#     [16, 16]
	size: (rectangle) ->
		
		[
			rectangle[2]
			rectangle[3]
		]
	
	# Compute the intersection rectangle of two rectangles.
	#
	#     avocado> avo.Rectangle.intersection [0, 0, 16, 16], [8, 8, 24, 24]
	#     [8, 8, 8, 8]
	intersection: (l,r) ->
		
		return [0, 0, 0, 0] unless avo.Rectangle.intersects l, r
		
		x = Math.max l[0], r[0]
		y = Math.max l[1], r[1]
		
		lx2 = l[0] + l[2]
		rx2 = r[0] + r[2]
		ly2 = l[1] + l[3]
		ry2 = r[1] + r[3]
		
		w = if lx2 <= rx2 then lx2 - x else rx2 - x
		h = if ly2 <= ry2 then ly2 - y else ry2 - y
		
		[x, y, w, h]

	# Returns a rectangle translated along the [*x*, *y*] axis of a vector.
	#
	#     avocado> avo.Rectangle.translated [0, 0, 16, 16], [8, 8]
	#     [8, 8, 16, 16]
	translated: (rectangle, vector) ->
		
		avo.Rectangle.compose(
			avo.Vector.add avo.Rectangle.position, vector
			avo.Rectangle.size rectangle
		)
		
	# Checks if a rectangle is null. A null rectangle is defined by having any
	# 0-length axis.
	#
	#     avocado> avo.Rectangle.isNull [0, 0, 1, 1]
	#     false
	#
	#     avocado> avo.Rectangle.isNull [0, 0, 1, 0]
	#     true
	isNull: (rectangle) ->
		
		avo.Vector.isZero avo.Rectangle.size rectangle

	# Returns a rectangle that is the united area of two rectangles.
	#
	#     avocado> avo.Rectangle.united [0, 0, 4, 4], [4, 4, 8, 8]
	#     [0, 0, 12, 12]
	united: (l, r) ->
		
		return r if avo.Rectangle.isNull l
		return l if avo.Rectangle.isNull r
		
		x = Math.min l[0], r[0]
		y = Math.min l[1], r[1]
		x2 = Math.max l[0] + l[2], r[0] + r[2]
		y2 = Math.max l[1] + l[3], r[1] + r[3]
		
		united = [
			x
			y
			x2 - x
			y2 - y
		]
		
	# Round the position and size of a rectangle.
	#
	#     avocado> avo.Rectangle.round [3.14, 4.70, 5.32, 1.8]
	#     [3, 5, 5, 2]
	round: (rectangle) ->
		
		avo.Rectangle.compose(
			avo.Vector.round avo.Rectangle.position rectangle
			avo.Vector.round avo.Rectangle.size rectangle
		)
		
	# Floor the position and size of a rectangle.
	#
	#     avocado> avo.Rectangle.round [3.14, 4.70, 5.32, 1.8]
	#     [3, 4, 5, 1]
	floor: (rectangle) ->
		
		avo.Rectangle.compose(
			avo.Vector.floor avo.Rectangle.position rectangle
			avo.Vector.floor avo.Rectangle.size rectangle
		)
		