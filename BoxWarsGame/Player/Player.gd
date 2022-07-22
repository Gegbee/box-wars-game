extends KinematicBody2D

var velocity := Vector2()

const MAX_SPEED : int = 400
const ACCEL : float = 6.0

var username : String = "default name"

export var knockback_resistance : float = 1.0
var impulse_vector : Vector2 = Vector2()
var impulse_strength : float = 0.0

puppet var puppet_position = Vector2() setget puppet_position_set
# setget for puppet_velocity can be deleted later i just made this for animation testing
puppet var puppet_velocity = Vector2() setget puppet_velocity_set
puppet var puppet_rotation = 0.0
  
var invincible : bool = false
export var health_bar_path : NodePath
var health_bar = null
export var MAX_HEALTH : int = 100
onready var health : int = MAX_HEALTH
puppet var puppet_health : int = 100 setget puppet_health_set
signal OnEntityDead()

func _ready():
	add_to_group("player")
	if is_network_master():
		$Camera2D.current = true
		
func _physics_process(delta):
	if is_network_master():
		
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
			if abs(dir_input.dot(Vector2(cos(rotation), sin(rotation)))) > 0.5:
				$AnimationPlayer.play("PlayerWalking")
			else:
				$AnimationPlayer.play("PlayerShuffle")
			velocity = lerp(velocity, dir_input.normalized() * MAX_SPEED, ACCEL * delta)
		else:
			$AnimationPlayer.play("PlayerIdle")
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
	
		if velocity.length() > 60.0:
			if abs(velocity.normalized().dot(Vector2(cos(rotation), sin(rotation)))) > 0.5:
				$AnimationPlayer.play("PlayerWalking")
			else:
				$AnimationPlayer.play("PlayerShuffle")
		else:
			$AnimationPlayer.play("PlayerIdle")
		
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	$tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$tween.start()

#puppet velocity can be simplified but i just made this for testing
func puppet_velocity_set(new_value):
	puppet_velocity = new_value
	velocity = puppet_velocity
	
func damage(dmg : int, impulse_dir : Vector2 = Vector2(), strength : float = 0):
	set_health(health - dmg)
	impulse(impulse_dir.normalized(), strength)
	print(self.name + " health: " + str(health) + " / " + str(MAX_HEALTH))
	
func set_health(new_health : int):
	if invincible:
		return
	if new_health <= 0: #and health > 0:
		rpc("kys")
	health = new_health
	rset("puppet_health", health)
	if health_bar:
		health_bar.updateHealth(health)

func puppet_health_set(new_value):
	puppet_health = new_value
	health = puppet_health
	
remotesync func kys():
	emit_signal("OnEntityDead")
	queue_free()

func impulse(dir : Vector2, strength: float):
	impulse_strength = strength
	impulse_vector = dir * strength / knockback_resistance

