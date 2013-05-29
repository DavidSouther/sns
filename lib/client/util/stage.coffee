define ["util/camera", "util/renderer", "game/clock", "util/control/click", "util/stats"], (Camera, Renderer, Clock, Click, stats)->
	class Stage
		constructor: (selector)->
			FPS = 60
			$container = $ selector
			@running = no

			# Resize the stage to the current container bounds
			do size = =>
				@width = $container.width()
				@height = $container.height()
				@aspect = @width / @height

			# Set up the render pipeline
			@camera = Camera @
			@renderer = Renderer @

			$(window).on 'resize', resize = =>
				size()
				@camera.resize()
				@renderer.resize()
			$container.trigger 'resize'
			@container = $container[0]

			# The render loop and render clock
			do update = =>
				if @running
					stats.begin()

					@controls?.update()
					@renderer.render()

					stats.end()
				setTimeout (->requestAnimationFrame update), 1000 / FPS

			@start = -> @running = yes
			@stop = -> @running = no

			@clicked = (intersects)->
				for intersect in intersects
					intersect.object.onclick? intersect

			# attach the render-supplied DOM element
			$container.append @renderer.domElement
			new Click $container,  @
