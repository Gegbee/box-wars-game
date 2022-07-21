extends Node

const DROPPED_ITEM = preload("res://DroppedItems/DroppedItem.tscn")

var held_items : Dictionary = {
	"flag" : {
		"type" : "hold/drop",
		"hold_position" : Vector2()
	},
	"pewpi" : {
		"type" : "gun",
		"hold_position" : Vector2(),
		"gun_attributes" : [],
		"sprite_attributes" : [preload("res://Assets/PewpiHeld.png"), 3, Vector2()]
	}
}
var dropped_items : Dictionary = {
	"pewpi" : {
		"sprite" : preload("res://Assets/PewpiDropped.png")
	}
}
