extends Area2D

class_name DroppedItem

export var item_name : String = ""
var can_pickup : bool = true

func _ready():
	randomize()
	rotation = rand_range(0.0, 2*PI)
	add_to_group("item")
	assign_sprite()
	get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	
func assign_sprite():
	$Sprite.texture = Global.dropped_items[item_name]["sprite"]

remotesync func destroy_on_all_clients():
	queue_free()

func _network_peer_connected(id):
#	var instance : DroppedItem = Global.DROPPED_ITEM.instance()
#	instance.name = name
	Global.rpc_id(id, "spawn_item", name, item_name, global_position)
