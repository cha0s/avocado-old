
avo = require 'avo'

Core = require 'Core'
Graphics = require 'Graphics'
Timing = require 'Timing'
Sound = require 'Sound'

# Use SFML CoreService for now.
Core.CoreService.implementSpi 'sfml'
avo.coreService = new Core.CoreService()

# Use SFML GraphicsService for now.
Graphics.GraphicsService.implementSpi 'sfml'
avo.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing.TimingService.implementSpi 'sfml'
avo.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound.SoundService.implementSpi 'sfml'
avo.soundService = new Sound.SoundService()

# Shoot for 60 FPS input and render.
avo.ticksPerSecondTarget = 120
avo.rendersPerSecondTarget = 80

console.log(Object.keys(avo));

###

//var fs = require('fs');

//console.log(fs.readdirSync('engine/core'));

//
//var CoreService = require('CoreService').CoreService;
//
//CoreService.implementSpi('sfml');
//var coreService = new CoreService();
//
//var GS = require('GraphicsService');
//var GraphicsService = GS.GraphicsService;
//GraphicsService.implementSpi('sfml');
//var graphicsService = new GraphicsService();
//
//var w = new GS.Window();
//
//w['%setSize']([640, 480]);
//
//setTimeout(
//	function() {},
//	3000
//);

###
