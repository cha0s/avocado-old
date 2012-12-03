
CoreService = require('Core').CoreService
Image = require('Graphics').Image
Rectangle = require 'core/Extension/Rectangle'
upon = require 'core/Utility/upon'
Vector = require 'core/Extension/Vector'

module.exports = Tileset = class

	constructor: ->
	
		@image_ = null
		@tileSize_ = [0, 0]
		@tiles_ = [0, 0]
	
	fromObject: (O) ->
		
		defer = upon.defer()
		
		@["#{i}_"] = O[i] for i of O
	
		uri = O.imageUri ? O.uri.replace '.tileset.json', '.png'
		Image.load(uri).then (@image_) =>
		
			@setTileSize @tileSize_
		
			defer.resolve()
	
		defer.promise
	
	@load: (uri) ->
		
		defer = upon.defer()
		
		CoreService.readJsonResource(uri).then (O) =>
			
			tileset = new Tileset()
			
			O.uri = uri
			tileset.fromObject(O).then ->
				
				defer.resolve tileset
		
		defer.promise
	
	copy: ->
		
		tileset = new Tileset()
		
		tileset.tileSize_ = Vector.copy @tileSize_
		tileset.tiles_ = Vector.copy @tiles_
		
		tileset.image_ = @image_
		
		tileset
	
	tileSize: -> @tileSize_
	setTileSize: (w, h) ->
		
		@tileSize_ = if h? then [w, h] else w
		
		return unless @image_?

		@tiles_ = Vector.div @image_.size(), @tileSize_
	
	tiles: -> @tiles_
	
	render: (
		location
		destination
		index
		mode
		tileClip = Rectangle.compose [0, 0], @tileSize_
	) ->
		
		return unless @image_?
		
		tileBox = @tileBox index
		tileBox = Rectangle.intersection(
			tileBox
			Rectangle.translated tileClip, Rectangle.position tileBox 
		)
		
		@image_.render(
			Vector.add location, Rectangle.position tileClip
			destination
			255
			mode
			tileBox
		)
	
	image: -> @image_
	
	isValid: ->
		
		return false unless @image_?
		
		not Vector.isNull @image_.size()
	
	tileBox: (index) ->
		
		Rectangle.compose(
			Vector.mul(
				[index % @tiles_[0], Math.floor index / @tiles_[0]]
				@tileSize_
			)
			@tileSize_
		)
		
	tileCount: -> @tiles[0] * @tiles[1]
