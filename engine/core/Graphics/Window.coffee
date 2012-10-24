# SPI proxy and constant definitions.

# **Window** handles window creation and properties of the window. 

Window = require('Graphics').Window

# Window creation constants.
# 
# * <code>Window.Flags_Default</code>: ***(default)*** Nothing special.
# * <code>Window.Flags_Fullscreen</code>: Create a fullscreen window.
# ***NOTE:*** May not be supported on all platforms.
Window.Flags_Default = 0
Window.Flags_Fullscreen = 1

# Mouse button constants.
Window.LeftButton   = 1
Window.MiddleButton = 2
Window.RightButton  = 3
Window.WheelUp      = 4
Window.WheelDown    = 5

# Show the window.
Window::display = Window::['%display']

# The height of the window.
Window::height = -> @size()[1]

# Poll for events sent to this window.
Window::pollEvents = Window::['%pollEvents']

# Render an Image onto this window.
Window::render = (image, rectangles = [[0, 0, 0, 0]]) ->
	return unless image?
	
	@['%render'] image, rectangle for rectangle in rectangles

# Set the window parameters.
Window::setFlags = (flags = Window.Flags_Default) ->
	return unless flags?
	
	@['%setFlags'] flags

# Set the window parameters.
Window::setSize = (size) ->
	return unless size?
	
	@['%setSize'] size

# Set whether the mouse is visible while hovering over the window.
Window::setMouseVisibility = (visibility) ->
	return unless visibility?
	
	@['%setMouseVisibility'] visibility

# Set the window title.
Window::setWindowTitle = (window, iconified = window) ->
	return unless window?
	
	@['%setWindowTitle'] window, iconified

# The size of the window.
Window::size = Window::['%size']

# The width of the window.
Window::width = -> @size()[0]
