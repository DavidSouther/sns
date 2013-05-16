###
@author David Souther http://davidsouther.com
###
class THREE.ChaseControls extends THREE.Trackball
	constructor: (object, domElement = document) ->
		super(object, domElement)
		@noPan = true
		@maxRadii = 16
		@rotateSpeed = 0.5
		@eye = vec -1, 0, 0

		_chase = new THREE.Object3D
		_radius = 1
		Object.defineProperty @, 'chase',
			set: (it)->
				throw "Not a valid 3D object" unless it.position
				_chase = it
				_chase.rotationAutoUpdate = true
				@object.position = _chase.position
				geom = _chase.geometry || _chase
				if geom.computeBoundingSphere
					geom.computeBoundingSphere()
					# This is some "magic" until we get a better bounding sphere
					SCALE_FACTOR = 2
					_radius = geom.boundingSphere.radius * _chase.scale.length() * SCALE_FACTOR
					@minDistance = _radius
					@maxDistance = _radius * @maxRadii
			get: -> _chase

		$ =>
			df = dat.addFolder "Chase"
			df.add @, "rotateSpeed", 0, 1
			df.add @, "maxRadii"

	checkDistances: ->
		if @eye.lengthSq() is 0
			console.warn "eye locked at 0"
			@eye = vec -1, 0, 0

		@eye.setLength(@maxDistance) if @eye.lengthSq() > @maxDistance * @maxDistance
		@eye.setLength(@minDistance) if @eye.lengthSq() < @minDistance * @minDistance

	update: =>
		# Calculate new eye position from events since last update
		@zoom()
		@rotate()

		# Fix any oddities
		@checkDistances()

		# Rotate the eye's origin and apply to camera
		eye = @eye.clone()

		@object.position.addVectors @chase.position, eye

		@object.lookAt @chase.position
