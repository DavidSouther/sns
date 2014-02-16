define ['util/mechanics/body'], (CelestialBody)->
	Planet = class Planet extends CelestialBody
		constructor: (name, @mass, @radius, @siderealRotation,
			@orbit, @atmPressure,
			@texture, @bump, @clouds
		)->
			super(@mass, @radius, @siderealRotation, @orbit, @atmPressure)
			@name = name

			# set up the sphere vars
			segments = 16 * 6
			rings = 16 * 4

			surfaceMaterial = new THREE.MeshPhongMaterial map: THREE.ImageUtils.loadTexture texture
			surfaceMaterial.bumpMap = THREE.ImageUtils.loadTexture bump unless not bump
			surface = new THREE.Mesh new THREE.SphereGeometry(radius, segments, rings), surfaceMaterial
			surface.name = "#{@name}_suface"

			@add surface
			@computeBoundingSphere = ->
			@boundingSphere = {@radius}

			@timeScale = 15

			@update = (t)=>
				@rotation = vec 0, @siderealTimeAt(0, t), 0

	Planet