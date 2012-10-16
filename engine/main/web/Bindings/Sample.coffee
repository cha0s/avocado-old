class avo.Sample extends avo.Sound
	
	@['%load'] = (uri) ->
		
		defer = upon.defer()
		
		soundPromise = Sound.load uri
		soundPromise.then (sound) ->
			
			sample = new Sample()
			
			sample.Media = sound.Media
			sample.Audio = sound.Audio
			sample.URI = sound.URI
			
			defer.resolve sample
		
		defer.promise
	
