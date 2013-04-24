define [], ()->
	Sphere: (radius, texture, bump, clouds)->
		# set up the sphere vars
		segments = 16 * 6
		rings = 16 * 4

		planet = new THREE.Object3D()

		surfaceMaterial = new THREE.MeshPhongMaterial map: THREE.ImageUtils.loadTexture texture
		surfaceMaterial.bumpMap = THREE.ImageUtils.loadTexture bump unless not bump
		surface = new THREE.Mesh new THREE.SphereGeometry(radius, segments, rings), surfaceMaterial

		cloudMaterial = new THREE.MeshPhongMaterial color: 0xFFFFFF

		planet.add surface

		planet.update = (t)->
			s = 0.06 * t
			surface.rotation = vec 0, s, 0

		planet

