View = exports.View = Ember.CollectionView.extend
	classNames: ['nav']
	tagName: 'ul'

	itemViewClass: Ember.View.extend(Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport, {

		template: Ember.Handlebars.compile """

{{#if view.content.noLink}}
	{{#if view.content.text}}
		<p class="navbar-text" {{bindAttr id="view.content.id"}} >{{view.content.text}}</p>
	{{else}}
		<p class="navbar-text">{{view.content}}</p>
	{{/if}}
{{else}}
	{{#if view.content.text}}
		<a {{bindAttr title="view.content.title"}} {{bindAttr href="javascript:void(0)"}} {{bindAttr id="view.content.id"}} >
			{{#if view.content.i}}
				<i {{bindAttr class="view.content.i"}} ></i>		
			{{/if}}
			{{view.content.text}}
		</a>
	{{else}}
		<a {{bindAttr title="view.content.title"}} {{bindAttr href="javascript:void(0)"}} >
			{{#if view.content.i}}
				<i {{bindAttr class="view.content.i"}} ></i>
			{{else}}		
				{{view.content}}
			{{/if}}
		</a>
	{{/if}}
{{/if}}

"""

		click: (event) ->
			
			# Only care about links.
			return false unless $('a', event.currentTarget).length > 0
			
			@_super event
			
		mouseDown: (event) ->
			
			return unless Modernizr.touch
			
			@click event
			
			false
			
	})

