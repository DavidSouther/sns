define [], ()->
	loader = new THREE.JSONLoader();
	load: (scene, orbit)->
		loader.load "ship/ship.json", (geometry, materials)->
			ship = new THREE.Mesh geometry, new THREE.MeshFaceMaterial(materials)
			# ship = new THREE.Mesh geometry, new THREE.MeshBasicMaterial color: 0xFF0000

			ship.position = vec 0, 0, 0
			ship.scale.set 1

			ship.update = (t)->
				s = t * 0.1
				ship.position = orbit(s)

			scene.addShip ship
