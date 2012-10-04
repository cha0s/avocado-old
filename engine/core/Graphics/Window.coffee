# SPI proxy and constant definitions.

avo.Window.Flags_Default = 0
avo.Window.Flags_Fullscreen = 1

avo.Window::render = (buffer) ->
	return unless buffer?
	
	@['%render'] buffer

avo.Window::set = (size, flags = avo.Window.Flags_Default) ->
	return unless size?
	
	@['%set'] size, flags

avo.Window::setMouseVisibility = (visibility) ->
	return unless visibility?
	
	@['%setMouseVisibility'] visibility

avo.Window::setWindowTitle = (window, iconified = window) ->
	return unless window?
	
	@['%setWindowTitle'] window, iconified

avo.Window::size = @['%size']
