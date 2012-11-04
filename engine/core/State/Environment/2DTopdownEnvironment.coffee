
Box2D = require 'core/Physics/Box2D'
EnvironmentState = require 'core/State/Environment'
Timing = require 'Timing'

module.exports = class extends EnvironmentState
	
	enter: (args) ->
		
		@world = new Box2D.b2World new Box2D.b2Vec2(0, 0), false
		
		super args
			
	tick: ->
		
		if world = @world
			
			world.Step 1 / Timing.ticksPerSecondTarget, 8, 3
