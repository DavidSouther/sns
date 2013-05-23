do ->
	Q = new THREE.Quaternion()
	axes = 
		X: (n)-> Q.setFromAxisAngle vec(1, 0, 0), n
		Y: (n)-> Q.setFromAxisAngle vec(0, 1, 0), n
		Z: (n)-> Q.setFromAxisAngle vec(0, 0, 1), n

	_setFromEuler = THREE.Quaternion::setFromEuler
	THREE.Quaternion::setFromEuler = (v, order = "XYZ")->
		order = order.toUpperCase().split ''

		# if typeof THREE.Quaternion::setFromEuler[order] is 'function'
		# 	THREE.Quaternion::setFromEuler[order].apply @, [v, order]
		# else
		# 	_setFromEuler.apply @, [v, order]

		@set 1, 0, 0, 0
		@multiply axes[order[0]] v.x
		@multiply axes[order[1]] v.y
		@multiply axes[order[2]] v.z
		@