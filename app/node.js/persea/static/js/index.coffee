CoreService = require 'main/web/Bindings/CoreService'
NetworkConfig = 'core/Config/Network'
Timing = require 'Timing'

# SPI proxies.
require 'core/proxySpiis'

timeCounter = new Timing.Counter()
setInterval(
	-> Timing.TimingService.setElapsed timeCounter.current() / 1000
	25
)

CoreService.ResourcePath = ''

ember = require 'Persea/ember'

mvcs = [
	'Footer', 'Home', 'Nav'
	
	'Environment', 'Environments'
	'Project', 'Projects'
	'Tileset', 'Tilesets'
]

app =

	ApplicationView: Ember.View.extend
	
		template: Ember.Handlebars.compile """

{{outlet nav}}
{{outlet body}}
{{outlet footer}}

"""
	
	ApplicationController: Ember.Controller.extend()
	
ember.mixinMvc app, mixin for mixin in mvcs

router =
	
	actions:
		
		enableLogging: false
		
	routes:

		goToHome:  Ember.Route.transitionTo 'root.index'
		index: Ember.Route.extend
			route: '/'
			connectOutlets: (router, context) ->
				
				router.get('applicationController').connectOutlet 'nav', 'nav'
				router.get('applicationController').connectOutlet 'body', 'home'
				router.get('applicationController').connectOutlet 'footer', 'footer'
				
				router.set 'navController.selected', 'home'
				router.set 'navController.fluid', false
		
ember.mixinRouter router, mixin for mixin in mvcs

actions = router.actions
actions.root = Ember.Route.extend router.routes
router = actions

app.Router = Ember.Router.extend router

window.App = Ember.Application.create app

somber = require 'Persea/somber-client'

App.store = DS.Store.create
	revision: 11

	adapter: somber.Adapter.create
		
		socket: io.connect NetworkConfig.host
	
###	
	adapter: DS.FixtureAdapter.create
		simulateRemoteResponse: true
		latency: 10
###

DS.JSONTransforms.serialized =
	
	deserialize: (serialized) ->
		
		if Ember.isNone serialized
			null
		else
			JSON.stringify serialized
		
	serialize: (deserialized) ->
		
		if Ember.isNone deserialized
			null
		else
			JSON.parse deserialized

DS.JSONTransforms.passthru =
	
	deserialize: (serialized) ->
		
		serialized
		
	serialize: (deserialized) ->
		
		deserialized

ember.mixinModels App, [
	'Environment'
	'Project'
	'Tileset'
]

(($) ->
	
) jQuery

App.initialize()

adapter = App.store.get 'adapter'
