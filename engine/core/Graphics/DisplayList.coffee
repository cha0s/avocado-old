# avo.**DisplayList** is a
# [display list](http://en.wikipedia.org/wiki/Display_list). It is used for
# rendering graphics scene in an optimized way.
#
# The display list manages which parts of the scene have actually changed, and
# only renders the changes.
class avo.DisplayList
	
	constructor: (rectangle, worldRectangle) ->
		
		args = avo.Rectangle.toObject worldRectangle, true
		args.maxChildren = 2
		args.maxDepth = 4
		
		@quadTree = new avo.QuadTree args
		
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@dirtyCommands_ = {}
		
		@clear()
		@setRectangle rectangle
		
	setRectangle: (rectangle) ->
		return if @rectangle_? and avo.Rectangle.equals @rectangle_, rectangle
		
		@rectangle_ = rectangle
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@markCommandsAsDirty()
		
	rectangle: -> @rectangle_
	
	setPosition: (position) -> @setRectangle avo.Rectangle.compose(
		position
		avo.Rectangle.size @rectangle_
	)
	
	position: -> avo.Rectangle.position @rectangle_
	
	addCommandToQuadTree: (command) ->
	
		O = avo.Rectangle.toObject(
			command.relativeRectangle @rectangle_
			true
		)
		O.command = command
		command.O = O
		O.toJSON = ->
			x: @x
			y: @y
			w: @w
			h: @h
		
		@quadTree.insert O
		
	addCommand: (command) ->
		
		command.commandId_ = @commandId_++
		@commands_.push command
		
		# Add it to the QuadTree.
		@addCommandToQuadTree command
		
		command.markAsDirty = (
			rectangle = command.relativeRectangle @rectangle_
		) =>
			
			@dirtyCommands_[command.commandId_] = command
			
			@lastDirtyRectangle_ = avo.Rectangle.united(
				@lastDirtyRectangle_
				avo.Rectangle.intersection(
					command.relativeRectangle @rectangle_
					@rectangle_
				)
			)
			
		command.markAsDirty()
	
	clear: ->
		
		@commandId_ = 0
		@commands_ = []
		@dirtyCommands_ = {}
		@quadTree.clear()
	
	markCommandsAsDirty: (commandsAreDirty) ->
		
		affectedCommands = @quadTree.retrieve(
			avo.Rectangle.toObject(
				@rectangle_
				true
			)
		)
		affectedCommands = _.map affectedCommands, (O) -> O.command
		
		command.markAsDirty() for command in affectedCommands
	
	render: (destination) ->
		renderRectangles = []
		
		return renderRectangles if _.isEmpty @dirtyCommands_
		
		sortCommands = (commands) ->
			
			_.sortBy commands, 'commandId_'
		
		renderCommand = (command, intersection) =>
			
			# The actual position where rendering occurs.
			position = avo.Rectangle.position intersection
			position = avo.Vector.sub(
				position
				avo.Rectangle.position @rectangle_
			)
			
			# The clipping rectangle for rendering this command.
			clip = avo.Rectangle.compose(
				avo.Vector.sub(
					position
					avo.Vector.sub(
						avo.Rectangle.position command.relativeRectangle @rectangle_
						avo.Rectangle.position @rectangle_
					)
				)
				avo.Rectangle.size intersection
			)
			
			# Render this command.
			command.render position, clip, destination
			
		# Keep track of the display offset so we can translate the resulting
		# dirty rectangle back later.
		offset = avo.Vector.scale(
			avo.Rectangle.position @rectangle_
			-1
		)
		
		dirtyRectangle = [0, 0, 0, 0]
		dirtyCommands = []
		
		@dirtyCommands_ = (v for k, v of @dirtyCommands_) 
		for dirtyCommand in sortCommands @dirtyCommands_
			
			intersection = avo.Rectangle.intersection(
				dirtyCommand.relativeRectangle @rectangle_
				@rectangle_
			)
			continue if avo.Rectangle.isNull intersection
			
			dirtyCommands.push dirtyCommand
			
			dirtyRectangle = avo.Rectangle.united dirtyRectangle, intersection
		
		totalDirtyRectangle = avo.Rectangle.intersection(
			avo.Rectangle.united @lastDirtyRectangle_, dirtyRectangle
			@rectangle_
		)
		
		@quadTree.clear()
		for command in @commands_
			@addCommandToQuadTree command
		
		affectedCommands = @quadTree.retrieve(
			avo.Rectangle.toObject(
				totalDirtyRectangle
				true
			)
		)
		affectedCommands = _.map affectedCommands, (O) -> O.command
		affectedCommands = sortCommands affectedCommands
		
		cleanCommands = _.difference affectedCommands, @dirtyCommands_
		
		if cleanCommands.length > 0
			for command in cleanCommands
				
				intersection = avo.Rectangle.intersection(
					command.relativeRectangle @rectangle_
					@lastDirtyRectangle_
				)
				continue if avo.Rectangle.isNull intersection
				
				renderCommand command, intersection
				
			dirtyCommands = sortCommands dirtyCommands.concat cleanCommands
			
		for command in dirtyCommands

			intersection = avo.Rectangle.intersection(
				command.relativeRectangle @rectangle_
				dirtyRectangle
			)
			continue if avo.Rectangle.isNull intersection
			
			renderCommand command, intersection
			
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@dirtyCommands_ = {}
		
		renderRectangles.push(
			totalDirtyRectangle
		)
		
		# Let caller know which areas are actually dirty.
		_.map renderRectangles, (renderRectangle) ->
			avo.Rectangle.translated renderRectangle, offset
	
# avo.**DisplayCommand** is an abstract base class to implement a display
# command.
class avo.DisplayCommand

	constructor: (@list_, rectangle = [0, 0, 0, 0]) ->
		
		avo.Mixin this, avo.EventEmitter
		
		@rectangle_ = [0, 0, 0, 0]
		@setRectangle rectangle
		@setIsRelative true
		
		@list_.addCommand this
		@markAsDirty true
	
	list: -> @list_
		
	markAsDirty: (rectangle) ->
		
	setIsRelative: (isRelative) -> @isRelative_ = isRelative
	isRelative: -> @isRelative_
	
	setRectangle: (rectangle) ->
		
		return if @rectangle_? and avo.Rectangle.equals rectangle, @rectangle_
		
		@markAsDirty rectangle
		@rectangle_ = avo.Rectangle.round rectangle
		
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
			
	relativeRectangle: (visible) ->
		
		@calculateRelative @rectangle_, visible
		
	relativePosition: (visible) ->
		
		avo.Rectangle.position @relativeRectangle visible
	
	render: (position, clip, destination) ->
