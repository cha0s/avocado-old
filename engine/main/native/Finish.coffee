Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

Sound.soundService.close()
Timing.timingService.close()
Graphics.graphicsService.close()
Core.coreService.close()
