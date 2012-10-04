# String operations.

# avo.**String** is a utility class to help with string operations.
avo.String = 
	
	# From a name, get a setter name. e.g.
	# 
	#     avocado> setterName 'width'
	#     'setWidth'
	setterName: (name) ->
	
		"set#{avo.String.capitalizeString name}"
	
	# Capitalize the first character in the string. e.g.
	# 
	#     avocado> capitalizeString 'ruben'
	#     'Ruben'
	capitalizeString: (string) ->
		
		string.substr(0, 1).toUpperCase() + string.substr 1