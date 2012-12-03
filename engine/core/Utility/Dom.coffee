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

exports.numberFromPxString = numberFromPxString = (pxString) ->
	return 0 if '' is pxString
	
	parseFloat pxString.substr 0, pxString.length - 2
	
exports.outerWidth = (element, includeMargin = false) ->
	
	{
		width
		borderLeft, borderRight
		paddingLeft, paddingRight
		marginLeft, marginRight
	} = window.getComputedStyle element
	
	outerWidth = numberFromPxString width
	outerWidth += numberFromPxString paddingLeft
	outerWidth += numberFromPxString paddingRight
	outerWidth += numberFromPxString borderLeft
	outerWidth += numberFromPxString borderRight
	
	if includeMargin
		outerWidth += numberFromPxString marginLeft
		outerWidth += numberFromPxString marginRight
	
	outerWidth
