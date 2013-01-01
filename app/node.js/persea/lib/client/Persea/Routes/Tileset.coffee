Color = require 'core/Graphics/Color'
CoreService = require 'main/web/Bindings/CoreService'
Image = require('Graphics').Image
Swipey = require 'Swipey'
Vector = require 'core/Extension/Vector'

TilesetModel = require 'Persea/Models/Tileset'

exports.Controller = Ember.Controller.extend

	tileWidth: 16
	tileHeight: 16
	
	tileSizeChanged: (->
		
		@set 'tileset.tileSize', [
			+@get 'tileWidth'
			+@get 'tileHeight'
		]
		
	).observes 'tileWidth', 'tileHeight'
	
exports.View = Ember.View.extend
	
	tilesetBinding: 'controller.tileset'
	tileWidthBinding: 'controller.tileWidth'
	tileHeightBinding: 'controller.tileHeight'
	
	tilesetStyle: (->
		
		return '' unless (object = @get 'tileset.object')?
		
		[width, height] = object.image().size()
		
		"
background-image: url(#{object.image().src});
width: #{width}px; 
height: #{height}px;
"
		
	).property 'tileset.object'
	
	swipeyReset: (->
		
		return unless (object = @get 'tileset.object')?
		return unless (swipey = @get 'swipey')?
		
		swipey.setMinMax(
			[0, 0]
			Vector.sub(
				object.tiles()
				Vector.floor Vector.div(
					[256, 256]
					object.tileSize()
				)
			)
		)
		
		swipey.setOffset [0, 0]
		
	).observes 'tileset.object', 'swipey'
	
	gridChanged: (->
	
		return unless (object = @get 'tileset.object')?
		return unless ($gridCanvas = @$('.grid'))?
		
		gridImage = new Image()
		tileImage = new Image object.tileSize()
		tiles = object.tiles()
		
		gridImage.Canvas = $gridCanvas[0]
		gridImage.fill 0, 0, 0, 0
		
		tileImage.lockPixels()
		for x in [0...object.tileWidth()]
			tileImage.setPixelAt(
				x, 0
				if x % 2 is 0
					Color.Rgb 255, 255, 255
				else
					Color.Rgb 0, 0, 0
			)
		for y in [0...object.tileHeight()]
			tileImage.setPixelAt(
				0, y
				if y % 2 is 0
					Color.Rgb 255, 255, 255
				else
					Color.Rgb 0, 0, 0
			)
		tileImage.unlockPixels()
		
		renderPosition = [0, 0]
		for y in [0...tiles[1]]
			for x in [0...tiles[0]]
				
				tileImage.render renderPosition, gridImage
				
				renderPosition[0] += object.tileWidth()
				
			renderPosition[0] = 0
			renderPosition[1] += object.tileHeight()
	
	).observes 'tileWidth', 'tileHeight', 'tileset.object'
		
	tilesetChanged: (->
		
		return unless (object = @get 'tileset.object')?
		
		@beginPropertyChanges()
		
		@set 'tileWidth', object.tileWidth()
		@set 'tileHeight', object.tileHeight()
		
		@endPropertyChanges()
		
	).observes 'tileset.object'
	
	didInsertElement: ->
	
		# Attach swiping behaviors to the tileset.
		swipey = new Swipey @$('.image-container'), 'tilesetSwipey'
		swipey.on 'update', (offset) =>
			
			return unless (object = @get 'tileset.object')?
			
			tileSize = object.tileSize()
			
			# Update the tileset image offset.
			[left, top] = Vector.mul(
				Vector.floor offset
				Vector.scale tileSize, -1
			)
			
			@$('.image').css left: left, top: top
			
		@set 'swipey', swipey
		
#		@$('.upload-tileset').click => @$('input.tileData').click()
		
		@$('input.tileData').change (event) =>
			
			i = 0
			while file = event.target.files[i++]
			
				continue unless file.type.match 'image.*'
				
				reader = new FileReader()
				reader.onload = ({target}) =>
					@set 'tileset.tileData', target.result.split(',')[1]
				reader.readAsDataURL file
				
		@gridChanged()
		
	template: Ember.Handlebars.compile """

<div id="tileset" class="container-fluid">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{currentProject.name}}</a> <span class="divider">/</span></li>
		<li><a {{action goToProjectTilesets currentProject href=true}} >Tilesets</a> <span class="divider">/</span></li>
		<li class="active">{{tileset.name}}</li>
	</ul>

	<h1>
		{{tileset.name}}
		{{#if tileset.isDirty}}
			*
		{{/if}}
		<small>
			{{environment.fetching}}
			{{#if tileset.isSaving}}
				Saving...
			{{/if}}
		</small>
	</h1>
	
	<div class="row-fluid form-row">
		
		<div class="span2">
			<label>Width</label>
			<div class="input-append">
				{{view Ember.TextField class="width input-mini" type="number" valueBinding="tileWidth"}}
				<span class="add-on">px</span>
			</div>
		</div>
		
		<div class="span2">
			<label>Height</label>
			<div class="input-append">
				{{view Ember.TextField class="height input-mini" type="number" valueBinding="tileHeight"}}
				<span class="add-on">px</span>
			</div>
		</div>
		
	</div>
	
	<div class="row-fluid">
		
		<div class="image-container">
			
			<div
				unselectable="off"
				class="image"
				{{bindAttr style="view.tilesetStyle"}}
			></div>
			
			<canvas width="256" height="256" class="grid"></canvas>
			
		</div>
		
		<input type="file" class="tileData" name="tileData[]" />
		
	</div>
	
</div>

"""

exports.Route = Ember.Route.extend
	
	route: '/:id'
	
	deserialize: (router, context) ->
		
		App.store.find TilesetModel, context.id
	
	serialize: (router, context) ->
		
		id: context.id
	
	connectOutlets: (router, tileset) ->
		
		router.get('applicationController').connectOutlet 'nav', 'nav'
		
		router.set 'tilesetController.tileset', tileset
		
		router.get('applicationController').connectOutlet 'footer', 'footer'
		
		router.set 'navController.fluid', true
		router.set 'footerController.fluid', true
		
		undefined
		
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			router.set 'tilesetController.currentProject', project
			
			router.get('applicationController').connectOutlet 'body', 'tileset'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.selected', 'tileset'
			
			undefined

