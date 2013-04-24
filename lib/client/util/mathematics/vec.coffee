window.vec = (x, y, z, w)->
	switch arguments.length
		when 2 then new THREE.Vector2 x, y
		when 3 then new THREE.Vector3 x, y, z
		when 4 then new THREE.Vector4 x, y, z, w