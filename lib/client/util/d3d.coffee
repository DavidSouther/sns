window.d3d = selection = (root)->
	_selection = []
	_data = []

	set = (object, path, value)->
		path = path.split('.')
		for i in [0 ... path.length-1]
			object = object[path[i]]
		object[path[i]] = value

	selected =
		enter: ->
			selected
		data: (dataArray)->
			_data = dataArray
			selected

		append: (childType)->
			for dat in _data
				node = d3d.build[childType]()
				root.add(node.child)
				_selection.push({node, dat})
			selected

		attr: (attributes)->
			_selection.forEach (select)->
				for attribute, functor of attributes
					value = if typeof functor is 'function' then functor(select.dat) else functor
					set select.node, attribute, value
			selected

window.d3d.build =
	Sphere: ->
		geo = new THREE.SphereGeometry(0.2, 18, 9)
		mat = new THREE.MeshLambertMaterial()
		child = new THREE.Mesh geo, mat
		sphere = {child}
		Object.defineProperty sphere, 'ambient',
			get: -> mat.ambient
			set: (v)->
				mat.ambient.setHex v
				child
		Object.defineProperty sphere, 'color',
			get: -> mat.color
			set: (v)->
				mat.color.setHex v
				child
		Object.defineProperty sphere, 'position',
			get: -> child.position
			set: (v)->
				child.position = v
				child
		sphere

	PointLight: ->
		new THREE.Object3D
		# light = new THREE.PointLight()
