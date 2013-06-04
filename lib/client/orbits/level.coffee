define ["util/stage", "util/mechanics/orbit", "util/mechanics/orbital", "orbits/egg"],
	(Stage, Orbit, Orbital, Egg)->
		controls = update: ->
		setUp = (stage, orbits)->
			scene = stage.scene = new THREE.Scene

			height = 0
			for orbit in orbits
				orbital = new THREE.Orbital orbit, orbit.color, height
				scene.add orbital
				height += 0.0001

			Egg.load scene
			scene.add new THREE.AmbientLight 0xE0E0E0
			scene.add new THREE.AxisHelper(0.5)

			stage.controls = new THREE.ChaseControls stage.camera, stage.container
			stage.controls.chase = 
				scale: vec(1, 0, 0)
				position: vec(0, 0, 0)
				computeBoundingSphere: ->
				boundingSphere:
					radius: 2

		play: (selector)->
			stage = new Stage selector

			object = {reference: vec(0, 1, 0).normalize(), position: vec(0, 0, 0)}

			altitude = (1 + 0.062)
			params = Orbit.parts(0.5, altitude, 0.3, 0.0, 0.0)

			orbits = [
				new Orbit(object, null, params)
			]

			do ->
				point0 = orbits[0].closed(0)
				# Take the position of the point at theta = 0, point back to the origin (focus), and scale to length
				# of the semimajor axis. This is the displacement each point around the focus must go through.
				center = point0.clone()

				params = Orbit.fromPoints(
					point0
					orbits[0].closed(Math.PI / 4)
					orbits[0].closed(Math.PI / 2)
					center
				)
				orbits.push new Orbit(object, null, params)
				orbits[1].color = 0x0000FF

			setUp stage, orbits
			stage.start()
