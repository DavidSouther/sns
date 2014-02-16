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
					position = new THREE.Vector3
					velocity = new THREE.Vector3

					mesh.update = (clock)->
						time = clock.now
						delta = clock.delta
						tA = orbit.trueAnomalyAt time
						tAD = orbit.trueAnomalyAt time + delta
						mesh.position.fromArray orbit.positionAtTrueAnomaly tA
						velocity.fromArray orbit.positionAtTrueAnomaly tAD

						# Point the top of the ship back at the planet
						mesh.up = mesh.position.clone().normalize().negate()

						# Given the position and orientation, look at the next point in the orbit
						mat.lookAt mesh.position, velocity, mesh.up
						mesh.quaternion.setFromRotationMatrix mat

					stage.addShip mesh
