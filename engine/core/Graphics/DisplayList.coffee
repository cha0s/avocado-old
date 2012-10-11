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
		renderRectangles = []
		
		# Nothing to render?
		return renderRectangles unless @dirtyCommands_.length > 0
		
		# Keep track of the display offset so we can translate the resulting
		# dirty rectangle back later.
		offset = avo.Vector.scale(
			avo.Rectangle.position visibleRectangle
			-1
		)
		
		# Separate the visible clean commands so we have less to check.
		cleanCommands = _.difference @commands_, @dirtyCommands_
		cleanCommands = _.filter cleanCommands, (command) ->
			avo.Rectangle.intersects(
				command.relativeRectangle visibleRectangle
				visibleRectangle
			)
			
		# All commands are dirty? Just render everything!
		if cleanCommands.length is 0
			
			for command in _.sortBy @dirtyCommands_, 'commandId_'
				
				# Render this command.
				command.render(
					avo.Vector.sub(
						command.relativePosition visibleRectangle
						avo.Rectangle.position visibleRectangle
					)
					avo.Rectangle.compose [0, 0], command.size()
					destination
				)
				
				command.setLastRectangle command.rectangle()
				
			# Refresh everything.
			renderRectangles.push visibleRectangle
				
		else
		
			renderCommands = (commands, rectangle) ->
				for command in _.sortBy commands, 'commandId_'
				
					# Make sure this command intersects the current
					# rectangle.
					dirtyIntersection = avo.Rectangle.intersection(
						rectangle
						command.relativeRectangle visibleRectangle
					)
					continue if avo.Rectangle.isNull dirtyIntersection
					
					# Make sure this command is actually visible.
					intersection = avo.Rectangle.intersection(
						dirtyIntersection
						visibleRectangle
					)
					continue if avo.Rectangle.isNull intersection
					
					# Add this command's rectangle to the rendering
					# rectangles list.
					renderRectangles.push intersection
					
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
								avo.Rectangle.position command.relativeRectangle visibleRectangle
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
				
				rectangle = dirtyCommand.lastRelativeRectangle visibleRectangle
				
				continue unless avo.Rectangle.intersects(
					rectangle
					visibleRectangle
				)
			
				renderCommands _.filter(
					cleanCommands
					(command) -> avo.Rectangle.intersects(
						command.relativeRectangle visibleRectangle
						rectangle
					)
				), rectangle
				
			# Render all clean and dirty commands that intersect all dirty
			# rectangles.
			for dirtyCommand in @dirtyCommands_
			
				rectangle = dirtyCommand.relativeRectangle visibleRectangle
				dirtyCommand.setLastRectangle dirtyCommand.rectangle()
				
				continue unless avo.Rectangle.intersects(
					rectangle
					visibleRectangle
				)
			
				renderCommands _.filter(
					cleanCommands.concat @dirtyCommands_
					(command) -> avo.Rectangle.intersects(
						command.relativeRectangle visibleRectangle
						rectangle
					)
				), rectangle
		
		# Clean ALL the commands!
		@dirtyCommands_ = []
		
		# Let caller know which areas are actually dirty.
		_.map renderRectangles, (renderRectangle) ->
			avo.Rectangle.translated renderRectangle, offset
		
# avo.**DisplayCommand** is an abstract base class to implement a display
# command.
class avo.DisplayCommand

	constructor: (list, rectangle = [0, 0, 0, 0]) ->
		
		@list_ = list
		@list_.addCommand this
		
		@setRectangle rectangle
		@setLastRectangle [0, 0, 0, 0]
		
		@setIsRelative true
		
	setDirty: ->
		
		@list_.setCommandDirty this
	
	setIsRelative: (isRelative) -> @isRelative_ = isRelative
	isRelative: -> @isRelative_
		
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
	
	calculateRelative: (rectangle, visible) ->
		
		if @isRelative()
			rectangle
		else
			avo.Rectangle.compose(
				avo.Vector.add(
					avo.Rectangle.position visible
					avo.Rectangle.position rectangle
				)
				avo.Rectangle.size rectangle
			)
			
	relativeRectangle: (visible) -> @calculateRelative @rectangle_, visible
		
	relativePosition: (visible) ->
		
		avo.Rectangle.position @relativeRectangle visible
	
	setLastRectangle: (lastRectangle) -> @lastRectangle_ = avo.Rectangle.round lastRectangle
	lastRectangle: -> @lastRectangle_
	
	lastRelativeRectangle: (visible) -> @calculateRelative @lastRectangle_, visible
	
	render: (position, clip, destination) ->
