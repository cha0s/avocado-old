# avo.**TileLayer** represents a 2D tile matrix. It is a glorified array of
# tile indices which index into a tileset.
class avo.TileLayer
	
	constructor: ->
	
		# The tile index data.
		@tileIndices_ = null
		
		# The size of the tile matrix.
		@size_ = [0, 0]
		
	fromObject: (O) ->
		
		defer = upon.defer()
		
		@["#{i}_"] = O[i] for i of O
		
		@size_ = avo.Vector.copy @size_
		
		@tileIndices_ = @tileIndices_.slice 0 if @tileIndices_
			
		defer.resolve()
			
		defer.promise
	
	toJSON: ->
		
		tileIndices = if 0 isnt Math.max.apply Math, @tileIndices_
			@tileIndices_
		else
			null
			
		tileIndices: tileIndices
		size: @size_
		
	copy: ->
		
		layer = new TileLayer()
		layer.fromObject @toJSON()
		
		layer 
	
	# Resize the layer, losing as little information as possible.
	resize: (w, h) ->
		
		size = if w instanceof Array then w else [w, h]
		
		tileIndices = new Array size[0] * size[1]
		for y in [0...size[1]]
			for x in [0...size[0]]
				tileIndices[y * size[0] + x] = @tileIndex x, y
				
		@size_ = size
		@tileIndices_ = tileIndices
	
	size: -> @size_
	
	# Calculate a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     vector = [10, 10]
	#     calcTileIndex vector
	# * With width, height:
	#     calcTileIndex 10, 10
	# * With a tile index:
	#     calcTileIndex 28
	calcTileIndex: (x, y) ->
		
		return unless @tileIsValid x, y
		
		[x, y] = x if x instanceof Array
		
		if y? then @size_[0] * y + x else x
	
	# Retrieve a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     vector = [10, 10]
	#     tileIndex vector
	# * With width, height:
	#     tileIndex 10, 10
	# * With a tile index:
	#     tileIndex 28
	tileIndex: (x, y) ->
	
		return 0 unless @tileIndices_?
		
		@tileIndices_[@calcTileIndex x, y] ? 0
	
	# Set a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     vector = [10, 10]
	#     setTileIndex index, vector
	# * With width, height:
	#     setTileIndex index, 10, 10
	# * With a tile index:
	#     setTileIndex index, 28
	setTileIndex: (index, x, y) ->
	
		i = @calcTileIndex x, y
		
		return unless i?
		
		@tileIndices_[i] = index
	
	# Check whether a tile is valid. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     vector = [10, 10]
	#     tileIsValid vector
	# * With width, height:
	#     tileIsValid 10, 10
	# * With a tile index:
	#     tileIsValid 28
	tileIsValid: (x, y) ->
		
		[x, y] = x if x instanceof Array
		
		return false if x < 0
		
		if y?
		
			y >= 0 and x < @size_[0] and y < @size_[1]
			
		else
			
			x < @area()
	
	# Calculate the area of the tile layer.
	area: -> @size_[0] * @size_[1]
	
	render: (
		position
		tileset
		destination
		clip = [0, 0, 0, 0]
		mode = avo.Image.DrawMode_Blend
	) ->
		
		return unless @tileIndices_?
		
		tileSize = tileset.tileSize()
		
		matrixRenderer clip, tileSize, (matrix) =>
			
			index = @tileIndex matrix.start
			tileset.render(
				avo.Vector.sub(
					avo.Vector.mul matrix.start, tileSize
					position
				)
				destination
				index
				mode
				matrix.clip
			) if index
				
# Helper function - Ease a lot of the initial calculations involved with doing
# partial tile matrix rendering. Returns an object with useful calculated
# results.
matrixBreaker = (clip, unit) ->

	start = avo.Vector.floor avo.Vector.div(
		avo.Rectangle.position clip
		unit
	)
	endOffset = [
		(clip[0] + clip[2]) % unit[0]
		(clip[1] + clip[3]) % unit[1]
	]
	start: start
	endOffset: endOffset
	area: avo.Vector.add(
		[
			if endOffset[0] then 1 else 0
			if endOffset[1] then 1 else 0
		]
		avo.Vector.sub(
			avo.Vector.floor avo.Vector.div(
				avo.Vector.add(
					avo.Rectangle.position clip
					avo.Rectangle.size clip
				)
				unit
			)
			start
		)
	)
	startOffset: [
		clip[0] % unit[0]
		clip[1] % unit[1]
	]
	clip: avo.Rectangle.compose [0, 0], unit
	
