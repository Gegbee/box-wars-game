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
		"hold_position" : Vector2(5, 0)
	},
	"kudi" : {
		"type" : "gun",
		"scene" : preload("res://HeldItems/Weapons/Kudi.tscn"),
		"hold_position" : Vector2(5, 0)
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
