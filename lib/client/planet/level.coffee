define ["game/clock", "util/mechanics/orbit", "planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Clock, Orbit, Geometry, Galaxy, Orbital, Ship)->
		controls = update: ->
		setUp = (stage, base, orbit)->
			scene = stage.scene
			clock = new Clock

			radii = 
				Earth: 1
				Venus: 0.9504
				Mars: 0.5318

			earth = Geometry.Sphere base * radii.Earth, "https://s3.amazonaws.com/sns_assets/planet/textures/earth_day_4k.jpg"
			earth.position = vec 0, 0, 0
			earth.timeScale = 0
			scene.add earth

			# earth.clouds = Geometry.Sphere base * radii.Earth * 1.01,
 
			stage.planets = [earth]
			stage.ships = []

			scene.add new THREE.AmbientLight 0xE0E0E0

			orbital = Orbital orbit, 0, 90 * 60 * 2 * Math.PI, 9 * 6
			scene.add orbital

			scene.addShip = (ship)->
				scene.add ship
				stage.ships.push ship
				# stage.controls?.chase = ship
			# Ship.load scene, orbit

			clock.addEventListener 'tick', (event)->
				clock = event.clock
				(planet.update clock for planet in stage.planets)
				(ship.update clock for ship in stage.ships)

			stage.controls = new THREE.ChaseControls stage.camera, stage.container
			stage.controls.chase = earth

			$ ->
			# 	cf = dat.addFolder "Pause"
			# 	cf.add clock, 'pause'

		play: (selector)->
			stage = new S3age selector

			# BASE = 50
			BASE = 1

			altitude = (1 + 0.062) * BASE
			orbit = Orbit({reference: vec(0, 1, 0).normalize()}, null, Orbit.parts(0.5, altitude, 0.0, 0.0, 0.0))
			stage.camera.position = vec 55, 0, 0

			setUp stage, BASE, orbit

			stage.start()
