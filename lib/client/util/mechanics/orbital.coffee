tau = 2 * Math.PI
hundredth_tau = tau / 100
define [], ()->
	Orbital = class Orbital extends THREE.Object3D
		constructor: (@orbit, start = 0, stop = tau, step = hundredth_tau, @color = 0xFA1010)->
			super()
			@name = "orbital_#{@id}"
			@geometry = new THREE.Geometry()
			@materials =
				particle: new THREE.ParticleBasicMaterial {color: @color, size: 0.1}
				line: new THREE.LineBasicMaterial {color: @color}

			while start < stop
				tA = start += step
				position = @orbit.positionAtTrueAnomaly tA
				v = (new THREE.Vector3().fromArray(position))
				@geometry.vertices.push v

			@add @dots = new THREE.ParticleSystem @geometry.clone(), @materials.particle
			@add @line = new THREE.Line @geometry.clone(), @materials.line
