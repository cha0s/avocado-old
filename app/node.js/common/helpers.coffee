fs = require 'fs'

# Gather all files under a path, recursively.
exports.gatherFilesRecursiveSync = gatherFilesRecursiveSync = (filepath) ->
		
	files = []
	for candidate in fs.readdirSync filepath
		subpath = "#{filepath}/#{candidate}"
		
		# Recur?
		stats = fs.statSync subpath
		if stats.isDirectory()
			files = files.concat gatherFilesRecursiveSync subpath
			
		# Add to the list.
		else
			files.push subpath
	
	files
