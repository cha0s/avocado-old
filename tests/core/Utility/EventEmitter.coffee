assert = require('chai').assert
expect = require('chai').expect

upon = require 'core/Utility/upon'
Mixin = require 'core/Utility/Mixin'
EventEmitter = require 'core/Utility/EventEmitter'

describe 'core/Utility/EventEmitter', ->
	
	it 'should implement events', (next) ->
		
		object = {}
		Mixin object, EventEmitter
		
		object.on 'test', -> next()
		
		cb = -> assert.ok false, 'test2'
		object.on 'test2', cb
		object.off 'test2', cb
		object.emit 'test2'

		setTimeout (-> object.emit 'test'), 10
		
	it 'should implement named events', ->
		
		object = {}
		Mixin object, EventEmitter
		
		object.on 'test.namespaced', -> assert.fail()
		object.on 'test', -> assert.fail()
		
		object.off 'test'
		
		object.emit 'test'

	it 'should implement locally namespaced events', (next) ->
		
		object = {}
		Mixin object, EventEmitter
		
		object.on 'test.namespaced', -> assert.ok false, 'test.namespaced'
		object.on 'test', -> next()
		
		object.off 'test.namespaced'
		
		object.emit 'test'

	it 'should implement globally namespaced events', (next) ->
		
		object = {}
		Mixin object, EventEmitter
		
		testDefer = upon.defer()
		test2Defer = upon.defer()
		
		object.on 'test.namespaced', -> assert.ok false, 'test.namespaced'
		object.on 'test', -> testDefer.resolve()
		
		object.on 'test2.namespaced', -> assert.ok false, 'test2.namespaced'
		object.on 'test2', -> test2Defer.resolve()
		
		object.off '.namespaced'
		
		object.emit 'test'
		object.emit 'test2'
		
		upon.all([
			testDefer
			test2Defer
		]).then -> next()
