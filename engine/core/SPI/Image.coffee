avo.Image.DrawMode_Replace = 0
avo.Image.DrawMode_Blend   = 1

avo.Image.blendPixel = (src, dst, alpha = 255) ->
	return unless src? and dst?
	
	{r, g, b, a} = Rgba src
	sr = r; sg = g; sb = b; sa = a;
	
	return dst unless sa > 0
	
	{r, g, b, a} = Rgba dst
	dr = r; dg = g; db = b; da = a;
	
	pAlpha = sa * (alpha / 255)
	
	dr = (sr * pAlpha + dr * (255 - pAlpha)) / 255
	dg = (sg * pAlpha + dg * (255 - pAlpha)) / 255
	db = (sb * pAlpha + db * (255 - pAlpha)) / 255
	da = pAlpha
	
	Rgba dr, dg, db, da

avo.Image.load = (uri, qualify = true, fn = ->) ->
	return unless uri?
	
	avo.Image['%load'] uri, qualify, fn

avo.Image::drawBox = (box, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawBox'] box, r, g, b, a, mode
	
avo.Image::drawCircle = (point, radius, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless point? and radius? and r? and g? and b?
	
	@['%drawCircle'] point, radius, r, g, b, a, mode
	
avo.Image::drawLine = (line, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless line? and r? and g? and b?
	
	@['%drawLine'] line, r, g, b, a, mode
	
avo.Image::drawRect = (rect, r, g, b, a = 255, mode = avo.Image.DrawMode_Blend) ->
	return unless rect? and r? and g? and b?
	
	@['%drawRect'] rect, r, g, b, a, mode
	
avo.Image::fill = (r, g, b, a = 255) ->
	return unless r? and g? and b?
	
	@['%fill'] r, g, b, a
	
avo.Image::floodfill = (point, color) ->
	return unless point? and color?
	
	@['%floodfill'] point, color
	
avo.Image::height = -> @['%height']()

avo.Image::lockPixels = -> @['%lockPixels']?()

avo.Image::pixelAt = (x, y) ->
	return unless x? and y?
	
	@['%pixelAt'] x, y
	
avo.Image::render = (position, destination, alpha = 255, mode = avo.Image.DrawMode_Blend, sourceRect = [0, 0, 0, 0]) ->
	return unless position? and destination?
	
	@['%render'] position, destination, alpha, mode, sourceRect
	
avo.Image::renderGrayscale = (destination, amount = 1, darken = 1) ->
	return unless destination?
	
	@['%renderGrayscale'] destination, amount, darken
	
avo.Image::setPixelAt = (x, y, color) ->
	return unless x? and y? and color?
	
	@['%setPixelAt'] x, y, color
	
avo.Image::size = -> [@width(), @height()]

avo.Image::unlockPixels = -> @['%unlockPixels']?()

avo.Image::uri = -> @['%uri']()

avo.Image::width = -> @['%width']()
