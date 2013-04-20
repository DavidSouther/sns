define [], ()->
	->
		urls = [
			"planet/textures/sky/pos-x.png"
			"planet/textures/sky/pos-y.png"
			"planet/textures/sky/neg-x.png"
			"planet/textures/sky/neg-y.png"

			"planet/textures/sky/pos-z.png"
			"planet/textures/sky/neg-z.png"
		]

		cubemap = THREE.ImageUtils.loadTextureCube urls
		cubemap.format = THREE.RGBFormat
		material = new THREE.MeshLambertMaterial color: 0xffffff, envMap: cubemap

		skybox = new THREE.Mesh new THREE.CubeGeometry( 10000, 10000, 10000 ), material
		skybox.flipSided = true

		skybox
