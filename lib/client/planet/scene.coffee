define ["util/vec", "planet/geometry"], (vec, Geometry)->
	(camera)->
		scene = new THREE.Scene()

		base = 50
		radii = 
			Earth: 1
			Venus: 0.9504
			Mars: 0.5318

		venus = Geometry.Sphere "planet/textures/ven0aaa2.jpg", base * radii.Venus
		mars = Geometry.Sphere "planet/textures/mar0kuu2.jpg", base * radii.Mars
		earth = Geometry.Sphere "planet/textures/ear0xuu2.jpg", base * radii.Earth

		earth.position = vec 0, 0, 0
		venus.position = vec base * 2.5, 0, 0
		mars.position = vec base * 1.75, 0, base * 1.75

		scene.add venus
		scene.add mars
		scene.add earth

		planets = [earth, mars, venus]

		scene.add camera
		scene.add new THREE.AmbientLight 0xE0E0E0

		scene.update = (t)->
			camera.update t
			(planet.update t for planet in planets)

		scene
