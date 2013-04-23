define ["util/vec"], (vec)->
	(height, width, orbit)->
		# set some camera attributes
		VIEW_ANGLE = 45
		ASPECT = width / height
		NEAR = 0.1
		FAR = 100000

		camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR

		camera.update = (t)->
			s = t * 0.1;
			position = orbit(s)
			camera.position = position.clone()
			camera.lookAt orbit(s + 1)
			# console.log target

		camera
