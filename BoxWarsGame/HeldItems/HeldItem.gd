extends Node2D

class_name HeldItem

var item_name : String = "default"

remotesync func destroy_on_all_clients():
	queue_free()
