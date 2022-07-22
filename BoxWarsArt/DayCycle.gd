extends CanvasModulate


export var gradient : Gradient

var _t: float = 0.0
export var time_for_full_cycle : float = 120.0

func _process(delta):
	_t += delta/time_for_full_cycle
	color = gradient.interpolate(_t)
	if _t > 1.0:
		_t = 0.0
	#get_parent().get_node("WorldEnvironment").environment.glow_bloom = abs(_t)/10.0
