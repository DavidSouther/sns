define [], ()->
	tau = 2 * Math.PI
	hundredth_tau = tau / 100

	class THREE.Orbital extends THREE.Object3D
		constructor: (@orbit, @color = 0xFA1010, @height = hundredth_tau, @loop = {start: hundredth_tau, stop: tau, step: hundredth_tau}, @vc = no)->
			super()

			@geos =
				dots: new THREE.Geometry()
				line: new THREE.Geometry()
			@axis = new THREE.AxisHelper()
			@axis.useQuaternion = yes
			@axis.quaternion = new THREE.Quaternion()

			materials =
				particle: new THREE.ParticleBasicMaterial {vertexColors: @vc, size: 5, sizeAttenuation: no, color: @color}
				line: new THREE.LineBasicMaterial {vertexColors: @vc, color: @color}

			@add new THREE.ParticleSystem @geos.dots, materials.particle
			@add new THREE.Line @geos.line, materials.line
			@add @axis

			@update()
			orbit.listen =>@update()

		update: =>
			for k, geo of @geos
				geo.vertices.length = geo.colors.length = 0
				geo.verticesNeedUpdate = geo.colorsNeedUpdate = yes

			@axis.quaternion = @orbit.reference

			{start, stop, step} = @loop
			addVert = (theta)=>
				vert = @orbit.closed(theta)
				vert.y += @height
				@geos.dots.vertices.push vert
				@geos.line.vertices.push vert

				h = ((theta / tau)) / 3 + 0.25
				color = (new THREE.Color()).setHSL(h, 0.5, 0.5)

				# console.log vert, color

				@geos.dots.colors.push color
				@geos.line.colors.push color

			while start < stop
				addVert start
				start += step

		onclick: (intersection)->
			@orbit.theta intersection.point
