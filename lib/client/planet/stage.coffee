define ["util/stage", "util/mechanics/orbit", "planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Stage, Orbit, Geometry, Galaxy, Orbital, Ship)->
		controls = update: ->
		setUp = (stage, base, orbit)->
			scene = stage.scene

			radii = 
				Earth: 1
				Venus: 0.9504
				Mars: 0.5318

			earth = Geometry.Sphere base * radii.Earth, "https://s3.amazonaws.com/sns_assets/planet/textures/earth_day_medium.jpg", "https://s3.amazonaws.com/sns_assets/planet/textures/earth_bump.jpg"
			earth.position = vec 0, 0, 0
			scene.add earth

			stage.planets = [earth]
			stage.ships = []

			scene.add Galaxy()
			scene.add new THREE.AmbientLight 0xE0E0E0
			scene.add Orbital orbit, 0, 2 * Math.PI, 0.01

			scene.addShip = (ship)->
				scene.add ship
				stage.ships.push ship
				controls.chase = ship
			Ship.load scene, orbit

			scene.update = (t)->
				stage.camera.update t
				(planet.update t for planet in stage.planets)
				(ship.update t for ship in stage.ships)

			controls = new THREE.ChaseControls stage.camera, stage.container

		play: (selector)->
			stage = Stage selector

			BASE = 50

			altitude = (1 + 0.062) * BASE
			orbit = Orbit({reference: vec(1, 0, 0)}, null, Orbit.parts(0.4, altitude, 0.2, 0.5, 0.1))

			update = (t)->
				controls.update()
			stage.camera.update = _(update).bind stage.camera

			setUp stage, BASE, orbit

			stage.start()
