TabPanes = require 'Persea/MVC/TabPanes'

Landscape = require 'Persea/MVC/Environment/Landscape'
Entities = require 'Persea/MVC/Environment/Entities'
Collision = require 'Persea/MVC/Environment/Collision'

Document = require 'Persea/MVC/Environment/Document'

EnvironmentModel = require 'Persea/Models/Environment'

exports.mixinApp = (App) ->
	
	App.EnvironmentModel = EnvironmentModel

exports.Controller = Ember.Controller.extend
	
	documentController: Document.Controller.create()
	
	roomSelectContent: []
	currentRoom: null
	
	environmentChanged: (->
		
		environment = @get 'environment'
		
		for control in @get 'content'
			
			continue unless control.get('controller')?
			
			control.set 'controller.environment', environment
		
		@set 'documentController.environment', environment
		
	).observes 'environment'
	
	currentRoomChanged: (->
		
		currentRoom = @get 'currentRoom'
		
		for control in @get 'content'
			
			continue unless control.get('controller')?
			
			control.set 'controller.currentRoom', currentRoom
			
		@set 'documentController.currentRoom', currentRoom
		
	).observes 'currentRoom'
	
	environmentObjectChanged: (->
		
		environment = @get 'environment'
		
		return unless (object = environment.object)?
		
		roomSelectContent = for i in [0...object.roomCount()]
			
			index: i
			name: object.room(i).name()
			object: object.room i
				
		@set 'roomSelectContent', roomSelectContent
		@set 'currentRoom', roomSelectContent[1]
		
	).observes 'environment.object'
	
	content: [
		Landscape.controls			
		Entities.controls
		Collision.controls
	]
	
	init: ->
		
		@set 'selection', @get('content')[0]
		
		@set 'documentController.landscapeController', Landscape.controls.controller
		
exports.View = Ember.View.extend
	
	controlsView: TabPanes.View
	
	documentView: Document.View
	
	template: Ember.Handlebars.compile """

<div id="environment" class="container-fluid">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{currentProject.name}}</a> <span class="divider">/</span></li>
		<li><a {{action goToProjectEnvironments currentProject href=true}} >Environments</a> <span class="divider">/</span></li>
		<li class="active">{{environment.name}}</li>
	</ul>

	<div class="row-fluid">
		
		<div class="span4">
		
			<h1>{{environment.name}} <small>({{currentProject.name}})</small></h1>
	
			<h2>Rooms</h2>
			<div class="rooms">
				{{view Bootstrap.Forms.Select
					contentBinding="roomSelectContent"
					selectionBinding="currentRoom"
					optionLabelPath="content.name"
					optionValuePath="content.index"
				}}
			</div>
			
			{{view view.controlsView
				id="environment-controls"
			}}
			
		</div>
		
		{{view view.documentView
			class="span8 document-container"
			controller=documentController
		}}
		
	</div>
	
</div>

"""

exports.Route = Ember.Route.extend
	
	route: '/:id'
	
	deserialize: (router, context) ->
		
		App.store.find EnvironmentModel, context.id.replace /\|/g, '/'
	
	serialize: (router, context) ->
		
		id: context.id.replace /\//g, '|'
	
	connectOutlets: (router, environment) ->
		
		router.get('applicationController').connectOutlet 'nav', 'nav'
		
		router.set 'environmentController.environment', environment
		
		router.get('applicationController').connectOutlet 'footer', 'footer'
		
		router.set 'navController.fluid', true
		router.set 'navController.selected', 'environment'
		
		undefined
		
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			router.set 'environmentController.currentProject', project
			
			router.get('applicationController').connectOutlet 'body', 'environment'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.selected', 'environments'
			
			undefined
