class avo.RasterFont
	
	@load = (uri) ->
		
		defer = upon.defer()
		
		avo.Image.load(uri).then (image) ->
			font = new RasterFont()
			font.image_ = image
			font.charSize_ = avo.Vector.div font.image_.size(), [256, 1]
			defer.resolve font
			
		defer.promise
	
	textWidth: (text) -> text.length * @charSize_[0]
	
	textHeight: (text) -> @charSize_[1]
	
	textSize: (text) -> [
		@textWidth text
		@textHeight text
	]
	
	render: (
		position
		text
		destination
		clip = avo.Rectangle.compose [0, 0], @textSize text
		alpha = 255
		effect = null
	) ->
		
		# Get the current area of the Image to render, based on the current
		# character, as well as the frame size.
		rect = (character) => [
			character * @charSize_[0], 0
			@charSize_[0], @charSize_[1]
		]
		
		position = avo.Vector.sub position, avo.Rectangle.position clip
		clip = avo.Rectangle.translated clip, position
		
		# Pre-calc the length. Iterate over the string's characters.
		for i in [0...text.length]
		
			effectedLocation = avo.Vector.copy position
			effectedLocation = avo.Vector.add(
				effectedLocation
				effect.apply i
			) if effect?
			
			# Move right the width of the font.
			position[0] += @charSize_[0]
			
			# The bounding rect of the character to render.
			charRect = avo.Rectangle.compose effectedLocation, @charSize_
			
			# Don't render the character if it isn't in the clipping area.
			intersection = avo.Rectangle.intersection charRect, clip
			continue if avo.Rectangle.isNull intersection
			
			offset = avo.Vector.sub(
				avo.Rectangle.position intersection
				avo.Rectangle.position charRect
			)
			
			# Render the character.
			@image_.render(
				avo.Vector.add effectedLocation, offset
				destination
				alpha
				avo.Image.DrawMode_Blend
				avo.Rectangle.compose(
					avo.Vector.add(
						offset
						avo.Rectangle.position rect text.charCodeAt i
					)
					avo.Rectangle.size intersection
				)
			)

		undefined

class avo.RasterFontDisplayCommand extends avo.DisplayCommand
	
	constructor: (list, font, text, rectangle = [0, 0, 0, 0]) ->
		super list, rectangle
		
		@font_ = font
		@setText text
		
	setText: (text) ->
		
		oldText = @text_
		@text_ = text
		
		if oldText isnt @text_
			
			@setSize @font_.textSize text
			@markAsDirty()
		
	render: (position, clip, destination) ->
		
		@font_.render position, @text_, destination, clip
