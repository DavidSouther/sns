define [], ()->
	tau = 2 * Math.PI
	hundredth_tau = tau / 100
	Orbital = (orbit, start = 0, stop = tau, step = hundredth_tau, color = 0xFA1010)->
		orbital =
			geometry: new THREE.Geometry()
			materials:
				particle: new THREE.ParticleBasicMaterial {color, size: 0.1}
				line: new THREE.LineBasicMaterial {color}

		while start < stop
			orbital.geometry.vertices.push orbit(start)
			start += step

		orbital.dots = new THREE.ParticleSystem orbital.geometry.clone(), orbital.materials.particle
		orbital.line = new THREE.Line orbital.geometry.clone(), orbital.materials.line
		orbital
