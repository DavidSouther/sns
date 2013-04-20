define ["util/vec"], (vec)->
	(height, width, base = 10)->
		# set some camera attributes
		VIEW_ANGLE = 45
		ASPECT = width / height
		NEAR = 0.1
		FAR = 100000

		camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR

		altitude = (1 + 0.062) * base

		camera.update = (t)->
			s = t * -0.0005;
			camera.position.x = altitude * Math.cos s
			camera.position.z = altitude * Math.sin s
			camera.rotation = vec 0, -s + 0.4, 0

		camera
