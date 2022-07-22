extends Node2D



export var melee_distance : int = 100.0
export var melee_damage : int = 10.0
export var automatic : bool = false
# melee_speed is how often (in seconds) a player can use the melee regardless of the automatic attribute.
export var melee_speed : float = 1.0

var melee_dir : Vector2 = Vector2()

func _ready():
	$Timer.wait_time = melee_speed
	$RayCast2D.cast_to = Vector2(melee_distance, 0)
	$RayCast2D.add_exception(get_parent())
	
func _process(delta):
	$RayCast2D.cast_to = melee_dir.normalized() * melee_distance
	
func attack():
	if $Timer.time_left > 0:
		return
	$AnimationPlayer.play("Attack")
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider.is_in_group('eplayer'):
			collider.damage(melee_damage)
	$Timer.start(melee_speed)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		$AnimationPlayer.play("Idle")
