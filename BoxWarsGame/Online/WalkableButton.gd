extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = Color(0, 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_WalkableButton_body_entered(body):
	if body.get_tree().is_network_server():
		rpc('change_color')

puppetsync func change_color():
	$Sprite.modulate = Color(1, 0, 1)
