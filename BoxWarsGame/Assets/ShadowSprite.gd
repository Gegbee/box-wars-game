extends Sprite

class_name ShadowSprite

export var shadow_offset : float = 4.0
export (float, 0.0, 1.0) var shadow_opacity = 0.5
var shadow : Sprite

func _ready():
	shadow = Sprite.new()
	add_child(shadow)
	if texture:
		shadow.texture = texture
	shadow.modulate = "000000"
	shadow.modulate.a = shadow_opacity
	shadow.z_index = z_index-1
	
func _process(delta):
	if shadow.texture:
		shadow.global_position = global_position - Vector2(0, -shadow_offset)
	else:
		if texture:
			shadow.texture = texture
