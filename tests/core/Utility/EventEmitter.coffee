assert = require('chai').assert
expect = require('chai').expect

Mixin = require 'core/Utility/Mixin'
EventEmitter = require 'core/Utility/EventEmitter'

describe 'core/Utility/EventEmitter', ->
	
	it 'should implement unqualified events', (next) ->
		
		object = {}
		Mixin object, EventEmitter
		
		object.on 'test', -> next()
		setTimeout (-> object.emit 'test'), 10
		
	it 'should implement namespaced events', (next) ->
		
		object = {}
		Mixin object, EventEmitter
		
		object.on 'test.namespaced', -> assert.fail()
		
		# Removing the namespaced event must leave this one alone.
		object.on 'test', -> next()
		
		# If this is removed, the listener that will fail won't be called.
		object.off '.namespaced'
		
		object.emit 'test'
