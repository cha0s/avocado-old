## Table of contents

<dl>
	<dt>
		Simply put, SPIs provide an way for the engine to do interesting and
		dynamic things. SPI stands for "Service Provide Interface".
	</dt>
	<dd>
		SPI
		<dl>
			<dt>
				The Core SPI handles framework initialization and teardown as
				well as bridges to core engine functionality like filesystem
				access.
			</dt>
			<dd>
				Core
				<dl>
					<dd><a href="engine/core/CoreService.coffee.html">CoreService</a></dd>
				</dl>
			</dd>
			
			<dt>
				The Graphics SPI handles window and graphics system
				initialization, and rendering.
			</dt>
			<dd>
				Graphics
				<dl>
					<dd><a href="engine/core/Graphics/Image.coffee.html">Image</a></dd>
					<dd><a href="engine/core/Graphics/Window.coffee.html">Window</a></dd>
				</dl>
			</dd>
			
			<dt>
				The Timing SPI handles measuring time.
			</dt>
			<dd>
				Timing
				<dl>
					<dd><a href="engine/core/Timing/TimingService.coffee.html">TimingService</a></dd>
					<dd><a href="engine/core/Timing/Counter.coffee.html">Counter</a></dd>
					<dd><a href="engine/core/Timing/Cps.coffee.html">Cps</a></dd>
					<dd><a href="engine/core/Timing/Ticker.coffee.html">Ticker</a></dd>
				</dl>
			</dd>
			
			<dt>
				The Sound SPI handles loading and playing sound effects and
				music.
			</dt>
			<dd>
				Sound
				<dl>
					<dd><a href="engine/core/Sound/Music.coffee.html">Music</a></dd>
					<dd><a href="engine/core/Sound/Sample.coffee.html">Sample</a></dd>
				</dl>
			</dd>
			
			<dt>
				The Input SPI handles user input polling.
			</dt>
			<dd>
				Input
				<dl>
					<dd><a href="engine/core/Input/Input.coffee.html">Input</a></dd>
				</dl>
			</dd>
		</dl>
	</dd>
	
	<dt>
		Avocado is always in a State, except during the initialization phase,
		and shortly before exiting the engine. States are how you spend your
		time doing things in the Avocado engine.	
	</dt>
	<dd>
		States
		<dl>
			<dd><a href="engine/core/State/AbstractState.coffee.html">AbstractState</a></dd>
			<dd><a href="engine/core/State/Initial.coffee.html">Initial</a></dd>
		</dl>
	</dd>
	
	<dt>
		Miscellaneous utility classes.
	</dt>
	<dd>
		Utilities
		<dl>
			<dd><a href="engine/core/Utility/EventEmitter.coffee.html">EventEmitter</a></dd>
			<dd><a href="engine/core/Utility/Logger.coffee.html">Logger</a></dd>
			<dd><a href="engine/core/Utility/Mixin.coffee.html">Mixin</a></dd>
			<dd><a href="engine/core/Utility/Transition.coffee.html">Transition</a></dd>
			<dd><a href="engine/core/Utility/upon.js.html">upon</a></dd>
		</dl>
	</dd>
	
	<dt>
		More advanced topics. Casual developers beware!	
	</dt>
	<dd>
		Advanced
		<dl>
			<dt>
				Avocado has multiple engine implementations so that it may run
				on multiple platforms.
			</dt>
			<dd>
				Engine implementations
				<dl>
					<dd>
						C++
						<dl>
							<dd><a href="cpp/index.html">Native code documentation</a></dd>
							<dd><a href="engine/main/native/Initialize.coffee.html">Initialization phase</a></dd>
							<dd><a href="engine/main/native/Main.coffee.html">Main loop</a></dd>
							<dd><a href="engine/main/native/Finish.coffee.html">Finishing phase</a></dd>
						</dl>
					</dd>
				</dl>
			</dd>
		</dl>
	</dd>
</dl>
