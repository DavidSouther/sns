define ["util/stage", "ship/ship"], (Stage, Ship)->
	play: (selector)->
		stage = Stage selector

		stage.scene.add new THREE.AmbientLight 0x303030
		light = new THREE.PointLight 0xF0F0F0, 1, 100
		light.position = vec 50, 50, 50
		stage.scene.add light

		stage.camera.position = vec 0, 2, 5
		stage.camera.lookAt vec 0, 0, 0

		stage.ships = []
		stage.addShip = (ship)->
			stage.ships.push ship
			stage.scene.add ship
			stage.start()
		Ship.load stage
