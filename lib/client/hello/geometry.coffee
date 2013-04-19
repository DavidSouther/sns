define ["hello/material"], (Material)->
	Sphere: ->
		# set up the sphere vars
		radius = 50
		tube = radius / 10
		segments = 16 * 6
		rings = 16 * 2

		attributes =
			displacement:
				type: 'f'
				value: []


		sphereMaterial = Material attributes

		# create a new mesh with sphere geometry -
		# we will cover the sphereMaterial next!
		sphere = new THREE.Mesh new THREE.TorusKnotGeometry(radius, tube, segments, rings), sphereMaterial

		attributes.displacement.value = (Math.random() * 30 for vert in sphere.geometry.vertices)

		sphere.update = (t)->

		sphere
