expect = require('chai').expect

Mixin = require 'core/Utility/Mixin'

class MixinTest
	
	@::property_ = 0
	
	constructor: ->
		
		@property_ = 0
		
	property: -> @property_
	setProperty: (@property_) ->

describe 'core/Utility/Mixin', ->
	
	object = {}
	
	Mixin object, MixinTest
	
	it 'should mix class properties into an object', ->
		
		expect(object).to.have.property 'property_'
		expect(object).to.have.property 'property'
		expect(object).to.have.property 'setProperty'

	it 'should give all the class functionality to the object', ->
		
		object.setProperty 69
		
		expect(object.property()).to.equal 69
