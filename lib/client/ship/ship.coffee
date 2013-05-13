define [], ()->
	loader = new THREE.ColladaLoader()
	loader.options.convertUpAxis = true;
	load: (stage, orbit)->
		collada = "ship/frigate/frigate.dae"
		loader.load collada, ( scene )->
			for mesh in scene.scene.children when mesh instanceof THREE.Mesh
				stage.addShip mesh
