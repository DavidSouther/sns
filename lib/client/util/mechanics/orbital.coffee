define [], ()->
	Orbital = (orbit, start = 0, stop = 100, step = 1)->
		orbital = 
			geometry: new THREE.Geometry()
			material: new THREE.ParticleBasicMaterial
				color: 0xFA1010
				size: 0.1

		while start < stop
			orbital.geometry.vertices.push orbit(start)
			start += step

		orbital.line = new THREE.ParticleSystem orbital.geometry, orbital.material
		orbital.line
