extends Area2D

export var item_name : String = ""

func _ready():
	randomize()
	rotation = rand_range(0.0, 2*PI)
	add_to_group("item")
	assign_sprite()
	
func assign_sprite():
	$Sprite.texture = Global.dropped_items[item_name]["sprite"]
