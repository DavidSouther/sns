define ["util/stage", "ship/ship"], (Stage, Ship)->
	play: (selector)->
		stage = Stage selector

		sphere = new THREE.Mesh(
			new THREE.SphereGeometry(5),
			new THREE.MeshLambertMaterial(color: 0x00FF00)
		)
		sphere.position = vec 0, 0, 0
		stage.scene.add sphere

		stage.ships = []
		stage.addShip = (ship)->
			stage.ships.push ship
			stage.scene.add ship
		Ship.load stage

		stage.start()
