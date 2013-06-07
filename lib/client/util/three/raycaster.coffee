ray = new THREE.Ray()
_intersect = THREE.Raycaster::intersectObjects

THREE.Raycaster::intersectObjects = ( objects, recursive )->
	intersects = []

	for object in objects
		if THREE.Orbital and object instanceof THREE.Orbital
			# Calculate point on plane intersection
			plane =
				normal: vec(0, 1, 0).applyQuaternion object.orbit.reference
				origin: object.orbit.body.position || vec 0, 0, 0
			point = @intersectPlane plane.origin, plane.normal

			# Find closest point on line strip to plane intersection
			distance = @toLineStrip(object.geos.line.vertices, point)

			length = distance.length()
			if length < THREE.Raycaster::intersectObjects.MAX_LINE_DISTANCE
				intersects.push {distance: length, point, face: null, object}
		else
			intersects.concat _intersect.apply @, [object, recursive]

	intersects

THREE.Raycaster::intersectPlane = (origin, normal)->
	diff = vec(0, 0, 0).add(origin).sub(@ray.origin)
	N = diff.dot(normal)
	Q = vec(0, 0, 0).add(@ray.direction).dot(normal)
	D = N / Q
	point = vec(0, 0, 0).add(@ray.direction).multiplyScalar(D).add(@ray.origin)

THREE.Raycaster::toLine = (line, normal, point)->
	AP = line.clone().sub(point)
	APN = AP.clone().dot(normal)
	APNN = normal.multiplyScalar(APN)
	distance = AP.sub(APNN)

THREE.Raycaster::toLineStrip = (lines, point)->
	Distance = (index)=>
		@toLine lines[index], lines[index + 1].clone().sub(lines[index]), point

	# Loop through the line segments in the orbit, saving the closest
	closest = vec(Infinity, Infinity, Infinity)
	closestDistanceSQ = Infinity
	start = 0
	stop = lines.length - 2
	while start < stop
		distance = Distance(start)
		distanceSQ = distance.lengthSq()
		if distanceSQ < closestDistanceSQ
			closest = distance
			closestDistanceSQ = distanceSQ
		start += 1
	closest

THREE.Raycaster::intersectObjects.MAX_LINE_DISTANCE = 0.1
$ ->
	dat.add THREE.Raycaster::intersectObjects, 'MAX_LINE_DISTANCE', 0, 1