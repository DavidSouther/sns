define ["util/camera", "util/renderer", "game/clock", "util/stats"], (Camera, Renderer, Clock, stats)->
	Stage = (selector)->
		FPS = 60
		$container = $ selector

		prep = ->
			# Resize the stage to the current container bounds
			do size = =>
				@width = $container.width()
				@height = $container.height()
				@aspect = @width / @height

			# Set up the render pipeline
			@camera = Camera @
			@renderer = Renderer @

			$container.on 'resize', resize = =>
				size()
				@camera.resize()
				@renderer.resize()
			$container.trigger 'resize'
			@container = $container[0]

			# Prep the THREE scene, including an update function, for game state
			@scene = new THREE.Scene()
			@scene.update = @scene.update || ->

			clock = Clock()
			# The render loop and render clock
			do update = =>
				if @running
					stats.begin()

					clock.tick()

					@scene.update clock
					@renderer.render()

					stats.end()
				setTimeout (->requestAnimationFrame update), 1000 / FPS

			@start = -> @running = yes
			@stop = -> @running = no

			# attach the render-supplied DOM element
			$container.append @renderer.domElement

			@

		prep.call running: no
