# avo.**DisplayList** is a
# [display list](http://en.wikipedia.org/wiki/Display_list). It is used for
# rendering graphics scene in an optimized way.
#
# The display list manages which parts of the scene have actually changed, and
# only renders the changes.
class avo.DisplayList
	
	constructor: ->
		
		@clear()
	
	addCommand: (command) ->
		
		# Add the command as dirty.
		command.commandId_ = @commandId_++
		@commands_.push command
		@setDirty command
	
	clear: ->
		
		@commandId_ = 0
		@commands_ = []
		@dirtyCommands_ = []
	
	setCommandDirty: (command) ->
		
		# Add the command if it hasn't been yet.
		unless  _.contains @dirtyCommands_, command
			@dirtyCommands_.push command
		
	setDirty: -> command.setDirty() for command in @commands_
	
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
			
		# All commands are dirty? Just render everything!
		if cleanCommands.length is 0
			
			for command in _.sortBy @dirtyCommands_, 'commandId_'
				
				# Render this command.
				command.render(
					avo.Vector.sub(
						command.position()
						avo.Rectangle.position visibleRectangle
					)
					avo.Rectangle.compose [0, 0], command.size()
					destination
				)
				
				command.setLastRectangle command.rectangle()
				
			renderRectangle = visibleRectangle
				
		else
		
			renderCommands = (commands, rectangle) ->
				for command in _.sortBy commands, 'commandId_'
				
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
					position = avo.Vector.sub(
						position
						avo.Rectangle.position visibleRectangle
					)
					
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
			
			# Render all clean commands that intersect all 'last' dirty
			# rectangles.
			for dirtyCommand in @dirtyCommands_
				
				rectangle = dirtyCommand.lastRectangle()
				
				continue unless avo.Rectangle.intersects(
					rectangle
					visibleRectangle
				)
			
				renderCommands _.filter(
					cleanCommands
					(command) -> avo.Rectangle.intersects(
						command.rectangle()
						rectangle
					)
				), rectangle
				
			# Render all clean and dirty commands that intersect all dirty
			# rectangles.
			for dirtyCommand in @dirtyCommands_
			
				rectangle = dirtyCommand.rectangle()
				dirtyCommand.setLastRectangle dirtyCommand.rectangle()
				
				continue unless avo.Rectangle.intersects(
					rectangle
					visibleRectangle
				)
			
				renderCommands _.filter(
					cleanCommands.concat @dirtyCommands_
					(command) -> avo.Rectangle.intersects(
						command.rectangle()
						rectangle
					)
				), rectangle
		
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
		
		@list_.setCommandDirty this
		
	setRectangle: (rectangle) ->
		
		@rectangle_ = avo.Rectangle.round rectangle
		@setDirty()
		
	rectangle: -> @rectangle_
	
	setPosition: (position) ->
		
		@setRectangle avo.Rectangle.compose(
			position
			avo.Rectangle.size @rectangle_
		)
	position: -> avo.Rectangle.position @rectangle_
	
	setSize: (size) ->
		
		@setRectangle avo.Rectangle.compose(
			avo.Rectangle.position @rectangle_
			size
		)
	size: -> avo.Rectangle.size @rectangle_
	
	setLastRectangle: (lastRectangle) -> @lastRectangle_ = avo.Rectangle.round lastRectangle
	lastRectangle: -> @lastRectangle_
	
	render: (position, clip, destination) ->