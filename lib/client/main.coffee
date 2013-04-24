stage = 'ship'

require ["#{stage}/stage"], (stage)->
	stage.play("#simulator")
