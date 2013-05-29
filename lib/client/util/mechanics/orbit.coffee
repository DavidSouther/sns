define [], ()->
	# body has .reference (vec3 identity), .position (vec3)
	# body, craft have .mass (scalar)
	# craft has velocity
	# orbit should usually come from "parts", it's cleaner.
	class THREE.Orbit
		constructor: (@body, @craft, orbit)->
			Q = new THREE.Quaternion()
			velocity = 0
			N = 0

			@closed = (t)->
				# Calculate theta on perfect circle
				s = t * velocity
				# Get cartesian points from perfect circle
				y = Math.cos s
				x = Math.sin s

				# Calculate radius at this point
				q = 1 + orbit.eccentricity * x
				r = N / q
				# Project onto XZ plane
				pos = vec(r * x, 0, r * y)
				pos.applyQuaternion @reverse

				# Cheat on the velocity vector by calling closed with a step

				pos

			do @calcReference = =>
				# Calculate the reference plane for this orbit.
				# The reference plane goes through the origin, with a normal given by closed.reference
				# The normal starts pointing "due north"
				# We then rotate the reference frame around the vertical (y) axis to longitude,
				# the horizontal (z) axis to inclination, and again around the (new) vertical (y) axis to periapsis.
				@reference = Q.setFromEuler(vec(orbit.longitude, orbit.inclination, orbit.periapsis), "yzy")
				@reverse = @reference.clone().inverse()

				eccentricitySquared = orbit.eccentricity * orbit.eccentricity
				semimajor = orbit.altitude / (1 - orbit.eccentricity)
				N = semimajor * (1 - eccentricitySquared)
				velocity = (2 * Math.PI) / (orbit.period * 60)

			listeners = []
			@listen = (f)->
				listeners.push f

			do @watch = =>
				folder = dat.addFolder "Orbit"
				parts =
					eccentricity: [0, 1]
					altitude: [1, 2]
					longitude: [0, 2 * Math.PI]
					inclination: [0, 2 * Math.PI]
					periapsis: [0, 2 * Math.PI]
					# period: [0, 120]
				for param, range of parts
					controller = folder.add(orbit, param, range[0], range[1])
					controller.onChange ->
						@calcReference()
						listen() for listen in listeners
						return
				@

		theta: (point)->
			point.applyQuaternion @reference
			r = point.length()
			theta = Math.acos(point.x / r)
			theta = Math.asin(point.z / r)
			console.log "Click on the orbit at ", theta


	# orbit has eccentricity (>=0), altitude, inclination (rad), longitude (rad), periapsis (rad)
	# Eccentricity: Elongates the ellipse. 0 = circle, 0 < e < 1 = ellipse, >=1 = escape trajectory
	# Altitude: height of craft at epoch (t=0).
	# Inclination: angle N of due east on equator at epoch.
	# Longitude: angle Longitude East of reference on equator.
	# Periapsis: angle along orbit at epoch (follow inclination from longitude.)
	# Period: time in (game) minutes to complete one orbit
	THREE.Orbit.parts = (eccentricity, altitude, inclination, longitude, periapsis, period = 90)->
		{eccentricity, altitude, inclination, longitude, periapsis, period}


	THREE.Orbit