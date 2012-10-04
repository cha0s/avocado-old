# Use SDL CoreService for now.
avo.CoreService.implementSpi 'sdl'
avo.coreService = new avo.CoreService()

# Use SDL GraphicsService for now.
avo.GraphicsService.implementSpi 'sdl'
avo.graphicsService = new avo.GraphicsService()

# Use SDL InputService for now.
avo.InputService.implementSpi 'sdl'
avo.inputService = new avo.InputService()

# Use SDL TimingService for now.
avo.TimingService.implementSpi 'sdl'
avo.timingService = new avo.TimingService()

# Use SDL SoundService for now.
avo.SoundService.implementSpi 'sdl'
avo.soundService = new avo.SoundService()

# Shoot for 60 FPS input and render.
avo.ticksPerSecondTarget = 60
avo.rendersPerSecondTarget = 60

handles = {}
handleIndex = 1

handleFreeIds = {}
handleFreeList = []

setCallback = (fn, duration, O, isInterval) ->
	
	fn: fn
	O: O ?= this
	duration: duration / 1000
	nextCall: avo.TimingService.elapsed()
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

avo['%setTimeout'] = (fn, duration, O) -> newHandle fn, duration, O, false

avo['%setInterval'] = (fn, duration, O) -> newHandle fn, duration, O, true

avo['%clearTimeout'] = avo['%clearInterval'] = clearHandle

avo.tickTimeouts = ->
	
	for id, handle of handles
		
		if avo.TimingService.elapsed() >= handle.nextCall + handle.duration
			
			handle.fn.apply handle.O
			
			if not handle.isInterval
			
				clearHandle {id: parseInt id}
				
			else
			
				handle.nextCall = avo.TimingService.elapsed()
