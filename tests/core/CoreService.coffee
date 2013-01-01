expect = require('chai').expect

CoreService = require('Core').CoreService

describe 'CoreService', ->
	
	reference = '{"foo": "bar", "baz": [0, 1, 2, 3]}'
	
	describe '#readResource()', ->
		
		it 'should read a resource file', (next) ->
			
			CoreService.readResource('/CoreService.test.json').then (resource) ->
				
				expect(resource).to.equal reference
				
				next()
				
	describe '#readJsonResource()', ->
		
		it 'should parse a JSON resource file', (next) ->
			
			CoreService.readJsonResource('/CoreService.test.json').then (resource) ->
				
				expect(resource).to.deep.equal JSON.parse reference
				
				next()
				
			
