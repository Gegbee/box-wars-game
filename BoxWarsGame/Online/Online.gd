extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("self_destroy"): #M
		Network.rpc("remove_player_on_all_clients", get_tree().get_network_unique_id())
	if Input.is_action_just_pressed("self_create"): #N
		Network.rpc("create_player_on_all_clients", get_tree().get_network_unique_id(), Network.username)
