define ["text!hello/vertex.glsl", "text!hello/fragment.glsl"], (vertex, fragment)->
	(attributes)->
		# create the sphere's material
		sphereMaterial = new THREE.ShaderMaterial vertexShader: vertex, fragmentShader: fragment, attributes: attributes