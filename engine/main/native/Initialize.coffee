global = this

@require = (name) ->
	
	throw new Error "Module #{name} not found!" unless requires_[name]?
	
	unless requires_[name].module?
		exports = {}
		module = exports: exports
		
		f = requires_[name]
		requires_[name] = module: module
		
		f.call global, module, exports
		
	requires_[name].module.exports

Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

# Use SFML CoreService for now.
Core.CoreService.implementSpi 'sfml'
Core.coreService = new Core.CoreService()

# Use SFML GraphicsService for now.
Graphics.GraphicsService.implementSpi 'sfml'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing.TimingService.implementSpi 'sfml'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound.SoundService.implementSpi 'sfml'
Sound.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

handles = {}
handleIndex = 1

handleFreeIds = {}
handleFreeList = []

setCallback = (fn, duration, O, isInterval) ->
	
	fn: fn
	O: O ?= this
	duration: duration / 1000
	thisCall: Timing.TimingService.elapsed()
	isInterval: isInterval

newHandle = (fn, duration, O, isInterval) ->
	
	if handleFreeList.length is 0
		
		id = handleIndex++
		
	else
	
		delete handleFreeIds[id = handleFreeList.shift()]
		throw new Error 'Duplicate timeout handle!' if handles[id]?
		
	handles[id] = setCallback fn, duration, O, isInterval
	handles[id].id = id
	
	return handles[id]

clearHandle = (handle) ->
	return if not handle? or handle.id is 0
	
	id = handle.id
	handles[handle.id].id = 0
	delete handles[id]
	
	if not handleFreeIds[id]
	
		handleFreeIds[id] = true
		handleFreeList.push id

Timing['%setTimeout'] = (fn, duration, O) -> newHandle fn, duration, O, false

Timing['%setInterval'] = (fn, duration, O) -> newHandle fn, duration, O, true

Timing['%clearTimeout'] = Timing['%clearInterval'] = clearHandle

Timing.tickTimeouts = ->
	
	for id, handle of handles
		
		if Timing.TimingService.elapsed() >= handle.thisCall + handle.duration
			
			if not handle.isInterval
			
				clearHandle {id: parseInt id}
				
			else
			
				handle.thisCall = Timing.TimingService.elapsed()

			handle.fn.apply handle.O
			
