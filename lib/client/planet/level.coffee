define ["util/stage", "game/clock", "util/mechanics/orbit", "planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Stage, Clock, Orbit, Geometry, Galaxy, Orbital, Ship)->
		controls = update: ->
		setUp = (stage, base, orbit)->
			scene = stage.scene = new THREE.Scene
			clock = new Clock

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
			orbital = Orbital orbit, 0, 90 * 60 * 2 * Math.PI, 9 * 6
			scene.add orbital.dots
			scene.add orbital.line

			scene.addShip = (ship)->
				scene.add ship
				stage.ships.push ship
				stage.controls?.chase = ship
			Ship.load scene, orbit

			clock.addEventListener 'tick', (event)->
				clock = event.clock
				(planet.update clock for planet in stage.planets)
				(ship.update clock for ship in stage.ships)

			stage.controls = new THREE.ChaseControls stage.camera, stage.container

			$ ->
				cf = dat.addFolder "Follow"
				follow =
					ship: -> stage.controls?.chase = stage.ships[0]
					earth: -> stage.controls?.chase = earth
				cf.add follow, 'ship'
				cf.add follow, 'earth'
				cf = dat.addFolder "Pause"
				cf.add clock, 'pause'

		play: (selector)->
			stage = Stage selector

			BASE = 50

			altitude = (1 + 0.062) * BASE
			orbit = Orbit({reference: vec(1, 0, 0)}, null, Orbit.parts(0.4, altitude, 0.2, 0.5, 0.1))
			stage.camera.position = vec 55, 0, 0

			setUp stage, BASE, orbit

			stage.start()
