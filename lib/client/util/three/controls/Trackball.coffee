###
@author Eberhard Graether / http://egraether.com/
@author David Souther / http://davidsouther.com/
###
# events
changeEvent = type: "change"

class THREE.Trackball extends THREE.EventDispatcher
	constructor: (@object, @domElement = document)->
		@enabled = true
		@screen =
			width: 0
			height: 0
			offsetLeft: 0
			offsetTop: 0

		@radius = (@screen.width + @screen.height) / 4
		@eye = new THREE.Vector3()
		@rotateSpeed = 1.0
		@zoomSpeed = 1.2
		@panSpeed = 0.3
		@noRotate = @noZoom = @noPan = @staticMoving = false
		@dynamicDampingFactor = 0.2
		@minDistance = 0
		@maxDistance = Infinity
		@keys = [65, 83, 68]
		@target = new THREE.Vector3()

		@_ =
			lastPosition: new THREE.Vector3()
			state: THREE.Trackball.STATE.NONE
			prevState: THREE.Trackball.STATE.NONE
			rotateStart: new THREE.Vector3()
			rotateEnd: new THREE.Vector3()
			zoomStart: new THREE.Vector2()
			zoomEnd: new THREE.Vector2()
			touchZoomDistanceStart: 0
			touchZoomDistanceEnd: 0
			panStart: new THREE.Vector2()
			panEnd: new THREE.Vector2()

		@initial =
			target: @target.clone()
			position: @object.position.clone()
			up: @object.up.clone()

		THREE.Trackball.listeners.apply @

	###
	Extendable methods
	###
	rotate: ->
		angle = Math.acos(@_.rotateStart.dot(@_.rotateEnd) / @_.rotateStart.length() / @_.rotateEnd.length())
		if angle
			axis = (new THREE.Vector3()).crossVectors(@_.rotateStart, @_.rotateEnd).normalize()
			quaternion = new THREE.Quaternion()
			angle *= @rotateSpeed
			quaternion.setFromAxisAngle axis, -angle
			@eye.applyQuaternion quaternion
			# @object.up.applyQuaternion quaternion
			# @_.rotateEnd.applyQuaternion quaternion
			# if @staticMoving
			# 	@_.rotateStart.copy @_.rotateEnd
			# else
			# 	quaternion.setFromAxisAngle axis, angle * (@dynamicDampingFactor - 1.0)
			# 	@_.rotateStart.applyQuaternion quaternion

	zoom: ->
		factor = 1
		if @_.state is THREE.Trackball.STATE.TOUCH_ZOOM
			factor = @_.touchZoomDistanceStart / @_.touchZoomDistanceEnd
			@_.touchZoomDistanceStart = @_.touchZoomDistanceEnd
			@eye.multiplyScalar factor
		else
			factor = 1.0 + (@_.zoomEnd.y - @_.zoomStart.y) * @zoomSpeed
			if factor isnt 1.0 and factor > 0.0
				@eye.multiplyScalar factor
				if @staticMoving
					@_.zoomStart.copy @_.zoomEnd
				else
					@_.zoomStart.y += (@_.zoomEnd.y - @_.zoomStart.y) * @dynamicDampingFactor

	pan: ->
		mouseChange = @_.panEnd.clone().sub(@_.panStart)
		if mouseChange.lengthSq()
			mouseChange.multiplyScalar @eye.length() * @panSpeed
			pan = @eye.clone().cross(@object.up).setLength(mouseChange.x)
			pan.add @object.up.clone().setLength(mouseChange.y)
			@object.position.add pan
			@target.add pan
			if @staticMoving
				@_.panStart = @_.panEnd
			else
				@_.panStart.add mouseChange.subVectors(@_.panEnd, @_.panStart).multiplyScalar(@dynamicDampingFactor)

	checkDistances: ->
		if not @noZoom or not @noPan
			@object.position.setLength @maxDistance  if @object.position.lengthSq() > @maxDistance * @maxDistance
			@object.position.addVectors @target, @eye.setLength(@minDistance)  if @eye.lengthSq() < @minDistance * @minDistance

	update: ->
		@eye.subVectors @object.position, @target

		@rotate() unless @noRotate
		@zoom() unless @noZoom
		@pan() unless @noPan

		@object.position.addVectors @target, @eye
		@checkDistances()
		@object.lookAt @target

		if @_.lastPosition.distanceToSquared(@object.position) > 0
			@dispatchEvent changeEvent
			@_.lastPosition.copy @object.position

	reset: ->
		@_.state = THREE.Trackball.STATE.NONE
		@_.prevState = THREE.Trackball.STATE.NONE

		@target.copy @initial.target
		@object.position.copy @initial.position
		@object.up.copy @initial.up

		@eye.subVectors @object.position, @target
		@object.lookAt @target

		@dispatchEvent changeEvent
		@_.lastPosition.copy @object.position

	# methods
	handleResize: ->
		@screen.width = window.innerWidth
		@screen.height = window.innerHeight
		@screen.offsetLeft = 0
		@screen.offsetTop = 0
		@radius = (@screen.width + @screen.height) / 4

	handleEvent: (event)=>
		@[event.type] event if typeof @[event.type] is "function"

	getMouseOnScreen: (clientX, clientY)=>
		new THREE.Vector2(
			(clientX - @screen.offsetLeft) / @radius * 0.5,
			(clientY - @screen.offsetTop) / @radius * 0.5
		)

	getMouseProjectionOnBall: (clientX, clientY)=>
		mouseOnBall = new THREE.Vector3(
			(clientX - @screen.width * 0.5 - @screen.offsetLeft) / @radius,
			(@screen.height * 0.5 + @screen.offsetTop - clientY) / @radius,
			0.0
		)
		length = mouseOnBall.length()
		if length > 1.0
			mouseOnBall.normalize()
		else
			mouseOnBall.z = Math.sqrt(1.0 - length * length)

		eye = @object.position.clone().sub @target
		projection = @object.up.clone().setLength(mouseOnBall.y)
		projection.add @object.up.clone().cross(eye).setLength(mouseOnBall.x)
		projection.add eye.setLength(mouseOnBall.z)
		projection

