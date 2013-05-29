define [], ()->
	tau = 2 * Math.PI
	hundredth_tau = tau / 100

	class THREE.Orbital extends THREE.Object3D
		constructor: (@orbit, @loop = [0, tau, hundredth_tau], @color = 0xFA1010)->
			super()

			@geos =
				dots: new THREE.Geometry()
				line: new THREE.Geometry()
				ref: new THREE.Geometry()

			materials =
				particle: new THREE.ParticleBasicMaterial {@color, size: 0.1}
				line: new THREE.LineBasicMaterial {@color}
				reference: new THREE.LineBasicMaterial {color: 0x10FA10}

			axis = =>
				@geos.ref.vertices = [
					vec(0, 0, 0), vec(1, 0, 0).applyQuaternion(orbit.reference)
					vec(0, 0, 0), vec(0, 1, 0).applyQuaternion(orbit.reference)
					vec(0, 0, 0), vec(0, 0, 1).applyQuaternion(orbit.reference)
				]

			do @update = =>
				for k, geo of @geos
					geo.vertices.length = 0
					geo.verticesNeedUpdate = yes

				axis()
				[start, stop, step] = @loop
				while start < stop
					vert = orbit.closed(start)
					@geos.dots.vertices.push vert
					@geos.line.vertices.push vert
					start += step
			orbit.listen @update

			@add new THREE.ParticleSystem @geos.dots, materials.particle
			@add new THREE.Line @geos.line, materials.line
			@add new THREE.Line @geos.ref, materials.reference, THREE.LinePieces

		onclick: (intersection)->
			@orbit.theta intersection.point
