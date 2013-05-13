m4p = (i)->
	"n#{Math.floor(i/4) + 1}#{(i % 4) + 1}"

matrixNaN = ->
	for i, n of @elements
		if +i >= 0 and isNaN n
			throw "#{m4p i} is NaN"
	return

vectorNaN = ->
	for r in ["x", "y", "z", "w"]
		if @[r] and isNaN @[r]
			throw "#{r} is NaN"
	return

faceNaN = ->
	try
		@normal.findNaN()
	catch e
		throw "normal has #{e}"
	@vertexNormals.forEach (vn, i)->
		try
			vn.findNaN()
		catch e
			throw "vertexNormal has #{e}"
		return
	return

for f in ["Face4"]
	THREE[f]::findNaN = faceNaN

for m in ["Matrix3", "Matrix4"]
	THREE[m]::findNaN = matrixNaN

for v in ["Vector2", "Vector3", "Vector4"]
	THREE[v]::findNaN = vectorNaN

THREE.Geometry::findNaN = ->
	try
		@vertices.forEach (v, i)->
			try
				v.findNaN()
			catch e
				throw "Vertex #{i} has NaN where #{e}"
			return
		@faces.forEach (f, i)->
			try
				f.findNaN()
			catch e
				throw "Face #{i} has NaN where #{e}"
			return
	catch e
		throw "Geometry has NaN where #{e}"
	return

THREE.Mesh::findNaN = ->
	try
		@geometry.findNaN()
	catch e
		throw "Mesh has NaN where #{e}"
	

window.findNaN = (obj)->
	if obj.findNaN
		obj.findNaN()
	for matrix in ["matrix", "matrixWorld", "position", "rotation"]
		do ->
			if obj[matrix]
				try
					obj[matrix].findNaN()
				catch e
					throw "#{matrix} where #{e}"
	for child in obj.children
		try
			findNaN child
		catch e
			throw "#{child} has #{e}"
	return


do ->
	m4 = THREE.Matrix4
	THREE.Matrix4 = (n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 ) ->
		for i, n in arguments
			if n and isNaN n
				throw "NaN in matrix at #{m4p i}"
		m4.apply(@, arguments)
	THREE.Matrix4:: = m4::
	_set = m4::set
	m4::set = (n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 ) ->
		for i, n in arguments
			if n and isNaN n
				throw "NaN in matrix at #{m4p i}"
		_set.apply(@, arguments)
