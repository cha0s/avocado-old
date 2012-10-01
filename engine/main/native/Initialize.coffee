
# Use SDL CoreService for now.
avo.CoreService.implementSpi 'sdl'
avo.coreService = new avo.CoreService()

# Use SDL GraphicsService for now.
avo.GraphicsService.implementSpi 'sdl'
avo.graphicsService = new avo.GraphicsService()

# Use SDL TimingService for now.
avo.TimingService.implementSpi 'sdl'
avo.timingService = new avo.TimingService()
