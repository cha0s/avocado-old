# avo.**DisplayList** is a
# [display list](http://en.wikipedia.org/wiki/Display_list). It is used for
# rendering graphics scene in an optimized way.
#
# The display list manages which parts of the scene have actually changed, and
# only renders the changes.
class avo.DisplayList
	
	constructor: ->
		
		@commands_ = []
		@dirtyCommands_ = []
	
	addCommand: (command) ->
		
		# Add the command as dirty.
		@commands_.push command
		@setDirty command
	
	clear: -> @commands_ = []
	
	setDirty: (command) ->
		
		# Add the command if it hasn't been yet.
		unless  _.contains @dirtyCommands_, command
			@dirtyCommands_.push command
		
	render: (visibleRectangle, destination) ->
		renderRectangle = [0, 0, 0, 0]
		
		# Nothing to render?
		return renderRectangle unless @dirtyCommands_.length > 0
		
		# Separate the visible clean commands so we have less to check.
		cleanCommands = _.difference @commands_, @dirtyCommands_
		cleanCommands = _.filter cleanCommands, (command) ->
			avo.Rectangle.intersects(
				command.rectangle()
				visibleRectangle
			)
		
		for dirtyCommand in @dirtyCommands_
			
			# Make sure the command is visible.
			if _.any(
				[dirtyCommand.rectangle(), dirtyCommand.lastRectangle()]
				(rectangle) -> avo.Rectangle.intersects(
					rectangle
					visibleRectangle
				)
			) 
				
				# Get any clean commands intersecting this dirty command.
				commandsToRender = _.filter(
					cleanCommands
					(command) -> _.any(
						[dirtyCommand.rectangle(), dirtyCommand.lastRectangle()]
						(rectangle) -> avo.Rectangle.intersects(
							command.rectangle()
							rectangle
						)
					)
				)
				
				# Render over (clear) the area of the last rectangle of the
				# dirty command, and then under the dirty command.
				for rectangle in [
					dirtyCommand.lastRectangle()
					dirtyCommand.rectangle()
				]
					
					for command in commandsToRender
					
						# Make sure this command intersects the current
						# rectangle.
						dirtyIntersection = avo.Rectangle.intersection(
							rectangle
							command.rectangle()
						)
						continue if avo.Rectangle.isNull dirtyIntersection
						
						# Make sure this command is actually visible.
						intersection = avo.Rectangle.intersection(
							dirtyIntersection
							visibleRectangle
						)
						continue if avo.Rectangle.isNull intersection
						
						# Add this command's rectangle to the rendering
						# rectangle.
						renderRectangle = avo.Rectangle.united(
							renderRectangle
							intersection
						)
						
						# The actual position where rendering occurs.
						position = avo.Rectangle.position intersection
						
						# The clipping rectangle for rendering this command.
						clip = avo.Rectangle.compose(
							avo.Vector.sub(
								position
								avo.Vector.sub(
									avo.Rectangle.position command.rectangle()
									avo.Rectangle.position visibleRectangle
								)
							)
							avo.Rectangle.size intersection
						)
						
						# Render this command.
						command.render position, clip, destination
						
					# Add the dirty command on the second time around.
					commandsToRender.push dirtyCommand
			
			# Update the current rectangle.
			dirtyCommand.setLastRectangle dirtyCommand.rectangle()
			
		# Clean ALL the commands!
		@dirtyCommands_ = []
		
		# Let caller know which area is actually dirty.
		renderRectangle
		
# avo.**DisplayCommand** is an abstract base class to implement a display
# command.
class avo.DisplayCommand

	constructor: (list, rectangle = [0, 0, 0, 0]) ->
		
		@list_ = list
		@list_.addCommand this
		
		@setRectangle rectangle
		@setLastRectangle [0, 0, 0, 0]
		
	setDirty: ->
		
		@list_.setDirty this
		
	setRectangle: (rectangle) ->
		
		@rectangle_ = avo.Rectangle.floor rectangle
		@setDirty()
		
	rectangle: -> @rectangle_
	
	setPosition: (position) ->
		
		@setRectangle avo.Rectangle.compose(
			position
			avo.Rectangle.size @rectangle_
		)
		
	position: -> avo.Rectangle.position @rectangle_
	
	setLastRectangle: (lastRectangle) -> @lastRectangle_ = avo.Rectangle.floor lastRectangle
	lastRectangle: -> @lastRectangle_
	
	render: (position, clip, destination) ->
