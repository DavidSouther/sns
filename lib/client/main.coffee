stage = 'planet'

require ["#{stage}/level"], (stage)->
	stage.play("#simulator")
