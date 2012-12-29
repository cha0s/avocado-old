global = this

@require = require = (name) ->
	
	throw new Error "Module #{name} not found!" unless requires_[name]?
	
	unless requires_[name].module?
		exports = {}
		module = exports: exports
		
		f = requires_[name]
		requires_[name] = module: module
		
		f.call global, module, exports
		
	requires_[name].module.exports

@_ = require 'core/Utility/underscore'

# Hack in the SPIIs.
_.extend requires_, 
	Core:
		module: exports:
			CoreService: require 'main/web/Bindings/CoreService'

_.extend requires_, 
	Graphics:
		module: exports:
			GraphicsService: require 'main/web/Bindings/GraphicsService'
			Font: require 'main/web/Bindings/Font'
			Image: require 'main/web/Bindings/Image'
			Window: require 'main/web/Bindings/Window'

_.extend requires_, 
	Timing:
		module: exports:
			TimingService: require 'main/web/Bindings/TimingService'
			Counter: require 'main/web/Bindings/Counter'

_.extend requires_, 
	Sound:
		module: exports:
			SoundService: require 'main/web/Bindings/SoundService'
			Music: require 'main/web/Bindings/Music'
			Sample: require 'main/web/Bindings/Sample'

Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

Timing['%setTimeout'] = setTimeout
Timing['%setInterval'] = setInterval
Timing['%clearTimeout'] = clearTimeout
Timing['%clearInterval'] = clearInterval

Core.coreService = new Core.CoreService()
Graphics.graphicsService = new Graphics.GraphicsService()
Timing.timingService = new Timing.TimingService()
Sound.soundService = new Sound.SoundService()

Timing.ticksPerSecondTarget = 120
Timing.rendersPerSecondTarget = 60
