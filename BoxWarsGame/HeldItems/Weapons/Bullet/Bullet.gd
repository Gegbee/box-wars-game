extends KinematicBody2D

var direction = Vector2()
var speed := 400
var damage : int = 0

var velocity : Vector2 = Vector2()

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0.0

var initial_position := Vector2()

var player_owner : int = 0

signal in_init_position()

func _ready():
	z_index = 10
	$CollisionShape.disabled = true
#	connect("in_init_position", $Trail, "bullet_in_init_position")
#	emit_signal("in_init_position")

func initialize(_speed : float, _direction : Vector2, _damage : float):
	velocity = _direction * _speed
	damage = _damage
	rotation = atan2(_direction.y, _direction.x) + PI/2
	initial_position = global_position
	$CollisionShape.set_deferred("disabled", false)
	
func _physics_process(delta):
	var _movement = move_and_slide(velocity)
		
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision.collider.is_in_group("player"):
			collision.collider.damage(damage)
		rpc("destroy")
	if (global_position - initial_position).length() > 2000:
		rpc("destroy")
			
func puppet_position_set(new_value):
	puppet_position = new_value
	global_position = puppet_position
	
remotesync func destroy():
	set_process(false)
	set_physics_process(false)
	queue_free()
