define [], ()->
	(stage)->
		# set some camera attributes
		VIEW_ANGLE = 45
		NEAR = 0.1
		FAR = 10000

		camera = new THREE.PerspectiveCamera VIEW_ANGLE, stage.aspect, NEAR, FAR
		camera.resize = ->
			camera.aspect = stage.aspect
			camera.updateProjectionMatrix()

		camera
