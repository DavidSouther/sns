###
@author David Souther http://davidsouther.com
###
THREE.ChaseControls = (object, domElement) ->
	THREE.TrackballControls.call @, object, domElement
	@noPan = true
	@maxRadius = 6

	_chase = new THREE.Object3D
	Object.defineProperty @, 'chase',
		set: (it)->
			throw "Not a valid 3D object" unless it.position
			_chase = it
			@object.position = _chase.position
			if _chase.computeBoundingSphere
				_chase.computeBoundingSphere()
				@object.position.add (vec 1, 1, 1).normalize().scalarMultiply(boundRadius() * 2)
				@minDistance = _chase.boundingSphere.radius
				@maxDistance = _chase.boundingSphere.radius * @maxRadius
		get: -> _chase

	boundRadius = ->
		_chase.computeBoundingSphere() if _chase.computeBoundingSphere unless _chase.boundingSphere
		radius = _chase.boundingSphere?.radius || 1
		radius

	@zoomCamera = ->
		if @_priv.state is THREE.TrackballControls.STATE.TOUCH_ZOOM
			factor = @_priv.touchZoomDistanceStart / @_priv.touchZoomDistanceEnd
			@_priv.touchZoomDistanceStart = @_priv.touchZoomDistanceEnd
		else
			factor = 1.0 + (@_priv.zoomEnd.y - @_priv.zoomStart.y) * @zoomSpeed
			if factor isnt 1.0 and factor > 0.0
				if @staticMoving
					@_priv.zoomStart.copy @_priv.zoomEnd
				else
					@_priv.zoomStart.y += (@_priv.zoomEnd.y - @_priv.zoomStart.y) * @dynamicDampingFactor
		factor

	@update = =>
		# _update.apply @
		bounds = boundRadius()
		distance = bounds

		# Point trail in correct direction...
		trail = vec(-1, 0.5, 0.5).normalize()
		# # Scale distance on zoom level
		distance *= @zoomCamera()
		# console.log distance
		trail.multiplyScalar distance

		# Constrain within distance bounds
		l = trail.length()
		trail.length(@minDistance) if l < @minDistance
		trail.length(@maxDistance) if l > @maxDistance

		@object.position = @chase.position.clone().add trail
		console.log trail

		@object.lookAt @chase.position
		# @object.up = @chase.up

	@

THREE.ChaseControls:: = Object.create(THREE.TrackballControls::)
