fs = require 'fs'

exports.gatherFilesRecursive = gatherFilesRecursive = (filepath) ->
		
	files = []
	
	for candidate in fs.readdirSync filepath
		
		subpath = "#{filepath}/#{candidate}"
		
		stats = fs.statSync subpath
		if stats.isDirectory()
			files = files.concat gatherFilesRecursive subpath
		else
			files.push subpath
	
	files
