define [], ()->
	(stage)->
		# set some camera attributes
		VIEW_ANGLE = 45
		NEAR = 0.1
		FAR = 10000

		FOV = 300

		camera = new THREE.PerspectiveCamera VIEW_ANGLE, stage.aspect, NEAR, FAR
		# camera = new THREE.OrthographicCamera window.innerWidth / -FOV, window.innerWidth / FOV, window.innerHeight / FOV, window.innerHeight / -FOV, 0, FOV

		camera.resize = ->
			camera.aspect = stage.aspect
			camera.updateProjectionMatrix()

		camera
