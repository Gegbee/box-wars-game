extends TextureProgress

var glow_r : int = 330

func _ready():
	modulate = Color8(glow_r, 255, 255, 255)
	max_value = get_parent().get_parent().MAX_HEALTH
	$Tween.interpolate_property(self, "modulate", Color8(glow_r, 255, 255, 255),
	Color8(glow_r, 255, 255, 0), 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 3)
	$Tween.start()

func updateHealth(new_health : int):
	max_value = get_parent().get_parent().MAX_HEALTH
	#$Tween.stop(self, ":modulate")
#	$Tween.interpolate_property(self, "rect_scale", rect_scale, 
#	Vector2(1, 1) * 1.3, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
#
#	$Tween.interpolate_property(self, "rect_scale", rect_scale, 
#	Vector2(1, 1), 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 2)
	$Tween.remove_all()
	modulate = Color8(glow_r, 255, 255, 255)
	
	$Tween.interpolate_property(self, "modulate", Color8(glow_r, 255, 255, 255),
	Color8(glow_r, 255, 255, 0), 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 3)
	$Tween.start()
#	$Timer.stop()
#	$Timer.start(3)
	value = new_health
	impulseBar()
	
func impulseBar():
	$Tween2.remove_all()
	$Tween2.interpolate_property(self, "rect_scale", rect_scale,
	Vector2(1.5, 1.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween2.start()
	yield($Tween2, "tween_completed")
	$Tween2.interpolate_property(self, "rect_scale", rect_scale,
	Vector2(1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween2.start()
