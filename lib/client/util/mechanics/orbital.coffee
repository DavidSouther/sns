define [], ()->
	Orbital = (orbit, start = 0, stop = 100, step = 1)->
		orbital = 
			geometry: new THREE.Geometry()
			material: new THREE.LineBasicMaterial
				color: 0xFA1010

		while start < stop
			orbital.geometry.vertices.push orbit(start)
			start += step

		orbital.line = new THREE.Line orbital.geometry, orbital.material, THREE.LineStrip

		orbital.line
