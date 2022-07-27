extends DroppedItem

# you can write the code here to detect what area it is in and if it can be picked up
# prolly want like a 3 second delay before it can be picked up
func _ready():
	can_pickup = false
	$Timer.start(2)


func _on_Timer_timeout():
	can_pickup = true
