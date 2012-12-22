controller = Ember.Controller.extend

	entitiesContent: [
		'Townsperson'
		'Jerk'
		'Smoking chihuahua'
	]
	entitiesSelection: 'Townsperson'
		
controller = controller.create()

view = Ember.View.extend
	
	controller: controller
	
	classNames: ['entities']
	
	template: Ember.Handlebars.compile """

<h3>Entities</h3>
<div class="entities">
	{{view Bootstrap.Forms.Select
		contentBinding="entitiesContent"
		selectionBinding="entitiesSelection"
		labelBinding="entitiesLabel"
	}}
</div>

"""

exports.controls = Ember.Object.create
	title: 'Entities'
	link: 'entities'
	
	controller: controller
	view: view
