extends KinematicBody2D

var velocity := Vector2()

const MAX_SPEED := 60
const ACCEL : float = 15.0

func _physics_process(delta):
	var dir_input = Vector2(
		Input.get_action_strength("right")-Input.get_action_strength("left"),
		Input.get_action_strength("down")-Input.get_action_strength("up")
	)
	dir_input = dir_input.normalized()
	if dir_input.length() > 0:
		print(dir_input.dot(Vector2(cos(rotation), sin(rotation))))
		if abs(dir_input.dot(Vector2(cos(rotation), sin(rotation)))) > 0.5:
			$AnimationPlayer.play("Walking")
		else:
			$AnimationPlayer.play("Shuffle")
		velocity = lerp(velocity, dir_input.normalized() * MAX_SPEED, ACCEL * delta)
	else:
		$AnimationPlayer.play("Idle")
		velocity = lerp(velocity, Vector2.ZERO, ACCEL * delta)
	look_at(get_global_mouse_position())
	#$Body.rotation += PI/2
	#$Feet.rotation = atan2(dir_input.y, dir_input.x)
	velocity = move_and_slide(velocity)
