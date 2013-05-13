define [], ()->
	loader = new THREE.ColladaLoader()
	loader.options.convertUpAxis = true;
	load: (stage, orbit)->
		collada = "ship/frigate/frigate.dae"
		loader.load collada, ( scene )->
			for mesh in scene.scene.children when mesh instanceof THREE.Mesh
				do (mesh)->
					mesh.scale = vec 0.01, 0.01, 0.01
					mesh.update = (t)->
						position = orbit(t.time * 0.1)
						velocity = orbit((t.time + t.delta) * 0.1)
						mesh.position = position
						mesh.rotation = velocity.sub(mesh.position).normalize()
						mesh.up = mesh.position.clone().normalize().negate()
				stage.addShip mesh
