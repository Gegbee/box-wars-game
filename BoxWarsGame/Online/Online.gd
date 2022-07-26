extends Node2D

func _ready():
	if get_tree().is_network_server():
		Global.rpc("spawn_item_on_all_clients", Global.gen_unique_node_name("DroppedItem", get_tree().get_network_unique_id()), "flag", Vector2())
		Global.rpc("spawn_item_on_all_clients", Global.gen_unique_node_name("DroppedItem", get_tree().get_network_unique_id()), "hammer", Vector2())

func _process(delta):
#	if Input.is_action_just_pressed("self_destroy"): #M
#		Network.rpc("remove_player_on_all_clients", get_tree().get_network_unique_id())
#	if Input.is_action_just_pressed("self_create"): #N
#		Network.rpc("create_player_on_all_clients", get_tree().get_network_unique_id(), Network.username)
	pass
