# SPI proxy and constant definitions.

# avo.**Window** handles window creation and properties of the window. 

# Window creation constants.
# 
# * <code>avo.Window.Flags_Default</code>: (default) Nothing special.
# * <code>avo.Window.Flags_Fullscreen</code>: Create a fullscreen window.
# ***NOTE:*** May not be supported on all platforms.
avo.Window.Flags_Default = 0
avo.Window.Flags_Fullscreen = 1

# The height of the window.
avo.Window::height = -> @size()[1]

# Render an Image onto this window.
avo.Window::render = (image) ->
	return unless image?
	
	@['%render'] image

# Set the window parameters.
avo.Window::set = (size, flags = avo.Window.Flags_Default) ->
	return unless size?
	
	@['%set'] size, flags

# Set whether the mouse is visible while hovering over the window.
avo.Window::setMouseVisibility = (visibility) ->
	return unless visibility?
	
	@['%setMouseVisibility'] visibility

# Set the window title.
avo.Window::setWindowTitle = (window, iconified = window) ->
	return unless window?
	
	@['%setWindowTitle'] window, iconified

# The size of the window.
avo.Window::size = @['%size']

# The width of the window.
avo.Window::width = -> @size()[0]
