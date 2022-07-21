extends Area2D

export var item_name : String = ""
export var item_sprite : Texture

func _ready():
	randomize()
	rotation = rand_range(0.0, 2*PI)
	add_to_group("item")
	$Sprite.texture = item_sprite

