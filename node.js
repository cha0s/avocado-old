
var avo = require('avo');

var fs = require('fs');

console.log(fs.readdirSync('engine/core'));

console.log(Object.keys(avo));

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
