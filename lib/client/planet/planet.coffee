define ["util/camera", "util/renderer", "planet/scene"], (Camera, Renderer, Scene)->
	render: (selector)->
		$container = $ selector

		# set the scene size
		WIDTH = $container.width()
		HEIGHT = $container.height()
		BASE = 50

		camera = Camera HEIGHT, WIDTH, BASE
		renderer = Renderer HEIGHT, WIDTH
		scene = Scene camera, BASE

		# attach the render-supplied DOM element
		$container.append renderer.domElement

		clock = new THREE.Clock()
		do update = ()->
			requestAnimationFrame update
			t = clock.getElapsedTime()
			scene.update t
			# draw!
			renderer.render scene, camera
