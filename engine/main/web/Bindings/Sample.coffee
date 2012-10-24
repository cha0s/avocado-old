
Sound = require 'main/web/Bindings/Sound'
upon = require 'core/Utility/upon'

module.exports = class extends Sound
	
	@['%load'] = (uri, fn) ->
		
		Sound.load(uri).then (sound) ->
			
			sample = new Sample()
			
			sample.Media = sound.Media
			sample.Audio = sound.Audio
			sample.URI = sound.URI
			
			fn sample
	
