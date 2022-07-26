extends CanvasLayer

func _ready():
	Global.respawn_button = $CenterContainer/Button
	$CenterContainer/Button.hide()

func _on_Button_pressed():
	Global.controlled_player.rpc("enable", Vector2())
	#Network.rpc("create_player_on_all_clients", get_tree().get_network_unique_id(), Network.username)
	$CenterContainer/Button.hide()
