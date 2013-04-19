define ["util/camera", "util/renderer", "planet/scene"], (Camera, Renderer, Scene)->
	render: (selector)->
		$container = $ selector

		# set the scene size
		WIDTH = $container.width()
		HEIGHT = $container.height()

		camera = Camera HEIGHT, WIDTH
		renderer = Renderer HEIGHT, WIDTH
		scene = Scene camera

		# attach the render-supplied DOM element
		$container.append renderer.domElement

		frame = 0
		do update = ()->
			requestAnimationFrame update
			frame += 1
			scene.update frame
			# draw!
			renderer.render scene, camera