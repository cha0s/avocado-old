class avo.Tileset

	constructor: ->
	
		@image_ = null
		@tileSize_ = [0, 0]
		@tiles_ = [0, 0]
	
	fromObject: (O) ->
		
		defer = upon.defer()
		
		@["#{i}_"] = O[i] for i of O
	
		uri = O.imageUri ? O.uri.replace '.tileset.json', '.png'
		avo.Image.load(uri).then (@image_) =>
		
			@setTileSize @tileSize_
		
			defer.resolve()
	
		defer.promise
	
	@load: (uri) ->
		
		defer = upon.defer()
		
		avo.CoreService.readJsonResource(uri).then (O) =>
			
			tileset = new Tileset()
			
			O.uri = uri
			tileset.fromObject(O).then ->
				
				defer.resolve tileset
		
		defer.promise
	
	copy: ->
		
		tileset = new Tileset()
		
		tileset.tileSize_ = avo.Vector.copy @tileSize_
		tileset.tiles_ = avo.Vector.copy @tiles_
		
		tileset.image_ = @image_
		
		tileset
	
	tileSize: -> @tileSize_
	setTileSize: (w, h) ->
		
		@tileSize_ = if h? then [w, h] else w
		
		return unless @image_?

		@tiles_ = avo.Vector.div @image_.size(), @tileSize_
	
	render: (
		location
		destination
		index
		mode
		tileClip = avo.Rectangle.compose [0, 0], @tileSize_
	) ->
		
		return unless @image_?
		
		tileBox = @tileBox index
		tileBox = avo.Rectangle.intersection(
			tileBox
			avo.Rectangle.translated tileClip, avo.Rectangle.position tileBox 
		)
		
		@image_.render(
			avo.Vector.add location, avo.Rectangle.position tileClip
			destination
			255
			mode
			tileBox
		)
	
	image: -> @image_
	
	isValid: ->
		
		return false unless @image_?
		
		not avo.Vector.isNull @image_.size()
	
	tileBox: (index) ->
		
		avo.Rectangle.compose(
			avo.Vector.mul(
				[index % @tiles_[0], Math.floor index / @tiles_[0]]
				@tileSize_
			)
			@tileSize_
		)
		
	tileCount: -> @tiles[0] * @tiles[1]
