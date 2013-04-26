define ["util/stage", "ship/ship"], (Stage, Ship)->
	play: (selector)->
		stage = Stage selector

		stage.scene.add new THREE.AmbientLight 0x303030
		light = new THREE.PointLight 0xF0F0F0, 1, 100
		light.position = vec 50, 50, 50
		stage.scene.add light

		stage.camera.position = vec 0, 0, 20
		stage.camera.lookAt vec 0, 0, 0

		sphere = new THREE.Mesh(
			new THREE.SphereGeometry(5),
			new THREE.MeshLambertMaterial color: 0x00FF00
		)
		sphere.position = vec 10, 0, 0
		stage.scene.add sphere

		stage.ships = []
		stage.addShip = (ship)->
			stage.ships.push ship
			stage.scene.add ship
		Ship.load stage

		stage.start()
