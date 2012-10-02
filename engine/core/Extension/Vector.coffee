avo.Vector = 

	scale: (array, k) -> [array[0] * k, array[1] * k]
	add: (l, r) -> [l[0] + r[0], l[1] + r[1]]
	sub: (l, r) -> [l[0] - r[0], l[1] - r[1]]