# Helper function - Eases rendering of clipped tile matrices.
matrixRenderer = (clip, unit, f) ->

	matrix = matrixBreaker clip, unit
	for y in [0...matrix.area[1]]
		matrix.clip[1] = 0
		matrix.clip[3] = unit[1]
		
		matrix.clip[1] = matrix.startOffset[1] if y is 0
		if y is matrix.area[1] - 1
			matrix.clip[3] = matrix.endOffset[1] if matrix.endOffset[1] > 0
		matrix.clip[3] -= matrix.clip[1]
		
		for x in [0...matrix.area[0]]
			matrix.clip[0] = 0
			matrix.clip[2] = unit[0]
			
			matrix.clip[0] = matrix.startOffset[0] if x is 0
			if x is matrix.area[0] - 1
				matrix.clip[2] = matrix.endOffset[0] if matrix.endOffset[0] > 0
			matrix.clip[2] -= matrix.clip[0]
			
			f matrix
			
			matrix.start[0] += 1
			
		matrix.start[0] -= matrix.area[0]
		matrix.start[1] += 1
		
	undefined

class avo.TileLayerDisplayCommand extends avo.DisplayCommand
	
	constructor: (list, @layer_, @tileset_, rectangle = [0, 0, 0, 0]) ->
		super list, rectangle
		
		@cache_ = {}
		@freeQuads_ = []
		
		# We take an approach here as tradeoff between space and time. This
		# approach allocates 16 half-window-sized images which compose a 4x4
		# grid. The visible portion is in the middle of this grid, and when
		# the edge of the grid is approached, the next image is cached. 
		@halfWindowSize_ = avo.Vector.scale avo.window.size(), .5
		
	render: (position, clip, destination) ->
		
		if _.isEmpty @cache_
			for i in [0...16]
				@cache_[i] = new avo.Image @halfWindowSize_
		
		section = avo.Vector.mul(
			avo.Vector.floor(
				avo.Vector.div @list().position(), @halfWindowSize_
			)
			@halfWindowSize_
		)
		
		cache = {}
		
		offset = avo.Vector.scale @halfWindowSize_, -1
		for y in [0...4]
			for x in [0...4]
				
				rect = avo.Rectangle.compose(
					avo.Vector.add offset, section
					@halfWindowSize_
				)
				
				offset[0] += @halfWindowSize_[0]
				
				if @cache_[rect]?
					cache[rect] = @cache_[rect]
		
			offset[0] -= @halfWindowSize_[0] * 4
			offset[1] += @halfWindowSize_[1]
			 
		for rect, image of @cache_
			unless cache[rect]?
				image.fill 0, 0, 0, 0
				@freeQuads_.push image
				
		@cache_ = cache
		
		offset = avo.Vector.scale @halfWindowSize_, -1
		for y in [0...4]
			for x in [0...4]
				
				rect = avo.Rectangle.compose(
					avo.Vector.add offset, section
					@halfWindowSize_
				)
				
				offset[0] += @halfWindowSize_[0]
				
				continue if rect[0] < 0
				continue if rect[1] < 0
				continue if rect[0] >= @size()[0]
				continue if rect[1] >= @size()[1]
				
				unless @cache_[rect]?

					@layer_.render(
						avo.Rectangle.position rect
						@tileset_
						@cache_[rect] = @freeQuads_.pop()
						rect
						255
						avo.Image.DrawMode_Replace
					)
					
			offset[0] -= @halfWindowSize_[0] * 4
			offset[1] += @halfWindowSize_[1] 
		
		matrixRenderer clip, @halfWindowSize_, (matrix) =>
			
			rect = avo.Rectangle.compose(
				avo.Vector.mul matrix.start, @halfWindowSize_
				@halfWindowSize_
			)
			
			@cache_[rect].render(
				avo.Vector.sub(
					avo.Vector.add(
						avo.Vector.mul matrix.start, @halfWindowSize_
						matrix.clip
					)
					@list().position()
				)
				destination
				255
				avo.Image.DrawMode_Blend
				matrix.clip
			)
