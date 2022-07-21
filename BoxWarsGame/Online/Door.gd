extends Node2D


export var openable = true
var opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

puppetsync func open():
	opened = true
	$CollisionShape2D.set_deferred("disabled", true)
	#$Position2D.rotate(lerp(0, deg2rad(110), 0.3))
	
	
	$Tween.interpolate_property($Polygon2D, "scale", Vector2(0, 1), Vector2(1, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

#puppetsync func close():
#	$CollisionShape2D.set_deferred("disabled", true)
#	$Tween.interpolate_property($Polygon2D, "scale", Vector2(1, 0), Vector2(0, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
#	$Tween.start()
	
func _on_Area2D_body_entered(body):
	if body.is_in_group('player') && not opened:
		rpc('open')
#	if body.is_in_group('player') && opened:
#		rpc('close')
#		yield(get_tree().create_timer(1.0), "timeout")
