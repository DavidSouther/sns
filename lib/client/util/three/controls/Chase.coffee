###
@author David Souther http://davidsouther.com
###
THREE.ChaseControls = (object, domElement) ->
	THREE.TrackballControls.call @, object, domElement
	@noPan = true
	@maxRadii = 6

	_chase = new THREE.Object3D
	_radius = 1
	Object.defineProperty @, 'chase',
		set: (it)->
			throw "Not a valid 3D object" unless it.position
			_chase = it
			@object.position = _chase.position
			geom = _chase.geometry || _chase
			if geom.computeBoundingSphere
				geom.computeBoundingSphere()
				_radius = geom.boundingSphere.radius * _chase.scale.x
				@minDistance = _radius
				@maxDistance = _radius * @maxRadii
		get: -> _chase

	@checkDistances = ->
		@eye.setLength(@maxDistance)  if @eye.lengthSq() > @maxDistance * @maxDistance
		@eye.setLength(@minDistance)  if @eye.lengthSq() < @minDistance * @minDistance

	oldPosition = @chase.position.clone()
	@update = =>
		@target = @chase.position.clone()
		@eye.subVectors oldPosition, @target
		oldPosition = @chase.position.clone()
		
		@rotateCamera()  unless @noRotate
		@zoomCamera()  unless @noZoom
		@panCamera()  unless @noPan
		@checkDistances()

		@object.position.addVectors @target, @eye

		@object.lookAt @target

	@

THREE.ChaseControls:: = Object.create(THREE.TrackballControls::)
