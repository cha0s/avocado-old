
exports.calculateOffset = (element) ->

	obj = element
	
	offset = [
		obj.offsetLeft
		obj.offsetTop
	]
	while obj = obj.offsetParent
		offset[0] += obj.offsetLeft
		offset[1] += obj.offsetTop
		
	offset
