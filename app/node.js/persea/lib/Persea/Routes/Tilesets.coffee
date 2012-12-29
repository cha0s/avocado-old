
Tileset = require 'Persea/Routes/Tileset'

exports.Controller = Ember.ArrayController.extend
	sortProperties: ['name']

exports.View = Ember.View.extend

	template: Ember.Handlebars.compile """

<div id="environment-list" class="container">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{currentProject.name}}</a> <span class="divider">/</span></li>
		<li class="active">Tilesets</li>
	</ul>

	<h1>{{currentProject.name}}'s Tilesets</h1>
	
	{{#each controller}}
		<div class="row">
			<a class="media span6" {{action goToProjectTileset this href=true}} >
			    <img class="pull-left media-object" src="http://placekitten.com/g/64/64">
			    <div class="media-body">
				    <h4 class="media-heading">{{name}} <small>{{fetching}}</small></h4>
				    {{#unless fetching}}
				    	<p>{{description}}</p>
				    {{/unless}}
			    </div>
			</a>
		</div>
	{{/each}}
	
</div>

"""

exports.Route = Ember.Route.extend
	
	goToProjectTileset: Ember.Route.transitionTo 'tileset.index'
	
	route: '/tilesets'
	
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			
			router.set 'tilesetsController.currentProject', project
			router.set 'tilesetsController.content', project.get 'tilesets'
			router.get('applicationController').connectOutlet 'body', 'tilesets'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.fluid', false
			router.set 'footerController.fluid', false
			
			router.set 'navController.selected', 'tilesets'
			
			undefined

	tileset: Tileset.Route