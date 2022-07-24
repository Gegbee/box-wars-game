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

var cur_item_to_pickup = null
var cur_item_held_name : String = ""
var cur_item = null

func _ready():
	add_to_group("player")
	
	yield(get_tree(), "idle_frame")
	
	if is_network_master():
		exchange_items(cur_item, null)
		#rpc("exchange_items", cur_item, null)
		$Camera2D.current = true
		get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	
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
			velocity = lerp(velocity, Vector2.ZERO, ACCEL * delta * 2.0)
		
		#$Body.rotation += PI/2
		#$Feet.rotation = atan2(dir_input.y, dir_input.x)
		velocity -= impulse_vector
		look_at(get_global_mouse_position())
		velocity = move_and_slide(velocity)
		
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", velocity)
		
		cur_item_to_pickup = null
		for item in $ItemDetection.get_overlapping_areas():
			if item.is_in_group("item"):
				cur_item_to_pickup = item

		if Input.is_action_just_pressed("interact"):
			exchange_items(cur_item, cur_item_to_pickup)
		
		use_item()
	else:
		rotation = lerp_angle(rotation, puppet_rotation, delta * 8)
		
		if velocity.length() > 60.0:
			if abs(velocity.normalized().dot(Vector2(cos(rotation), sin(rotation)))) > 0.5:
				$AnimationPlayer.play("PlayerWalking")
			else:
				$AnimationPlayer.play("PlayerShuffle")
		else:
			$AnimationPlayer.play("PlayerIdle")
	
	$Position2D/Username.text = username
	$Position2D.global_rotation = 0
	
func exchange_items(_cur_item, _next_item):
	if _cur_item:
		rpc("remove_item")
	if _next_item:
		rpc("add_item", _next_item.item_name)
		_next_item.rpc("destroy_on_all_clients")
		#cur_item_to_pickup = null
	else:
		rpc("add_item", "fists")
	
func use_item():
	if !cur_item:
		return
	if Global.held_items[cur_item_held_name]["type"] == "gun":
		if cur_item.automatic:
			if cur_item.can_fire and cur_item.current_magazine > 0 and Input.is_action_pressed("attack"):
				cur_item.rpc("shoot", 0, rotation, "Bullet")
		else:
			if cur_item.can_fire and cur_item.current_magazine > 0 and Input.is_action_just_pressed("attack"):
				cur_item.rpc("shoot", 0, rotation, "Bullet")
		if Input.is_action_just_pressed("reload"):
			cur_item.reload()
	elif Global.held_items[cur_item_held_name]["type"] == "melee":
		if cur_item.automatic:
			if Input.is_action_pressed("attack"):
				cur_item.attack()
		else:
			if Input.is_action_just_pressed("attack"):
				cur_item.attack()
				
remotesync func add_item(_item_name):
	cur_item_held_name = _item_name.to_lower()
	
	cur_item = Global.held_items[cur_item_held_name]["scene"].instance()
	cur_item.name = "HeldItem" + str(int(name)) + str(Global.node_name_index)
	Global.node_name_index += 1
	add_child(cur_item)
	cur_item.position = Global.held_items[cur_item_held_name]["hold_position"]
	
remotesync func remove_item():
	if Global.held_items[cur_item_held_name]["drop"]:
#		var dropped_item = Global.DROPPED_ITEM.instance()
#		dropped_item.item_name = cur_item_held_name
#		dropped_item.assign_sprite()
#		get_tree().get_current_scene().add_child(dropped_item)
#		dropped_item.global_position = global_position
		Global.spawn_item("Item" + str(int(name)) + str(Global.node_name_index), cur_item_held_name, global_position)
		#Global.rpc("spawn_item_on_all_clients", "Item" + str(int(name)) + str(Global.node_name_index), cur_item_held_name, global_position)
		Global.node_name_index += 1
	cur_item.queue_free()
	cur_item = null
	cur_item_held_name = ""
	
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

func _network_peer_connected(id):
	if cur_item:
		rpc_id(id, "add_item", cur_item_held_name)
