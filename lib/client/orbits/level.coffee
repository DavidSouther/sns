define ["util/stats", "util/mechanics/orbit", "util/mechanics/orbital", "orbits/egg"],
	(stats, Orbit, Orbital, Egg)->
		window.stats = stats # Make global for S3age
		controls = update: ->
		setUp = (stage, orbits)->
			scene = stage.scene

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
			stage = new S3age selector

			object = {reference: vec(0, 1, 0).normalize(), position: vec(0, 0, 0)}

			altitude = (1 + 0.062)
			params = Orbit.parts(0.5, altitude, 0.3, 0.0, 0.0)
			params = Orbit.parts(0.1, altitude, 0.0, 0.0, 0.0)

			orbits = [
				new Orbit(object, null, params)
			]

			do ->
				params = Orbit.fromPoints(
					orbits[0].closed(0)
					orbits[0].closed(Math.PI / 8)
					orbits[0].closed(Math.PI / 4)
					vec(0, 0, 0)

				orbits.push new Orbit(object, null, params)
				orbits[1].color = 0x0000FF

			setUp stage, orbits
			stage.start()
