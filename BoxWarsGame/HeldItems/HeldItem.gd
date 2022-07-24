extends Node

class_name HeldItem

remotesync func destroy_on_all_clients():
	queue_free()
