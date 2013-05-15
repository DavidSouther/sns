define [], -> ->
	clock = new THREE.Clock()

	Clock =
		tick: ->
			Clock.frame += 1
			Clock.delta = clock.getDelta()
			Clock.time = clock.getElapsedTime()
		frame: 0
		delta: 0
		time: clock.getElapsedTime()

	Clock
