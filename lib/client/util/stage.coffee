define ["util/camera", "util/renderer", "util/stats"], (Camera, Renderer, stats)->
	Stage = (selector)->
		$container = $ selector

		prep = ->
			# Resize the stage to the current container bounds
			do size = =>
				@width = $container.width()
				@height = $container.height()
				@aspect = @width / @height

			# Set up the render pipeline
			@camera = Camera @
			# @controls = new THREE.TrackballControls @camera
			@renderer = Renderer @

			$container.on 'resize', resize = =>
				size()
				@camera.resize()
				@renderer.resize()
			$container.trigger 'resize'

			# Prep the THREE scene, including an update function, for game state
			@scene = new THREE.Scene()
			@scene.update = @scene.update || ->

			window.debug = false

			frame = 0
			clock = new THREE.Clock()
			# The render loop and render clock
			do update = =>
				if @running
					stats.begin()

					tick = 
						delta: clock.getDelta()
						time: clock.getElapsedTime()
						frame: frame += 1

					if window.debug
						console.log "Frame #{frame}..."
						findNaN @scene
						console.log "Frame clean entering..."

					@scene.update tick
					# @controls.update()
					@renderer.render()

					if window.debug
						findNaN @scene
						console.log "Frame clean exiting."

					stats.end()
				requestAnimationFrame update

			@start = -> @running = yes
			@stop = -> @running = no

			# attach the render-supplied DOM element
			$container.append @renderer.domElement

			@

		prep.call running: no
