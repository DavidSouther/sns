define [], ()->
	projector = new THREE.Projector()

	class THREE.Click 
		constructor: ($container, stage)->
			down = 0
			$container.on 'mousedown', ->
				down = Date.now();

			$container.on 'mouseup', (event)->
				event.preventDefault()
				return if Date.now() - down > @CLICK_TIMEOUT
				down = 0

				# Get the projection vector for the raycast
				vector = vec( ( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1, 0.5 )
				projector.unprojectVector( vector, stage.camera )
				vector.sub( stage.camera.position ).normalize()

				raycaster = new THREE.Raycaster stage.camera.position, vector

				intersects = raycaster.intersectObjects stage.scene.children, yes

				stage.clicked? intersects

				intersects

		CLICK_TIMEOUT: 100

	$ ->
		dat.add THREE.Click::, 'CLICK_TIMEOUT', 0, 1000

	THREE.Click
