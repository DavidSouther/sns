define [], ()->
	tau = 2 * Math.PI
	hundredth_tau = tau / 100
	Orbital = (orbit, start = 0, stop = tau, step = hundredth_tau, color = 0xFA1010)->
		loops = [start, stop, step]
		geos =
			dots: new THREE.Geometry()
			line: new THREE.Geometry()
			ref: new THREE.Geometry()

		materials = 
			particle: new THREE.ParticleBasicMaterial {color, size: 0.1}
			line: new THREE.LineBasicMaterial {color}
			reference: new THREE.LineBasicMaterial {color: 0x10FA10}

		orbital = new THREE.Object3D()

		axis = ->
			geos.ref.vertices = [
				vec(0, 0, 0), vec(1, 0, 0).applyQuaternion(orbit.reference)
				vec(0, 0, 0), vec(0, 1, 0).applyQuaternion(orbit.reference)
				vec(0, 0, 0), vec(0, 0, 1).applyQuaternion(orbit.reference)
			]

		do orbital.update = ->
			for k, geo of geos
				geo.vertices.length = 0
				geo.verticesNeedUpdate = yes

			axis()
			[start, stop, step] = loops
			while start < stop
				vert = orbit(start)
				geos.dots.vertices.push vert
				geos.line.vertices.push vert
				start += step
		orbit.listen orbital.update

		orbital.add dots = new THREE.ParticleSystem geos.dots, materials.particle
		orbital.add line = new THREE.Line geos.line, materials.line
		orbital.add ref = new THREE.Line geos.ref, materials.reference, THREE.LinePieces

		orbital
