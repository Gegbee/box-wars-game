extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 4

var server : NetworkedMultiplayerENet = null
var client : NetworkedMultiplayerENet = null

var username = ""
var ip_address = ""

const PLAYER = preload("res://Player/Player.tscn")

var upnp : UPNP = null
var players : Dictionary = {
	
}

func _ready():
#	if OS.get_name() == "Windows":
#		ip_address = IP.get_local_addresses()[3]
#
#	for address in IP.get_local_addresses():
#		if address.begins_with("192.168.") and not address.ends_with(".1"):
#			ip_address = address
#			break
	
	ip_address = "127.0.0.1"
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")

func _network_peer_connected(id):
	print("peer connected")
	rpc_id(id, "instance_player", get_tree().get_network_unique_id(), username)
		
func _network_peer_disconnected(id):
	print("peer disconnected")
	remove_player(id)
		
func create_server():
	if upnp == null:
		upnp = UPNP.new()
		upnp.discover()
		ip_address = upnp.query_external_address()
	var err = upnp.add_port_mapping(DEFAULT_PORT)
	if err != upnp.UPNP_RESULT_SUCCESS:
		push_error("Unable to port forward" + str(err))
	print(ip_address)
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	print("server created")
	# INSTANCE SERVER'S PLAYER
	if !Global.is_headless_server:
		instance_player(get_tree().get_network_unique_id(), username)
	get_tree().change_scene("res://Online/Online.tscn")
		
func join_server():
	client = NetworkedMultiplayerENet.new()
	print(ip_address)
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("client created")
	
func _connected_to_server():
	print("connected")
	yield(get_tree().create_timer(0.1), "timeout")
	# INSTANCE NEW CLIENT'S PLAYER
	instance_player(get_tree().get_network_unique_id(), username)
	get_tree().change_scene("res://Online/Online.tscn")
	
	
func _server_disconnected():
	print("disconnected")
	for child in Objects.get_children():
		child.queue_free()
	client.close_connection()
	get_tree().change_scene("res://Offline/Offline.tscn")


remotesync func create_player_on_all_clients(id, _username):
	if Objects.has_node(str(id)):
		return
	var player_instance = instance_player(id, _username)

remote func instance_player(id, _username):
	var player_instance = PLAYER.instance()
	player_instance.name = str(id)
	print(player_instance.name)
	player_instance.set_network_master(id)
	Objects.add_child(player_instance)
	player_instance.username = _username
	if get_tree().get_network_unique_id() == id:
		print("Controlled player set to: ", str(id))
		Global.controlled_player = player_instance
	return player_instance

func remove_player(id):
	if Objects.has_node(str(id)):
		if get_tree().get_network_unique_id() == id:
			if Global.controlled_player != null:
				Global.controlled_player = null
#			else:
#				return
		Objects.get_node(str(id)).queue_free()
		
remotesync func remove_player_on_all_clients(id):
	remove_player(id)

func _exit_tree():
	if upnp:
		upnp.delete_port_mapping(DEFAULT_PORT)
	print("exited game")
