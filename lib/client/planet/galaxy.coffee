define [], ()->
	->
		urls = [
			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0001.png"
			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0003.png"

			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0006.png"
			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0005.png"

			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0002.png"
			"https://s3.amazonaws.com/sns_assets/planet/textures/sky/0004.png"

		]

		cubemap = THREE.ImageUtils.loadTextureCube urls
		cubemap.format = THREE.RGBFormat
		material = new THREE.MeshLambertMaterial color: 0xffffff, envMap: cubemap

		skybox = new THREE.Mesh new THREE.CubeGeometry( 10000, 10000, 10000 ), material
		skybox.flipSided = true
		skybox.name = "skybox_#{skybox.id}"

		skybox
