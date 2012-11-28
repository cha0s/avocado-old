requires_['Persea/Editor/Environment/ThumbsView'] = (module, exports) ->
	
	Dom = require 'core/Utility/Dom'
	
	ThumbView = require 'Persea/Editor/Environment/ThumbView'
	
	module.exports = Backbone.View.extend
		
		tagName: 'ul'
		
		initialize: ({
			@subjects
		}) ->
			
			@canvasWidth = 'auto'
		
			# Allow swiping through thumbnails when they can't all fit.
			@$thumbs = $ '#subject-thumbs'
			(@$thumbsContainer = $ '#subject-thumbs-container').on
				mousedown: => @$thumbs.stop()
				swipeleft: (e, delta) => @handleSwipe delta, '-'
				swiperight: (e, delta) => @handleSwipe delta, '+'
			
			@$thumbs.append @el
			
		setSubjects: (@subjects) ->
			
			@subjects.bind 'add reset remove', @render, this
			
		setCanvasWidth: (@canvasWidth) -> @render()
		
		handleSwipe: (delta, op) ->
			
			# nop if the thumbnails fit.
			return unless @$thumbs.width() > @$thumbsContainer.width()
			
			# Exponential swipe delta.
			delta = Math.abs delta.end.coords[0] - delta.start.coords[0] - 30
			delta = Math.pow delta, 1.1
			
			# Calculate the offset destination.
			offsetDestination = @$thumbs.css 'left'
			offsetDestination = parseInt offsetDestination.substr 0, offsetDestination.length - 2
			offsetDestination = switch op
				when '+' then offsetDestination + delta
				when '-' then offsetDestination - delta
			offsetDestination = Math.max(
				-(@$thumbs.width() - @$thumbsContainer.width()) + 20
				Math.min(
					0
					offsetDestination
				)
			)
			
			# Animate to the offset.
			@$thumbs.animate(
				left: offsetDestination
			,
				1500
				'easeOutExpo'
			)
			
		render: ->
			
			# Thumbnail bar.
			@$el.empty()
			@subjects.each (subject) =>
				
				view = new ThumbView model: subject
				view.on 'subjectChanged', (model) => @subjects.trigger 'subjectChanged', model
				@$el.append view.render().el
	
			# Calculate width of all elements, stop animating, and reset
			# offset.
			@$thumbsContainer.css 'width', @canvasWidth
			@$thumbs.css 'width', _.reduce(
				$('.subject-thumb', @$thumbs)
				(l, r) -> l + Dom.outerWidth r, true
				0
			)
			@$thumbs.stop()
			@$thumbs.css 'left', 0
