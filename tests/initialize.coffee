# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml'
Core.coreService = new Core.CoreService()

#Core.CoreService.setEngineRoot '../../../engine'
Core.CoreService.setResourceRoot 'tests/resource'
	
# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml'
Sound.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 80

# SPI proxies.
require 'core/proxySpiis'

beforeEach ->
