define ["util/vec"], (vec)->
	Sphere: (texture, radius)->
		# set up the sphere vars
		segments = 16 * 6
		rings = 16 * 2

		sphereMaterial = new THREE.MeshPhongMaterial
			map: THREE.ImageUtils.loadTexture texture

		# create a new mesh with sphere geometry -
		# we will cover the sphereMaterial next!
		sphere = new THREE.Mesh new THREE.SphereGeometry(radius, segments, rings), sphereMaterial

		sphere.update = (t)->
			s = 0.005 * t
			sphere.rotation = vec 0, s, 0

		sphere
