define ["util/stage", "starmap/map"],
	(Stage, Map)->
		play: (selector)->
			stage = new Stage selector
			scene = stage.scene

			scene.add new THREE.AmbientLight 0xE0E0E0
			scene.add axis = new THREE.AxisHelper(0.5)

			Map scene

			stage.controls = new THREE.ChaseControls stage.camera, stage.container
			stage.controls.chase = 
				scale: vec(1, 0, 0)
				position: vec(0, 0, 0)
				computeBoundingSphere: ->
				boundingSphere:
					radius: 2

			stage.start()
