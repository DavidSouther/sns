define [], ->
	# {UPS} integer Updates per second (interval is 1000 / UPS)
	# {sclae} integer number of seconds game time per second real time
	class Clock extends THREE.EventDispatcher
		constructor: (UPS = 20, scale = 60)->
			clock = new THREE.Clock()

			@frame = 0
			@delta = 0
			@time = clock.getElapsedTime()
			@scale = (newScale)-> scale = newScale

			tick = =>
				@frame += 1
				@delta = clock.getDelta() * scale
				@time = clock.getElapsedTime() * scale

				@dispatchEvent type: 'tick', clock: @

			setInterval tick, 1000 / UPS

	# Clock:: = Object.create THREE.EventDispatcher::
	# Clock
