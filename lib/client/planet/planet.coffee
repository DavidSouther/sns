define ["util/camera", "util/renderer", "util/vec", "util/orbit", "planet/scene"], (Camera, Renderer, vec, Orbit, Scene)->
	render: (selector)->
		$container = $ selector

		# set the scene size
		WIDTH = $container.width()
		HEIGHT = $container.height()
		BASE = 50

		altitude = (1 + 0.062) * BASE
		orbit = Orbit({reference: vec(1, 0, 0)}, null, Orbit.parts(0.4, altitude, 0.2, 0.5, 0.1))

		camera = Camera HEIGHT, WIDTH, orbit
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
