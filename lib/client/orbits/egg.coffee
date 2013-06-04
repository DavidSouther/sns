define [], ->
	loader = new THREE.ColladaLoader()
	loader.options.convertUpAxis = yes
	wireframe = new THREE.MeshBasicMaterial wireframe: yes, color: 0x4A4A4A
	load: (stage, cb=->)->
		collada = "orbits/egg.dae"
		loader.load collada, ( dae )->
			meshes = []
			for mesh in dae.scene.children when mesh instanceof THREE.Mesh
				mesh.material = wireframe
				meshes.push mesh
			while mesh = meshes.pop()
				stage.add mesh
