module.exports = Ember.CollectionView.extend
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	itemViewClass: Ember.View.extend
		
		attributeBindings: ['unselectable']
		unselectable: 'on'
		
		didInsertElement: ->
			
			$layer = @$()
			
			roomObject = @get 'content.roomObject'
			environmentObject = @get 'content.environmentObject'
			
			sizeInTiles = roomObject.size()
			tileset = environmentObject.tileset()
			tileIndices = roomObject.layer($layer.index()).tileIndices_
			tileSize = tileset.tileSize()
			
			layer = new Image()
			layer.Canvas = $('canvas', $layer)[0]
			
			# Render the layer, row by row.
			y = 0
			indexPointer = 0
			renderPosition = [0, 0]
			(renderTile = =>
				for x in [0...sizeInTiles[0]]
					if index = tileIndices[indexPointer++]
						tileset.render(
							renderPosition
							layer
							index
						)
					
					renderPosition[0] += tileSize[0]
					
				renderPosition[0] = 0
				renderPosition[1] += tileSize[1]
				
				# Defer the next render until we get a tick from the VM, to
				# the browser's UI thread a chance to keep updating.
				_.defer renderTile if ++y < sizeInTiles[1]
			)()
		
		classNames: ['layer']
		template: Ember.Handlebars.compile """

<canvas
	unselectable="on"
	class="canvas"
	{{bindAttr width="view.content.width"}}
	{{bindAttr height="view.content.height"}}
	{{bindAttr style="view.content.style"}}
	{{bindAttr solo="view.content.solo"}}
>
</canvas>

"""

