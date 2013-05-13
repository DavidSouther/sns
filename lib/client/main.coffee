stage = 'planet'

require ["#{stage}/stage"], (stage)->
	stage.play("#simulator")
