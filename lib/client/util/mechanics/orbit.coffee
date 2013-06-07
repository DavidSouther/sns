define [], ()->
	# body has .reference (vec3 identity)
	# body, craft have .mass (scalar)
	# craft has velocity
	# orbit should usually come from "parts", it's cleaner.
<<<<<<< Updated upstream
	Orbit = (body, craft, orbit)->
		# Calculate the reference plane for this orbit.
		reference = body.reference.clone().applyEuler(vec(-orbit.periapsis, orbit.inclination, -orbit.longitude), "zxz")
		eccentricitySquared = orbit.eccentricity * orbit.eccentricity
		N = orbit.semimajor * (1 - eccentricitySquared)
		velocity = (2 * Math.PI) / (orbit.period * 60)

		closed = (t)->
			s = t
			s = t * velocity
			y = Math.cos s
			x = Math.sin s

			q = 1 + orbit.eccentricity * x
			r = N / q
			pos = vec(r * x, 0, r * y).applyEuler(reference)

			# Cheat on the velocity vector by calling closed with a step

			pos
		closed

	# orbit has eccentricity (>=0), altitude, inclination (rad), longitude (rad), periapsis (rad)
	# Eccentricity: Elongates the ellipse. 0 = circle, 0 < e < 1 = ellipse, >=1 = escape trajectory
	# Altitude: height of craft at epoch (t=0).
	# Inclination: angle N of due east on equator at epoch.
	# Longitude: angle Longitude East of reference on equator.
	# Periapsis: angle along orbit at epoch (follow inclination from longitude.)
	# Perior: time in (game) minutes to complete one orbit
	Orbit.parts = (eccentricity, altitude, inclination, longitude, periapsis, period = 90)->
		semimajor = altitude / (1 - eccentricity)
		{eccentricity, semimajor, inclination, longitude, periapsis, period}

	Orbit
=======
	class THREE.Orbit
		constructor: (@body, @craft, @params)->
			listeners = []
			@listen = (f)->
				listeners.push f

			{@reference, @reverse, @N, @velocity} = @params

			if not @params.reference
				@calcReference()
				@params.velocity ?= 1
			@params.velocity = 1

			# do @watch = =>
			# 	folder = dat.addFolder "Orbit"
			# 	parts =
			# 		eccentricity: [0, 1]
			# 		altitude: [1, 2]
			# 		longitude: [0, 2 * Math.PI]
			# 		inclination: [0, 2 * Math.PI]
			# 		periapsis: [0, 2 * Math.PI]
			# 		# period: [0, 120]
			# 	for param, range of parts
			# 		controller = folder.add(orbit, param, range[0], range[1])
			# 		controller.onChange ->
			# 			@calcReference()
			# 			listen() for listen in listeners
			# 			return
			# 	@

		closed: (t)->
			# Calculate theta on perfect circle
			s = t * @params.velocity # TODO correct for actual velocity
			# Get cartesian points from perfect circle
			y = Math.cos s
			x = Math.sin s

			# Calculate radius at this point
			q = 1 + @params.eccentricity * x
			r = @params.N / q
			# Project onto XZ plane
			pos = vec(r * x, 0, r * y)
			pos.applyQuaternion @reverse

			# Cheat on the velocity vector by calling closed with a step
			pos

		calcReference: ->
			# Calculate the reference plane for this orbit.
			# The reference plane goes through the origin, with a normal given by closed.reference
			# The normal starts pointing "due north"
			# We then rotate the reference frame around the vertical (y) axis to longitude,
			# the horizontal (z) axis to inclination, and again around the (new) vertical (y) axis to periapsis.
			@reference = (new THREE.Quaternion()).setFromEuler(vec(@params.longitude, @params.inclination, @params.periapsis), "yzy")
			@reverse = @reference.clone().inverse()

			eccentricitySquared = @params.eccentricity * @params.eccentricity
			@params.semimajor = @params.altitude / (1 - @params.eccentricity)
			@params.N = @params.semimajor * (1 - eccentricitySquared)
			@params.velocity = (2 * Math.PI) / (@params.period * 60)

		theta: (point)->
			point.applyQuaternion @reference
			r = point.length()
			theta = Math.acos(point.x / r)
			theta = Math.asin(point.z / r)
			console.log "Click on the orbit at ", theta

	###
	orbit has eccentricity (>=0), altitude, inclination (rad), longitude (rad), periapsis (rad)
	Eccentricity: Elongates the ellipse. 0 = circle, 0 < e < 1 = ellipse, >=1 = escape trajectory
	Altitude: height of craft at epoch (t=0).
	Inclination: angle N of due east on equator at epoch.
	Longitude: angle Longitude East of reference on equator.
	Periapsis: angle along orbit at epoch (follow inclination from longitude.)
	Period: time in (game) minutes to complete one orbit
	###
	THREE.Orbit.parts = (eccentricity, altitude, inclination, longitude, periapsis, period = 90)->
		{eccentricity, altitude, inclination, longitude, periapsis, period}

	THREE.Orbit.fromPoints = (a, b, c)->
		orbit = Solvers.find.planeEllipse(a, b, c)
		orbit

	THREE.Orbit
>>>>>>> Stashed changes
