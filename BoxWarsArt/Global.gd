extends Node

const DROPPED_ITEM = preload("res://DroppedItems/DroppedItem.tscn")

var held_items : Dictionary = {
	"flag" : {
		"type" : "hold/drop",
		"hold_position" : Vector2()
	},
	"pewpi" : {
		"type" : "gun",
		"scene" : preload("res://HeldItems/Weapons/Pewpi.tscn"),
		"hold_position" : Vector2(5, 0),
		"drop" : true
	},
	"kudi" : {
		"type" : "gun",
		"scene" : preload("res://HeldItems/Weapons/Kudi.tscn"),
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
		"sprite" : preload("res://Assets/PewpiDropped.png")
	},
	"kudi" : {
		"sprite" : preload("res://Assets/KudiDropped.png")
	}
}
