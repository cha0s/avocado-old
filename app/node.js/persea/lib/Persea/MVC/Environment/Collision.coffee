controller = Ember.Controller.extend

	collisionContent: [
		'Line from (0, 0) to (32, 32)'
		'Ellipsis at (16, 16) of size (8, 6)'
		'Circle at (24, 16) of radius 3'
		'...'
	]
	collisionSelection: 'Line from (0, 0) to (32, 32)'

controller = controller.create()

view = Ember.View.extend
	
	controller: controller
	
	classNames: ['collision']
	
	template: Ember.Handlebars.compile """

<h3>Collision</h3>
<div class="collision">
	{{view Bootstrap.Forms.Select
		contentBinding="collisionContent"
		selectionBinding="collisionSelection"
		labelBinding="collisionLabel"
	}}
</div>

"""

exports.controls = Ember.Object.create
	title: 'Collision'
	link: 'collision'
	
	controller: controller
	view: view
