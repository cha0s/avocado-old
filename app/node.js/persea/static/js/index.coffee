Timing = require 'Timing'

# SPI proxies.
require 'core/proxySpiis'

timeCounter = new Timing.Counter()
setInterval(
	-> Timing.TimingService.setElapsed timeCounter.current() / 1000
	25
)

ember = require 'Persea/ember'

mvcs = [
	'Footer', 'Home', 'Nav'
	
	'Environment', 'Environments'
	'Project', 'Projects'
	'Tileset'
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
		
		testing: 69
#		enableLogging: true
		
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

App.store = DS.Store.create
	revision: 10
	
	adapter: DS.FixtureAdapter.create
		simulateRemoteResponse: true
		latency: 50
		
#	adapter: DS.fixtureAdapter

ember.mixinApp App, mixin for mixin in mvcs

(($) ->
	
) jQuery

App.initialize()
