THREE.Trackball.listeners = ->
	mousedown = (event)=>
		return  if @enabled is false
		event.preventDefault()
		event.stopPropagation()
		@_.state = event.button  if @_.state is THREE.Trackball.STATE.NONE
		@_.rotateStart = @_.rotateEnd = @getMouseProjectionOnBall(event.clientX, event.clientY)

		document.addEventListener "mousemove", mousemove, false
		document.addEventListener "mouseup", mouseup, false

	mousemove = (event)=>
		return  if @enabled is false
		event.preventDefault()
		event.stopPropagation()
		@_.rotateEnd = @getMouseProjectionOnBall(event.clientX, event.clientY)

	mouseup = (event)=>
		return  if @enabled is false
		event.preventDefault()
		event.stopPropagation()
		document.removeEventListener "mousemove", mousemove
		document.removeEventListener "mouseup", mouseup

	mousewheel = (event)=>
		return  if @enabled is false
		event.preventDefault()
		event.stopPropagation()
		delta = 0
		if event.wheelDelta # WebKit / Opera / Explorer 9
			delta = event.wheelDelta / 40
		# Firefox
		else delta = -event.detail / 3  if event.detail
		@_.zoomStart.y += delta * 0.01

	touchstart = (event)=>
		return  if @enabled is false
		switch event.touches.length
			when 1
				@_.state = THREE.Trackball.STATE.TOUCH_ROTATE
				@_.rotateStart = @_.rotateEnd = @getMouseProjectionOnBall(event.touches[0].pageX, event.touches[0].pageY)
			when 2
				@_.state = THREE.Trackball.STATE.TOUCH_ZOOM
				dx = event.touches[0].pageX - event.touches[1].pageX
				dy = event.touches[0].pageY - event.touches[1].pageY
				@_.touchZoomDistanceEnd = @_.touchZoomDistanceStart = Math.sqrt(dx * dx + dy * dy)
			when 3
				@_.state = THREE.Trackball.STATE.TOUCH_PAN
				@_.panStart = @_.panEnd = @getMouseOnScreen(event.touches[0].pageX, event.touches[0].pageY)
			else
				@_.state = THREE.Trackball.STATE.NONE

	touchmove = (event)=>
		return  if @enabled is false
		event.preventDefault()
		event.stopPropagation()
		switch event.touches.length
			when 1
				@_.rotateEnd = @getMouseProjectionOnBall(event.touches[0].pageX, event.touches[0].pageY)
			when 2
				dx = event.touches[0].pageX - event.touches[1].pageX
				dy = event.touches[0].pageY - event.touches[1].pageY
				@_.touchZoomDistanceEnd = Math.sqrt(dx * dx + dy * dy)
			when 3
				@_.panEnd = @getMouseOnScreen(event.touches[0].pageX, event.touches[0].pageY)
			else
				@_.state = THREE.Trackball.STATE.NONE

	touchend = (event)=>
		return  if @enabled is false
		switch event.touches.length
			when 1
				@_.rotateStart = @_.rotateEnd = @getMouseProjectionOnBall(event.touches[0].pageX, event.touches[0].pageY)
			when 2
				@_.touchZoomDistanceStart = @_.touchZoomDistanceEnd = 0
			when 3
				@_.panStart = @_.panEnd = @getMouseOnScreen(event.touches[0].pageX, event.touches[0].pageY)
		@_.state = THREE.Trackball.STATE.NONE

	@domElement.addEventListener "contextmenu", ((event)-> event.preventDefault() ), false
	@domElement.addEventListener "mousedown", mousedown, false
	@domElement.addEventListener "mousewheel", mousewheel, false
	@domElement.addEventListener "DOMMouseScroll", mousewheel, false # firefox
	# @domElement.addEventListener "touchstart", touchstart, false
	# @domElement.addEventListener "touchend", touchend, false
	# @domElement.addEventListener "touchmove", touchmove, false
	# window.addEventListener "keydown", keydown, false
	# window.addEventListener "keyup", keyup, false
	@handleResize()

THREE.Trackball.STATE =
	NONE: -1
	ROTATE: 0
	ZOOM: 1
	PAN: 2
	TOUCH_ROTATE: 3
	TOUCH_ZOOM: 4
	TOUCH_PAN: 5
