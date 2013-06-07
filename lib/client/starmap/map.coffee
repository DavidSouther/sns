define [], ()->
	(scene)->
		d3.csv "starmap/assets/stars.csv", (error, stars)->
			colors =
				L: 0xd20033
				M: 0xffbd6f
				K: 0xffddb4
				G: 0xfff4e8
				F: 0xfbf8ff
				A: 0xcad8ff
				B: 0xaabfff
				O: 0x9db4ff

			d3d(scene)
				.data(stars)
				.enter()
					.append("Sphere")
					.attr(
						position: (d)-> sphere.astroToXYZ d
						# radius: -> 0.2 # Size of star is "roughly" proportional to magnitude + temperature
						ambient: (d)-> colors[d.Class[0]]
					)
