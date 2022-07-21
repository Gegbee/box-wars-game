extends KinematicBody2D

var velocity := Vector2()

const MAX_SPEED := 60
const ACCEL : float = 10.0

var username : String = "default name"

export var knockback_resistance : float = 1.0
var impulse_vector : Vector2 = Vector2()
var impulse_strength : float = 0.0

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0
  
func _ready():
	add_to_group("player")

func _physics_process(delta):
	if is_network_master():
		$Camera2D.current = true
		
		impulse_vector.x = lerp(impulse_vector.x, 0, 5.0 * delta)
		impulse_vector.y = lerp(impulse_vector.y, 0, 5.0 * delta)
		if impulse_vector.length() < 0.2:
			impulse_vector = Vector2()
			impulse_strength = 0.0
			
		var dir_input = Vector2(
			Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
		)
		
		dir_input = dir_input.normalized()
		if dir_input.length() > 0:
			#if abs(dir_input.dot(Vector2(cos(rotation), sin(rotation)))) > 0.5:
				#$AnimationPlayer.play("Walking")
			#else:
				#$AnimationPlayer.play("Shuffle")
			velocity = lerp(velocity, dir_input.normalized() * MAX_SPEED, ACCEL * delta)
		else:
			#$AnimationPlayer.play("Idle")
			velocity = lerp(velocity, Vector2.ZERO, ACCEL * delta)
		
		#$Body.rotation += PI/2
		#$Feet.rotation = atan2(dir_input.y, dir_input.x)
		velocity -= impulse_vector
		look_at(get_global_mouse_position())
		velocity = move_and_slide(velocity)
		
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", velocity)
		
	else:
		rotation = lerp_angle(rotation, puppet_rotation, delta * 8)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	$tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$tween.start()
