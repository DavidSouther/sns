define [], ->
	# {UPS} integer Updates per second (interval is 1000 / UPS)
	# {scale} integer number of seconds game time per second real time
	class Clock extends THREE.EventDispatcher
		constructor: (@UPS = 20, @scale = 60)->
			clock = new THREE.Clock()
			paused = false

			@frame = 0
			@delta = 0
			@time = clock.getElapsedTime()

			$ =>
				cf = dat.addFolder 'Clock'
				cf.add @, 'UPS', 1, 60
				cf.add @, 'scale', 1, 360

			tick = =>
				return if paused
				@frame += 1
				@delta = clock.getDelta() * @scale
				@time = clock.getElapsedTime() * @scale

				@dispatchEvent type: 'tick', clock: @

				setTimeout tick, 1000 / @UPS
			tick()

			@pause = ->
				if paused
					paused = false
					clock.start()
					@dispatchEvent type: 'paused', clock: @
					tick()
				else
					paused = true
					clock.stop()
					@dispatchEvent type: 'unpaused', clock: @
