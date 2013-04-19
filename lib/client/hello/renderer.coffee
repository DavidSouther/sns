define [], ()->
	(height, width)->
		renderer = new THREE.WebGLRenderer()
		# start the renderer
		renderer.setSize width, height
		renderer
