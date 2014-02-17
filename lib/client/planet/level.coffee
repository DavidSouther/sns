define ["game/clock", "util/mechanics/orbit", "planet/geometry", "planet/galaxy", "util/mechanics/orbital", "ship/ship"],
	(Clock, Orbit, Planet, Galaxy, Orbital, Ship)->
		mass =
			Earth: 5.9e24
		radii =
			Earth: 6.38e6

		controls = update: ->
		class Level extends THREE.Object3D
			constructor: (@stage, orbitParams)->
				super()
				@stage.scene.add @
				@name = 'level'

				earth = new Planet(
					"Earth", mass.Earth, radii.Earth, 0,
					null, 1,
					"https://s3.amazonaws.com/sns_assets/planet/textures/earth_day_4k.jpg",
					# "https://s3.amazonaws.com/sns_assets/planet/textures/earth_bump.jpg"
				)

				earth.position = vec 0, 0, 0
				@add earth

				@planets = [earth]
				@ships = []

				@add Galaxy()
				@add light = new THREE.AmbientLight 0xE0E0E0
				light.name = "#{@name}_ambient"

				orbitParams.referenceBody = earth
				orbit = Orbit.fromJSON orbitParams
				orbital = new Orbital orbit
				@add orbital

				@addShip = (ship)=>
					@add ship
					@ships.push ship
					@controls.target = ship
				Ship.load @, orbit

				@update = (clock)=>
					(planet.update clock for planet in @planets)
					(ship.update clock for ship in @ships)

				@controls = @stage.controls = new S3age.Controls.Sphere @stage, earth

				$ =>
					cf = dat.addFolder "Speed"
					cf.add @stage.clock, 'scale', 1, 32
					cf = dat.addFolder "Follow"
					follow =
						ship: => @controls.target = @ships[0]
						earth: => @controls.target = earth
					cf.add follow, 'ship'
					cf.add follow, 'earth'
					cf = dat.addFolder "Pause"
					cf.add @stage, 'start'
					cf.add @stage, 'stop'

		play: (selector)->
			stage = new S3age selector,
				debug: true
				expose: true
				camera:
					far: 6e12
					position: [6.38e6 * 2, 0, 0]
					lookAt: [0, 0, 0]
	
			orbitParams =
				semiMajorAxis: 6.38e6 + 2e5
				eccentricity: 0
				inclination: Math.PI / 2
				longitudeOfAscendingNode: 0
				timeOfPeriapsisPassage: 0
				meanAnomalyAtEpoch: 0
				argumentOfPeriapsis: 0

			new Level stage, orbitParams

			stage.start()
