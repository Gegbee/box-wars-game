extends KinematicBody2D

var velocity := Vector2()

const MAX_SPEED := 60
const ACCEL : float = 10.0

var cur_item_to_pickup = null
var cur_item_held_name : String = ""
var cur_item = null

var invincible : bool = false
export var health_bar_path : NodePath
var health_bar = null
export var MAX_HEALTH : int = 100
onready var health : int = MAX_HEALTH
signal OnEntityDead()

export var knockback_resistance : float = 1.0
var impulse_vector : Vector2 = Vector2()
var impulse_strength : float = 0.0

func _ready():
	exchange_items()
	
func _physics_process(delta):
	impulse_vector.x = lerp(impulse_vector.x, 0, 5.0 * delta)
	impulse_vector.y = lerp(impulse_vector.y, 0, 5.0 * delta)
	if impulse_vector.length() < 0.2:
		impulse_vector = Vector2()
		impulse_strength = 0.0
		
	var dir_input = Vector2(
		Input.get_action_strength("right")-Input.get_action_strength("left"),
		Input.get_action_strength("down")-Input.get_action_strength("up")
	)
	dir_input = dir_input.normalized()
	if dir_input.length() > 0:
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
	velocity -= impulse_vector
	velocity = move_and_slide(velocity)
	
	cur_item_to_pickup = null
	for item in $ItemDetection.get_overlapping_areas():
		if item.is_in_group("item"):
			cur_item_to_pickup = item

	if Input.is_action_just_pressed("interact"):
		exchange_items()
		
	use_item()
	$UsernameLabel.global_rotation = 0
	
func exchange_items():
	if cur_item:
		remove_item()
	if cur_item_to_pickup:
		add_item(cur_item_to_pickup.item_name)
		cur_item_to_pickup.queue_free()
		cur_item_to_pickup = null
	else:
		add_item("fists")
	
func use_item():
	if !cur_item:
		return
	if Global.held_items[cur_item_held_name]["type"] == "gun":
		if cur_item.automatic:
			if Input.is_action_pressed("shoot"):
				cur_item.shoot(0, rotation, "Bullet")
		else:
			if Input.is_action_just_pressed("shoot"):
				cur_item.shoot(0, rotation, "Bullet")
		if Input.is_action_just_pressed("reload"):
			cur_item.reload()
	elif Global.held_items[cur_item_held_name]["type"] == "melee":
		if cur_item.automatic:
			if Input.is_action_pressed("shoot"):
				cur_item.attack()
		else:
			if Input.is_action_just_pressed("shoot"):
				cur_item.attack()
				
func add_item(_name):
	cur_item_held_name = _name.to_lower()
	cur_item = Global.held_items[cur_item_held_name]["scene"].instance()
	add_child(cur_item)
	cur_item.position = Global.held_items[cur_item_held_name]["hold_position"]
	
func remove_item():
	if Global.held_items[cur_item_held_name]["drop"]:
		var dropped_item = Global.DROPPED_ITEM.instance()
		dropped_item.item_name = cur_item_held_name
		dropped_item.assign_sprite()
		get_tree().get_current_scene().add_child(dropped_item)
		dropped_item.global_position = global_position
	cur_item.queue_free()
	cur_item = null
	cur_item_held_name = ""
	
func damage(dmg : int, impulse_dir : Vector2 = Vector2(), strength : float = 0):
	set_health(health - dmg)
	impulse(impulse_dir.normalized(), strength)
	print(self.name + " health: " + str(health) + " / " + str(MAX_HEALTH))

func set_health(new_health : int):
	if invincible:
		return
	if new_health <= 0: #and health > 0:
		kys()
	health = new_health
	if health_bar:
		health_bar.updateHealth(health)
	
func kys():
	emit_signal("OnEntityDead")
	queue_free()

func impulse(dir : Vector2, strength: float):
	impulse_strength = strength
	impulse_vector = dir * strength / knockback_resistance

