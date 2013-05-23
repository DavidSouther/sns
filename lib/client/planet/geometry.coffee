define [], ()->
	Sphere: (radius, texture, bump, clouds)->
		# set up the sphere vars
		segments = 16 * 6
		rings = 16 * 4

		planet = new THREE.Object3D()

		surfaceMaterial = new THREE.MeshPhongMaterial map: THREE.ImageUtils.loadTexture texture
		surfaceMaterial.bumpMap = THREE.ImageUtils.loadTexture bump unless not bump
		surface = new THREE.Mesh new THREE.SphereGeometry(radius, segments, rings), surfaceMaterial

		planet.add surface
		planet.computeBoundingSphere = ->
		planet.boundingSphere = {radius}

		planet.timeScale = 15

		planet.update = (t)->
			s = t.time
			# The planet must go from 0 to 2PI in 24 * 60 * 60 game-time seconds
			# q = (2 * Math.PI) / (24 * 60 * 60)
			q = 0.0000727220521664304
			s = s * q * planet.timeScale

			planet.rotation = vec 0, s, 0

		planet

