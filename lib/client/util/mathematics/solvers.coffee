Math.sign = (x) -> if x < 0 then -1 else 1 

find =
	plane:
		###
		Given two nearby points on an ellipse (eg, initial position and position after single physics iteration),
		return the quaternion rotating a reference vector into the plane containing points `0`, `a`, and `b`.
		###
		rotation: (a, b, reference = vec(0, 1, 0))->
			# Find the normal of the plane
			N = a.clone().cross b
			N.normalize()

			# Find the angle between the reference and the normal
			R = reference.normalize()
			
			A = R.clone().cross(N)
			theta = Math.acos(R.clone().dot(N))

			h_theta = theta / 2
			A.multiplyScalar(Math.sin(h_theta))

			# The (shortest) rotation between reference and normal.
			Q = (new THREE.Quaternion(
				Math.cos(h_theta),
				A.x, A.y, A.z
			)).normalize()
			Q


		ellipse: (points, focus = vec(0, 0, 0))->
			params =
				reference: find.plane.rotation(points[0], points[1])
			params.reverse = params.reference.clone().inverse()

			fns =
				reverse: (p)-> p.applyQuaternion(params.reverse)
				plane: (p)-> vec(p.x, p.z)

			_(params).extend find.ellipse _(points).map(fns.reverse).map(fns.plane)#.map(fns.focus))


			params.N = params.semimajor * (1 - (params.eccentricity * params.eccentricity))

			params

	###
	Given three 2D points on an ellipse with a center at `(0, 0)`, find the eccentricity
	of the ellipse and the altitude at the closest approach.
	###
	ellipse: (points)->
		# Solution to Ellipse equation
		# eg the system Ax^2 + By^2 + 2Cxy = 1 for the three points.
		coefficients = [
			(p)-> p.x * p.x
			(p)-> p.y * p.y
			(p)-> 2 * p.x * p.y
			-> 1
		]
		[E, X] = solve.equations points, coefficients
		S = numeric.solve E, X

		# Get determinant pieces out of solution
		L = solve.quadraticDet S

		m = 1 / Math.sqrt(L[0])
		n = 1 / Math.sqrt(L[1])
		semimajor = Math.max(m, n)
		semiminor = Math.min(m, n)

		f = Math.sqrt(semimajor * semimajor - semiminor * semiminor)
		eccentricity = f / semimajor
		altitude = 1.2

		{semimajor, eccentricity, altitude}


solve =
	find: find
	###
	Return the matricies of `[A|b]` for several points (N) and a set of coeeficient equations (N + 1),
	where A[i][j] is the jth coeefficient applied to the ith point.
	###
	equations: (points, coefficients)->
		E = (coefficient(point) for coefficient in coefficients for point in points)
		X = (e[E.length] for e in E)
		e.length = E.length for e in E
		[E, X]

	###
	Return the two real solutions of x to the quadratic `ax^2 + bx + c`
	Uses a numerically-robust technique, and throws an exception in the case
	of a negative determinant.
	###
	quadratic: (a, b, c)->
		det = b * b - 4 * a * c

		throw "Non-real solution (#{a}, #{b}, #{c}): #{det}" if det < 0

		s = Math.sign(b)

		q = -0.5 * (b + s * Math.sqrt(det))

		x1 = q / a
		x2 = c / q

		[x1, x2]

	###
	Given A, B, C, solve the quadratic equation
	| A-l C   |
	| C   B-l | = 0
	for the two solutions of `l`
	###
	quadraticDet: (parts)->
		[A, B, C] = parts

		a = 1
		b = -(A + B)
		c = A * B - C * C

		solve.quadratic a, b, c

module = module || {exports: window}

module.exports.Solvers = solve
