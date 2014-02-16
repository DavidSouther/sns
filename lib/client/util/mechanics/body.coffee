define [], ()->
	G = 6.674e-11
	TWO_PI = 2 * Math.PI
	HALF_PI = 0.5 * Math.PI

	CelestialBody = class CelestialBody
		constructor: (@mass, @radius, @siderealRotation, @orbit, @atmPressure) ->
			@gravitationalParameter = G * @mass
			@sphereOfInfluence = @orbit.semiMajorAxis * Math.pow(@mass / @orbit.referenceBody.mass, 0.4) if @orbit?
			@atmPressure ?= 0

		circularOrbitVelocity: (altitude) ->
			Math.sqrt(@gravitationalParameter / (altitude + @radius))
		
		siderealTimeAt: (longitude, time) ->
			result = ((time / @siderealRotation) * TWO_PI + HALF_PI + longitude) % TWO_PI
			if result < 0 then result + TWO_PI else result
		
		name: -> return k for k, v of CelestialBody when v == this
		
		children: ->
			result = {}
			result[k] = v for k, v of CelestialBody when v?.orbit?.referenceBody == this
			result

	CelestialBody.fromJSON = (json) ->
		orbit = Orbit.fromJSON(json.orbit) if json.orbit?
		new CelestialBody(json.mass, json.radius, json.siderealRotation, orbit, json.atmPressure)

	CelestialBody
