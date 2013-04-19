define ["hello/geometry"], (Geometry)->
	(camera)->
		scene = new THREE.Scene()

		sphere = Geometry.Sphere()

		scene.add sphere
		scene.add camera


		scene.update = (t)->
			camera.update t
			sphere.update t

		scene
