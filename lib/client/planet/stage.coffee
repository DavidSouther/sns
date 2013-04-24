define ["util/stage", "util/mechanics/orbit", "planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Stage, Orbit, Geometry, Galaxy, Orbital, Ship)->
		setUp = (stage, base, orbit)->
			scene = stage.scene

			radii = 
				Earth: 1
				Venus: 0.9504
				Mars: 0.5318

			#venus = Geometry.Sphere "planet/textures/ven0aaa2.jpg", base * radii.Venus, 0x00E0E0
			#mars = Geometry.Sphere "planet/textures/mar0kuu2.jpg", base * radii.Mars, 0xE00000
			earth = Geometry.Sphere base * radii.Earth, "https://s3.amazonaws.com/sns_assets/planet/textures/earth_day_medium.jpg", "https://s3.amazonaws.com/sns_assets/planet/textures/earth_bump.jpg"

			earth.position = vec 0, 0, 0
			#venus.position = vec base * 2.5, 0, 0
			#mars.position = vec base * 1.75, 0, base * 1.75

			#scene.add venus
			#scene.add mars
			scene.add earth
			scene.add Orbital orbit, 0, 2 * Math.PI, 0.01

			stage.planets = [earth]
			stage.ships = []

			scene.add Galaxy()
			scene.add new THREE.AmbientLight 0xE0E0E0

			scene.update = (t)->
				stage.camera.update t
				(planet.update t for planet in stage.planets)
				(ship.update t for ship in stage.ships)

		play: (selector)->
			stage = Stage selector

			BASE = 50

			altitude = (1 + 0.062) * BASE
			orbit = Orbit({reference: vec(1, 0, 0)}, null, Orbit.parts(0.4, altitude, 0.2, 0.5, 0.1))

			update = (t)->
				s = t * 0.1;
				position = orbit(s)
				velocity = orbit(s + 0.1)
				normal = position.clone().cross(velocity).multiplyScalar(2)
				@position = position.clone().add(normal)
				@lookAt position
			stage.camera.update = _(update).bind stage.camera

			setUp stage, BASE, orbit

			stage.start()
