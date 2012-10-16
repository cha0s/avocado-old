class avo.Music extends avo.Sound

	@['%load'] = (uri) ->
		
		defer = upon.defer()
		
		soundPromise = avo.Sound.load uri
		soundPromise.then (sound) ->
			
			music = new Music()
			
			music.Media = sound.Media
			music.Audio = sound.Audio
			music.URI = sound.URI
			
			defer.resolve music
		
		defer.promise
		
	'%fadeIn': (@Loops, ms) ->
		return unless @Media?
		
		@addPlayEventListeners()
		
		@Media.volume = 0
		@Media.play()
		
		elapsed = avo.TimingService.elapsed()
		
		fadeInterval = setInterval(
			=>
				volume = (avo.TimingService.elapsed() - elapsed) / (ms / 1000)
				volume = 1 if volume > 1
				
				@Media.volume = volume
				
				if volume is 1
					
					clearInterval fadeInterval
			50
		)
	
	'%fadeOut': (ms) ->
		return unless @Media?
		
		magnitude = @Media.volume
		elapsed = avo.TimingService.elapsed()
		
		fadeInterval = setInterval(
			=>
				t = (avo.TimingService.elapsed() - elapsed) * 1000
				volume = magnitude - magnitude * t / ms
				volume = 0 if volume < 0
				
				@Media.volume = volume
				
				if volume is 0
					
					@removePlayEventListeners()
					
					@Media.pause()
					@Media.currentTime = 0
					
					clearInterval fadeInterval
			50
		)

