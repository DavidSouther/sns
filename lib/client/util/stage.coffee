define ["util/camera", "util/renderer", "util/stats"], (Camera, Renderer, stats)->
	Stage = (selector)->
		$container = $ selector

		prep = ->
			do size = =>
				@width = $container.width()
				@height = $container.height()
				@aspect = @width / @height

			$container.on 'resize', resize = =>
				size()
				@camera.resize()
				@renderer.resize()

			@camera = Camera @
			@controls = new THREE.TrackballControls @camera
			@renderer = Renderer @

			@scene = new THREE.Scene()
			@scene.update = @scene.update || ->

			$container.trigger 'resize'

			frame = 0
			clock = new THREE.Clock()
			do update = =>
				requestAnimationFrame update
				
				if @running
					stats.begin()

					tick = 
						delta: clock.getDelta()
						time: clock.getElapsedTime()
						frame: frame += 1

					@scene.update tick
					@controls.update()

					@renderer.render()

					stats.end()

			@start = ->
				@running = yes
			@stop = ->
				@running = no

			# attach the render-supplied DOM element
			$container.append @renderer.domElement

			@

		prep.call running: no
