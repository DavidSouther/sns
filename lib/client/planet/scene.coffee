define ["util/vec", "planet/geometry", "planet/galaxy"], (vec, Geometry, Galaxy)->
	(camera)->
		scene = new THREE.Scene()

		base = 50
		radii = 
			Earth: 1
			Venus: 0.9504
			Mars: 0.5318

		venus = Geometry.Sphere "planet/textures/ven0aaa2.jpg", base * radii.Venus, 0x00E0E0
		mars = Geometry.Sphere "planet/textures/mar0kuu2.jpg", base * radii.Mars, 0xE00000
		earth = Geometry.Sphere "planet/textures/ear0xuu2.jpg", base * radii.Earth, 0x0000EE

		earth.position = vec 0, 0, 0
		venus.position = vec base * 2.5, 0, 0
		mars.position = vec base * 1.75, 0, base * 1.75

		scene.add venus
		scene.add mars
		scene.add earth

		planets = [earth, mars, venus]

		scene.add Galaxy()
		scene.add camera
		scene.add new THREE.AmbientLight 0xE0E0E0

		scene.update = (t)->
			camera.update t
			(planet.update t for planet in planets)

		scene
