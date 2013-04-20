define ["util/vec"], (vec)->
	Sphere: (texture, radius, atmo)->
		# set up the sphere vars
		segments = 16 * 6
		rings = 16 * 2

		planet = new THREE.Object3D()

		surfaceMaterial = new THREE.MeshPhongMaterial map: THREE.ImageUtils.loadTexture texture
		surface = new THREE.Mesh new THREE.SphereGeometry(radius, segments, rings), surfaceMaterial

		atmoMaterial = new THREE.MeshNormalMaterial color: atmo, opacity: 0.1
		atmo = new THREE.Mesh new THREE.SphereGeometry(radius * 1.1, segments, rings), atmoMaterial

		planet.add atmo
		planet.add surface

		planet.update = (t)->
			s = 0.005 * t
			surface.rotation = vec 0, s, 0

		planet
