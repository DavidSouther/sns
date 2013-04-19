define ["util/vec"], (vec)->
	(height, width)->
		# set some camera attributes
		VIEW_ANGLE = 45
		ASPECT = width / height
		NEAR = 0.1
		FAR = 10000

		camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)

		# the camera starts at 0,0,0 so pull it back
		camera.position.z = 300

		camera.update = (t)->
			s = t * -0.005;
			camera.position.x = 500 * Math.sin s
			camera.position.z = 800 * Math.cos s
			camera.lookAt vec 0, 0, 0

		camera
