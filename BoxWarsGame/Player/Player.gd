extends KinematicBody2D

var velocity := Vector2()
var velocity_mult : float = 1.0
var can_boost : bool = true

const MAX_SPEED : int = 400
const ACCEL : float = 6.0

var username : String = "default name"

#export var knockback_resistance : float = 1.0
#var impulse_vector : Vector2 = Vector2()
#var impulse_strength : float = 0.0

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

var item_ready_to_pickup = null
var held_item = null

func _ready():
	add_to_group("player")
	
	yield(get_tree(), "idle_frame")
	if health_bar_path:
		health_bar = get_node(health_bar_path)
	
	if is_network_master():
		exchange_items(held_item, null)
		#rpc("exchange_items", held_item, null)
		$Camera2D.current = true
		get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	
func _physics_process(delta):
	if is_network_master():
#		impulse_vector.x = lerp(impulse_vector.x, 0, 5.0 * delta)
#		impulse_vector.y = lerp(impulse_vector.y, 0, 5.0 * delta)
#		if impulse_vector.length() < 0.2:
#			impulse_vector = Vector2()
#			impulse_strength = 0.0
			
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
		
		#velocity -= impulse_vector
		look_at(get_global_mouse_position())
		velocity = move_and_slide(velocity * velocity_mult)
		
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", velocity)
		
		item_ready_to_pickup = null
		for item in $ItemDetection.get_overlapping_areas():
			if item.is_in_group("item") and item.can_pickup:
				item_ready_to_pickup = item

		if Input.is_action_just_pressed("interact"):
			exchange_items(held_item, item_ready_to_pickup)
		
		velocity_mult = lerp(velocity_mult, 1.0, 40.0 * delta)
		if Input.is_action_just_pressed("boost") and can_boost:
			can_boost = false
			$BoostTimer.start(3.0)
			velocity_mult = 3.0
			
		use_held_item()
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
	
func exchange_items(_held_item, _next_item):
	if _held_item:
		rpc("remove_held_item", Global.gen_unique_node_name("DroppedItem", int(name)))
	if _next_item:
		rpc("add_held_item", _next_item.item_name,  Global.gen_unique_node_name("HeldItem", int(name)))
		_next_item.rpc("destroy_on_all_clients")
	else:
		rpc("add_held_item", "fists", Global.gen_unique_node_name("HeldItem", int(name)))
		
func use_held_item():
	if !held_item:
		return
	if Global.held_items[held_item.item_name]["type"] == "gun":
		if held_item.automatic:
			if held_item.can_fire and held_item.current_magazine > 0 and Input.is_action_pressed("attack"):
				held_item.rpc("shoot", 0, rotation, "Bullet")
		else:
			if held_item.can_fire and held_item.current_magazine > 0 and Input.is_action_just_pressed("attack"):
				held_item.rpc("shoot", 0, rotation, "Bullet")
		if Input.is_action_just_pressed("reload"):
			held_item.reload()
	elif Global.held_items[held_item.item_name]["type"] == "melee":
		if held_item.automatic:
			if Input.is_action_pressed("attack"):
				#held_item.rpc("attack")
				held_item.attack()
		else:
			if Input.is_action_just_pressed("attack"):
				#held_item.rpc("attack")
				held_item.attack()
				
remotesync func add_held_item(_item_name, _new_name : String):
	held_item = Global.held_items[_item_name.to_lower()]["scene"].instance()
	held_item.item_name = _item_name.to_lower()
	held_item.name = _new_name
	add_child(held_item)
	held_item.position = Global.held_items[held_item.item_name]["hold_position"]
	
remotesync func remove_held_item(_new_name : String):
	if Global.held_items[held_item.item_name]["drop"]:
		Global.spawn_item(_new_name, held_item.item_name, global_position)
	held_item.queue_free()
	held_item = null
	
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	$tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$tween.start()

#puppet velocity can be simplified but i just made this for testing
func puppet_velocity_set(new_value):
	puppet_velocity = new_value
	velocity = puppet_velocity
	
remotesync func damage(dmg : int, impulse_dir : Vector2 = Vector2(), strength : float = 0):
	set_health(health - dmg)
	#impulse(impulse_dir.normalized(), strength)
	if is_network_master():
		print(self.name + " health: " + str(health) + " / " + str(MAX_HEALTH))
	
func set_health(new_health : int):
	if invincible:
		return
	if new_health <= 0: #and health > 0:
		kys()
	health = new_health
	#rset("puppet_health", health)
	if health_bar:
		health_bar.updateHealth(health)

func puppet_health_set(new_value):
	puppet_health = new_value
	health = puppet_health
	
func kys():
	emit_signal("OnEntityDead")
	if is_network_master():
		Global.respawn_button.show()
	disable()
#	yield(get_tree().create_timer(1), "timeout")
#	queue_free()

#func impulse(dir : Vector2, strength: float):
#	impulse_strength = strength
#	impulse_vector = dir * strength / knockback_resistance

func _network_peer_connected(id):
	if held_item:
		rpc_id(id, "add_held_item", held_item.item_name, held_item.name)

remotesync func enable(spawn_position : Vector2):
	global_position = spawn_position
	set_process(true)
	set_physics_process(true)
	set_health(MAX_HEALTH)
	visible = true
	$CollisionShape2D.disabled = false
	if is_network_master():
		exchange_items(held_item, null)
	
func disable():
	set_process(false)
	set_physics_process(false)
	visible = false
	$CollisionShape2D.disabled = true
	if is_network_master() and held_item:
		exchange_items(held_item, null)


func _on_BoostTimer_timeout():
	can_boost = true
