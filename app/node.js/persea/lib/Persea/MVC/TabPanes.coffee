Tabs = Bootstrap.Tabs.extend

	itemViewClass: Ember.View.extend(Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport, {
		click: ->
		paneHref: Ember.computed(->
			"[data-tab-pane=\"#{@get('href')}\"]"
		).property('href').cacheable()
		
		template: Ember.Handlebars.compile """

<a data-toggle="tab" {{bindAttr href="view.paneHref"}} >{{view.title}}</a>

"""
	});

TabPane = Ember.View.extend Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport,
	classNames: ['tab-pane']
	attributeBindings: ['data-tab-pane']
	'data-tab-pane': Ember.computed(->
		@get('href')
	).property('href').cacheable()
	
	click: ->
	template: Ember.Handlebars.compile """

{{view view.content.view
	environmentBinding="environment"
}}

"""

TabPanes = exports.View = Ember.View.extend
	
	tabs: Tabs

	paneView: Ember.CollectionView.extend
		classNames: ['tab-content']
		itemViewClass: TabPane
		selection: null

	template: Ember.Handlebars.compile """

{{view view.tabs
	contentBinding="content"
	selectionBinding="selection"
}}

{{view view.paneView
	contentBinding="content"
	selectionBinding="selection"
}}

"""

