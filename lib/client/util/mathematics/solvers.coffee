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

		ellipse: (a, b, c, center = vec(0, 0, 0))->
			reference = find.plane.rotation(a, b)
			reverse = reference.clone().inverse()

			# Project the vectors onto the plane.
			center2 = center.applyQuaternion(reverse)
			d = center2.x

			a3 = a.applyQuaternion(reverse)
			b3 = b.applyQuaternion(reverse)
			c3 = c.applyQuaternion(reverse)

			a2 = vec(a3.x + d, a3.z)
			b2 = vec(b3.x + d, b3.z)
			c2 = vec(c3.x + d, c3.z)

			{semimajor, eccentricity, altitude} = find.ellipse(a2, b2, c2)

			N = semimajor * (1 - (eccentricity * eccentricity))

			{reference, reverse, eccentricity, N}

	###
	Given an NxM matrix, convert to upper-right trangular form.
	@param {elements} Array of length N, each element being an array of length M. THIS ARRAY WILL BE MODIFIED.
	@return the modified array.
	@reference https://github.com/jcoglan/sylvester/blob/bb0a1e7cbe6a6ac875f30865fade74fd4c71f975/src/matrix.js toRightTriangular()::279
	###
	rightTriangular: (elements)->
		k = n = elements.length
		kp = elements[0].length
		loop
			i = k - n
			if elements[i][i] is 0
				j = i + 1
				while j < k
					unless elements[j][i] is 0
						els = []
						np = kp
						loop
							p = kp - np
							els.push elements[i][p] + elements[j][p]
							break unless --np
						elements[i] = els
						break
					j++
			unless elements[i][i] is 0
				j = i + 1
				while j < k
					multiplier = elements[j][i] / elements[i][i]
					els = []
					np = kp
					loop
						p = kp - np
						
						# Elements with column numbers up to an including the number
						# of the row that we're subtracting can safely be set straight to
						# zero, since that's the point of this routine and it avoids having
						# to loop over and correct rounding errors later
						els.push (if p <= i then 0 else elements[j][p] - elements[i][p] * multiplier)
						break unless --np
					elements[j] = els
					j++
			break unless --n
		elements

	###
	Given three 2D points on an ellipse with a center at `(0, 0)`, find the eccentricity
	of the ellipse and the altitude at the closest approach.
	###
	ellipse: (a, b, c)->
		# Solution to Ellipse equation
		# eg the system Ax^2 + By^2 + 2Cxy = 1 for the three points.
		E = solve.equations a, b, c
		S = solve.matrix E

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
	Return a matrix of `[A|b]` for the ellipse equation `A x^2 + B y^2 + 2Cxy = 1` in three points of `R^2`
	###
	equations: (x, y, z)->
		ax2 = x.x * x.x
		ay2 = x.y * x.y
		axy = x.x * x.y * 2

		bx2 = y.x * y.x
		by2 = y.y * y.y
		bxy = y.x * y.y * 2

		cx2 = z.x * z.x
		cy2 = z.y * z.y
		cxy = z.x * z.y * 2

		[[ax2, ay2, axy, 1]
		 [bx2, by2, bxy, 1]
		 [cx2, cy2, cxy, 1]]

	###
	Given a matrix of the form `[A|b]`
	where `A` is an `N` by `N` matrix of coefficients for equations in `N` unknowns, and 
	`b` is an `N` length column vector with the solutions for those equations, return the
	row vector
	###
	matrix: (equations)->
		find.rightTriangular equations

		sol_z = equations[2][3] / equations[2][2]
		sol_y = (equations[1][3] - equations[1][2]*sol_z) / equations[1][1]
		sol_x = (equations[0][3] - equations[0][2]*sol_z - equations[0][1]*sol_y) / equations[0][0]

		[sol_x, sol_y, sol_z]

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
