define ["planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Geometry, Galaxy, Orbital, Ship)->
		(camera, base, orbit)->
			scene = new THREE.Scene()

			radii = 
				Earth: 1
				Venus: 0.9504
				Mars: 0.5318

			#venus = Geometry.Sphere "planet/textures/ven0aaa2.jpg", base * radii.Venus, 0x00E0E0
			#mars = Geometry.Sphere "planet/textures/mar0kuu2.jpg", base * radii.Mars, 0xE00000
			earth = Geometry.Sphere base * radii.Earth,
				"https://s3.amazonaws.com/sns_assets/planet/textures/earth_day_medium.jpg",
				"https://s3.amazonaws.com/sns_assets/planet/textures/earth_bump.jpg"

			earth.position = vec 0, 0, 0
			#venus.position = vec base * 2.5, 0, 0
			#mars.position = vec base * 1.75, 0, base * 1.75

			#scene.add venus
			#scene.add mars
			scene.add earth
			scene.add Orbital orbit, 0, 2 * Math.PI, 0.01

			planets = [earth]
			ships = []
			scene.addShip = (ship)->
				scene.add ship
				ships.push ship
			Ship.load scene, orbit

			scene.add Galaxy()
			scene.add camera
			scene.add new THREE.AmbientLight 0xE0E0E0
			# sun = new THREE.PointLight 0xFFFFDD, 10
			# sun.position = vec 100, 0, 0
			# scene.add sun

			scene.update = (t)->
				camera.update t
				(planet.update t for planet in planets)
				(ship.update t for ship in ships)

			scene
