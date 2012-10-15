avo.Font.FontStyle_Regular   = 0
avo.Font.FontStyle_Bold      = 1
avo.Font.FontStyle_Italic    = 2
avo.Font.FontStyle_Underline = 4

# Load a font at the specified URI.
avo.Font.load = (uri) ->
	return unless uri?
	
	avo.Font['%load'] uri

avo.Font::render = (position, destination, text, clip = [0, 0, 0, 0]) ->
	return unless position? and destination? and text?
	
	@['%render'] position, destination, text, clip

avo.Font::setSize = (size) ->
	return unless size?
	
	@['%setSize'] size

avo.Font::setStyle = (style) ->
	return unless style?
	
	@['%setStyle'] style

avo.Font::textHeight = avo.Font::['%textHeight']

avo.Font::textWidth = avo.Font::['%textWidth']

avo.Font::textSize = (text) -> [@textWidth(), @textHeight()]
	
class avo.FontDisplayCommand extends avo.DisplayCommand
	
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
		
		@font_.render position, destination, @text_, clip
	