# SPI proxy and constant definitions.

# avo.**Image** handles image resource management. Primitive operations such
# as filling, line, circle, box drawing and rasterization are supported. All
# image resources are loaded through avo.**Image**.load. 

# Draw mode constants.
# 
# * <code>avo.Image.DrawMode_Replace</code>: Write over any graphics under this
# image when rendering.
# * <code>avo.Image.DrawMode_Blend</code>: ***(default)*** Blend the image with
# any graphics underneath using alpha pixel values.
avo.Image.DrawMode_Replace = 0
avo.Image.DrawMode_Blend   = 1

# Calculate the pixel value of two pixels blended together with alpha.
avo.Image.blendPixel = (src, dst, alpha = 255) ->
	return unless src? and dst?
	
	# If source alpha is 0, then use the destination.
	{sr, sg, sb, sa} = Rgba src
	return dst unless sa > 0
	
	# Calculate the source pixel alpha.
	pAlpha = sa * (alpha / 255)
	
	# Do the [alpha blending](http://en.wikipedia.org/wiki/Alpha_compositing#Alpha_blending).
	{dr, dg, db, da} = Rgba dst
	dr = (sr * pAlpha + dr * (255 - pAlpha)) / 255
	dg = (sg * pAlpha + dg * (255 - pAlpha)) / 255
	db = (sb * pAlpha + db * (255 - pAlpha)) / 255
	da = pAlpha
	
	# Shift the pixel colors back into a single 32-bit integer.
	Rgba dr, dg, db, da

# Load an image at the specified URI.
avo.Image.load = (uri) ->
	return unless uri?
	
	avo.Image['%load'] uri

# Show the image.
avo.Image::display = avo.Image::['%display']

# Draw a circle at the given x, y with the given radius. Draw it with the given
# RGBA color, and with the given draw mode.
avo.Image::drawCircle = (point, radius, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless point? and radius? and r? and g? and b?
	
	@['%drawCircle'] point, radius, r, g, b, a, mode

# Draw a filled box at the given x, y with the given width, height dimensions.
# Draw it with the given RGBA color, and with the given draw mode.	
avo.Image::drawFilledBox = (box, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawFilledBox'] box, r, g, b, a, mode

# Draw a line at the given x, y to the x2, y2. Draw it with the given RGBA
# color, and with the given draw mode.
avo.Image::drawLine = (line, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless line? and r? and g? and b?
	
	@['%drawLine'] line, r, g, b, a, mode
	
# Draw a box at the given x, y with the given width, height dimensions. Draw it
# with the given RGBA color, and with the given draw mode.
avo.Image::drawLineBox = (box, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawLineBox'] box, r, g, b, a, mode
	
# Fill with a specified color.
avo.Image::fill = (r, g, b, a = 255) ->
	return unless r? and g? and b?
	
	@['%fill'] r, g, b, a

# Get the height of the image.	
avo.Image::height = avo.Image::['%height']

avo.Image::lockPixels = -> @['%lockPixels']?()

# Get the pixel color at a given x, y coordinate.
avo.Image::pixelAt = (x, y) ->
	return unless x? and y?
	
	@['%pixelAt'] x, y
	
# Render this image at x, y onto another image with the given alpha blending
# and draw mode, using the given sx, sy, sw, sh source rectangle to clip.
avo.Image::render = (position, destination, alpha = 255, mode = avo.Image.DrawMode_Blend, sourceRect = [0, 0, 0, 0]) ->
	return unless position? and destination?
	
	@['%render'] position, destination, alpha, mode, sourceRect

# Set the pixel color at a given x, y coordinate.	
avo.Image::setPixelAt = (x, y, color) ->
	return unless x? and y? and color?
	
	@['%setPixelAt'] x, y, color
	
# Get the size of the image.
avo.Image::size = -> [@width(), @height()]

avo.Image::unlockPixels = -> @['%unlockPixels']?()

# Get the URI (if any) used to load this image.
avo.Image::uri = avo.Image::['%uri']

# Get the width of the image.
avo.Image::width = avo.Image::['%width']
