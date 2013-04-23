define ["util/vec"], (vec)->
	# body has .reference (vec3 identity)
	# body, craft have .mass (scalar)
	# craft has velocity
	# orbit should usually come from "parts", it's cleaner.
	Orbit = (body, craft, orbit)->
		# Calculate the reference plane for this orbit.
		reference = body.reference.clone().applyEuler(vec(-orbit.periapsis, orbit.inclination, -orbit.longitude), "zxz")
		eccentricitySquared = orbit.eccentricity * orbit.eccentricity
		N = orbit.semimajor * (1 - eccentricitySquared)

		closed = (t)->
			s = t
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
	Orbit.parts = (eccentricity, altitude, inclination, longitude, periapsis)->
		eccentricity: eccentricity
		semimajor: altitude / (1 - eccentricity)
		inclination: inclination
		longitude: longitude
		periapsis: periapsis

	Orbit
