define [], ()->
	(scene)->
		d3.csv "starmap/assets/stars.csv", (error, stars)->
			HMStoRAD = (hms)->
				[a, h, m, s] = hms.match /(-?[0-9]+)h([0-9][0-9])m([^s]+)s/
				deg = parseInt(h) * (360 / 24) + 60 * m + 3600 * s
				rad = deg * (Math.PI / 180)
				rad

			DMStoRAD = (dms)->
				[a, d, m, s] = dms.match /(-?[0-9]+)d([0-9][0-9])m([^s]+)s/
				deg = d + 60 * m + 3600 * s
				rad = deg * (Math.PI / 180)
				rad

			toXYZ = (theta, phi, radius)->
				X = radius * Math.sin(theta) * Math.cos(phi)
				Z = radius * Math.sin(theta) * Math.sin(phi)
				Y = radius * Math.cos(theta)
				V = new THREE.Vector3(X, Y, Z)
				V

			astroToXYZ = (d)->
				v = toXYZ(
					HMStoRAD(d.Ascension),
					DMStoRAD(d.Declination),
					d.Distance
				)
				v

			d3d(scene)
				.data(stars)
				# .enter()
					.append("Sphere")
					.attr(
						position: (d)-> astroToXYZ d
						# radius: -> 0.2 # Size of star is "roughly" proportional to magnitude + temperatur
						color: 0xffaabb
					)
					# .append("PointLight")
					# .attr(
					# 	position: (d)-> astroToXYZ d
					# 	color: (d)-> 0xFFFFFF
					# )
