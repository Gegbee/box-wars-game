extends Node

var controlled_player : KinematicBody2D = null

const DROPPED_ITEM = preload("res://DroppedItems/DroppedItem.tscn")
	
var node_name_index : int = 0

var held_items : Dictionary = {
	"flag" : {
		"type" : "hold/drop",
		"scene" : preload("res://HeldItems/Flag/FlagHeldItem.tscn"),
		"hold_position" : Vector2(150, 0),
		"drop" : true
	},
	"pewpi" : {
		"type" : "gun",
		"scene" : preload("res://HeldItems/Weapons/Pewpi.tscn"),
		"hold_position" : Vector2(5, 0),
		"drop" : true
	},
	"fists" : {
		"type" : "melee",
		"scene" : preload("res://HeldItems/Weapons/Melee/Fists.tscn"),
		"hold_position" : Vector2(),
		"drop" : false
	},
	"template" : {
		"type" : "melee/gun/hold/drop",
		"scene" : "PackedScene",
		"hold_position" : Vector2(),
		"drop" : true
	}
}
var dropped_items : Dictionary = {
	"pewpi" : {
		"scene" : DROPPED_ITEM,
		"sprite" : preload("res://Assets/PewpiDropped.png")
	},
	"flag" : {
		"scene" : preload("res://DroppedItems/Flag/FlagDroppedItem.tscn"),
		"sprite" : preload("res://Assets/Chair.png")
	}
}

#func create_unique_node_instance(scene : PackedScene, unique_node_name : String, id : int):
#	var instance = scene.instance()
#	instance.name = unique_node_name + str(id) + str(node_name_index)
#	node_name_index += 1
#	return instance
	
remotesync func spawn_item_on_all_clients(_name : String, item_name : String, pos : Vector2):
	#var instance : DroppedItem = create_unique_node_instance(DROPPED_ITEM, "Item", id)
	spawn_item(_name, item_name, pos)

remote func spawn_item(_name : String, item_name : String, pos : Vector2):
	var instance : DroppedItem = dropped_items[item_name]["scene"].instance()
	instance.name = _name
	instance.item_name = item_name.to_lower()
	instance.position = pos
	#instance.assign_sprite()
	Objects.add_child(instance)
	
#remote func destroy_item_on_all_clients(node):
#	# MUST CHANGE TO SCREEN
#	rpc("destroy_instance_on_all_clients", node)

#remotesync func spawn_instance_on_all_clients(instance):
#	Objects.add_child(instance)
	
#remotesync func destroy_instance_on_all_clients(instance):
#	instance.queue_free()

func gen_unique_node_name(node_name : String, parent_id : int):
	var new_name = node_name + str(parent_id) + str(node_name_index)
	node_name_index += 1
	return new_name
