define [], ()->
	loader = new THREE.ColladaLoader()
	loader.options.convertUpAxis = true;
	load: (stage, orbit, ship = "frigate")->
		collada = "ship/#{ship}/#{ship}.dae"
		loader.load collada, ( scene )->
			for mesh in scene.scene.children when mesh instanceof THREE.Mesh
				do (mesh)->
					mat = new THREE.Matrix4()
					mesh.scale = vec 0.01, 0.01, 0.01

					mesh.update = (t)->
						position = orbit(t.time * 0.1)
						velocity = orbit((t.time + t.delta) * 0.1)
						mesh.position = position

						# Point the top of the ship back at the planet
						mesh.up = mesh.position.clone().normalize().negate()

						# Given the position and orientation, look at the next point in the orbit
						mat.lookAt mesh.position, velocity, mesh.up
						mesh.quaternion.setFromRotationMatrix mat

					stage.addShip mesh
