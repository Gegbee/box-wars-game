extends Control



onready var username_input = $CenterContainer/VBoxContainer/Username
onready var ip_input = $CenterContainer/VBoxContainer/IP


func _on_Server_pressed():
	if len(ip_input.text) > 0:
		Network.ip_address = ip_input.text
	Network.create_server()

func _on_Client_pressed():
	if len(username_input.text) <= 0:
		return
	Network.username = username_input.text
	Network.join_server()
