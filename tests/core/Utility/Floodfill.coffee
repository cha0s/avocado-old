assert = require('chai').assert
expect = require('chai').expect

Floodfill = require 'core/Utility/Floodfill'

grid = []

GridFloodfill = class extends Floodfill
	
	value: (x, y) -> grid[y * 5 + x]
	
	setValue: (x, y, value) -> grid[y * 5 + x] = value

describe 'core/Utility/Floodfill', ->
	
	it 'should do simple floodfilling', ->
		
		grid = [
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
			1, 1, 1, 1, 1
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
		
		floodfill = new GridFloodfill(
			[5, 5]
			[1, 1]
		)
		floodfill.fillAt 0, 0, 1
		
		expect(grid).to.deep.equal [
			1, 1, 1, 1, 1
			1, 1, 1, 1, 1
			1, 1, 1, 1, 1
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
		
	it 'should not fill diagonally', ->
		
		grid = [
			0, 0, 0, 0, 0
			0, 0, 1, 0, 0
			1, 1, 0, 1, 1
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
		
		floodfill = new GridFloodfill(
			[5, 5]
			[1, 1]
		)
		floodfill.fillAt 0, 0, 1
		
		expect(grid).to.deep.equal [
			1, 1, 1, 1, 1
			1, 1, 1, 1, 1
			1, 1, 0, 1, 1
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
		
	it 'should nop if it is the same value', ->
		
		grid = [
			1, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
		
		floodfill = new GridFloodfill(
			[5, 5]
			[1, 1]
		)
		floodfill.fillAt 0, 0, 1
		
		expect(grid).to.deep.equal [
			1, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
			0, 0, 0, 0, 0
		]
